import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/motion/page_transitions.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/floating_nav_bar.dart';
import '../core/widgets/app_lock_screen.dart';
import '../providers/user_provider.dart';
import 'smart_advice_screen.dart';
import 'analytics_screen.dart';
import 'budget_overview_screen.dart';
import 'edit_budget_screen.dart';
import 'add_expense_screen.dart';
import 'add_money_screen.dart';
import 'create_goal_screen.dart';
import 'goal_details_screen.dart';
import 'savings_goals_screen.dart';
import 'more_screen.dart';
import 'notifications_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_screen.dart';
import 'currency_selection_screen.dart';
import 'general_settings_screen.dart';
import 'notification_preferences_screen.dart';
import 'theme_settings_screen.dart';
import 'transactions_screen.dart';
import 'motion_debug_screen.dart';
import 'home_screen.dart';

/// Main app shell — bottom nav has 4 tabs: Home / Activity / Analytics / More.
/// Profile is accessed via the avatar tap on the home header (pushed route,
/// not a tab). Goals moved into the More tab. The central FAB opens Add Expense.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;
  int _prevIndex = 0;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    // Allow deep-linking via ?tab=<home|activity|analytics|more>
    // for preview/test purposes. Defaults to Home.
    final uri = Uri.base;
    final tab = uri.queryParameters['tab'];
    _index = switch (tab) {
      'activity' => 1,
      'analytics' => 2,
      'more' => 3,
      _ => 0,
    };
    // Allow pushing a sub-route via ?route=<addExpense|budgets|advice|notifications|profile|...>
    _pendingRoute = uri.queryParameters['route'];
  }

  String? _pendingRoute;

  /// Push the Profile screen — used by the home header's avatar tap.
  /// Profile is no longer a bottom-nav tab; it's a pushed route so the
  /// bottom nav has room for Analytics + More.
  void _openProfile() {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      SmoothFadePageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  /// Build the screen for the current tab. Built dynamically so we can pass
  /// callbacks (e.g. HomeScreen's onAvatarTap that pushes ProfileScreen).
  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(onAvatarTap: _openProfile);
      case 1:
        return const TransactionsScreen();
      case 2:
        return const AnalyticsScreen();
      case 3:
        return const MoreScreen();
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
        const goalId = null; // deep-link not available on mobile
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
          case 'profile':
            // Profile is now a pushed route (was a bottom-nav tab).
            target = const ProfileScreen();
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
            SmoothFadePageRoute<Widget>(builder: (_) => target!),
          );
        }
      });
    }
  }

  void _openAddExpense() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      SmoothFadePageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Touch user provider so greeting updates after profile edit
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    if ((user.appLockEnabled || user.biometricsEnabled) && !_isUnlocked) {
      return AppLockScreen(onUnlocked: () => setState(() => _isUnlocked = true));
    }
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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          if (_index != 0) {
            setState(() => _index = 0);
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: AppColorsOf.background(context),
          extendBody: true,
          // Smooth directional slide + crossfade between tabs
          body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, anim) {
            return FadeTransition(
              opacity: anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.99, end: 1.0).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                ),
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
            if (_index == i) return;
            HapticFeedback.selectionClick();
            setState(() {
              _prevIndex = _index;
              _index = i;
            });
          },
          onFabPressed: _openAddExpense,
        ),
      ),
    ),
  );
  }
}

