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

  late final List<Widget> _screens = const [
    HomeScreen(),
    TransactionsScreen(),
    SavingsGoalsScreen(),
    ProfileScreen(),
  ];

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
    return Scaffold(
      backgroundColor: AppColorsOf.background(context),
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _index,
        onTabSelected: (i) => setState(() => _index = i),
        onFabPressed: _openAddExpense,
      ),
    );
  }
}
