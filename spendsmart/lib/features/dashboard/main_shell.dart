import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/floating_nav_bar.dart';
import '../../providers/user_provider.dart';
import '../advice/smart_advice_screen.dart';
import '../analytics/analytics_screen.dart';
import '../budgets/budget_overview_screen.dart';
import '../budgets/edit_budget_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../goals/add_money_screen.dart';
import '../goals/create_goal_screen.dart';
import '../goals/goal_details_screen.dart';
import '../goals/savings_goals_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/currency_selection_screen.dart';
import '../settings/general_settings_screen.dart';
import '../settings/notification_preferences_screen.dart';
import '../settings/theme_settings_screen.dart';
import '../expenses/transactions_screen.dart';
import '../dev/motion_debug_screen.dart';
import 'home_screen.dart';

/// Main app shell — IndexedStack of Home / Transactions / Goals / Profile
/// with floating bottom nav and central FAB that opens Add Expense.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    // Allow deep-linking via ?tab=<home|activity|goals|profile>
    // for preview/test purposes. Defaults to Home.
    final uri = Uri.base;
    final tab = uri.queryParameters['tab'];
    _index = switch (tab) {
      'activity' => 1,
      'goals' => 2,
      'profile' => 3,
      _ => 0,
    };
    // Allow pushing a sub-route via ?route=<analytics|addExpense|budgets|advice|notifications>
    _pendingRoute = uri.queryParameters['route'];
  }

  String? _pendingRoute;

  /// Switch to a tab programmatically — used by the Home's profile avatar
  /// to switch to the Profile tab (index 3) instead of pushing a new route.
  void _switchTab(int i) {
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  /// Build the screen for the current tab. Built dynamically so we can pass
  /// callbacks (e.g. HomeScreen's onAvatarTap that switches to Profile tab).
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(onAvatarTap: () => _switchTab(3));
      case 1:
        return const TransactionsScreen();
      case 2:
        return const SavingsGoalsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pendingRoute != null) {
      final route = _pendingRoute!;
      _pendingRoute = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final goalId = Uri.base.queryParameters['goalId'];
        Widget? target;
        switch (route) {
          case 'analytics':
            target = const AnalyticsScreen();
            break;
          case 'addExpense':
            target = const AddExpenseScreen();
            break;
          case 'budgets':
            target = const BudgetOverviewScreen();
            break;
          case 'editBudget':
            target = const EditBudgetScreen();
            break;
          case 'advice':
            target = const SmartAdviceScreen();
            break;
          case 'notifications':
            target = const NotificationsScreen();
            break;
          case 'editProfile':
            target = const EditProfileScreen();
            break;
          case 'generalSettings':
            target = const GeneralSettingsScreen();
            break;
          case 'notifPrefs':
            target = const NotificationPreferencesScreen();
            break;
          case 'currencySelection':
            target = const CurrencySelectionScreen();
            break;
          case 'themeSettings':
            target = const ThemeSettingsScreen();
            break;
          case 'createGoal':
            target = const CreateGoalScreen();
            break;
          case 'goalDetails':
            if (goalId != null) target = GoalDetailsScreen(goalId: goalId);
            break;
          case 'addMoney':
            if (goalId != null) target = AddMoneyScreen(goalId: goalId);
            break;
          case 'motionDebug':
            target = const MotionDebugScreen();
            break;
        }
        if (target != null) {
          Navigator.of(context).push(
            MaterialPageRoute<Widget>(builder: (_) => target!),
          );
        }
      });
    }
  }

  void _openAddExpense() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Touch user provider so greeting updates after profile edit
    context.watch<UserProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Adapt system status bar to the app theme. Fixes the "dark icons on
      // dark background" bug on Home / Transactions / Goals / Profile tabs
      // (the same fix we applied to auth screens in commit 8b716ae).
      value: isDark
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light, // Android
              statusBarBrightness: Brightness.dark, // iOS — light icons
              systemNavigationBarColor: Color(0xFF0B0F1A),
              systemNavigationBarIconBrightness: Brightness.light,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark, // Android
              statusBarBrightness: Brightness.light, // iOS — dark icons
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
      child: Scaffold(
        backgroundColor: AppColorsOf.background(context),
        extendBody: true,
        // Smooth fade+slide between tabs (instead of IndexedStack which
        // doesn't animate). Each tab swap crossfades over 280ms with a
        // subtle slide-up.
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) {
            return FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_index),
            child: _buildScreen(_index),
          ),
        ),
        bottomNavigationBar: FloatingNavBar(
          currentIndex: _index,
          onTabSelected: (i) {
            HapticFeedback.selectionClick();
            setState(() => _index = i);
          },
          onFabPressed: _openAddExpense,
        ),
      ),
    );
  }
}
