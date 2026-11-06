import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/budget_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/notif_prefs_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/user_provider.dart';
import 'providers/language_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const _Providers());
}


class _Providers extends StatelessWidget {
  const _Providers();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => NotifPrefsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const SpendSmartApp(),
    );
  }
}
