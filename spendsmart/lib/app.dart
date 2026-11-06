import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';

/// Root widget. Rebuilds when ThemeProvider / CurrencyProvider change.
class SpendSmartApp extends StatelessWidget {
  const SpendSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      title: 'SpendSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _toMaterialMode(theme.mode),
      home: const SplashScreen(),
    );
  }

  ThemeMode _toMaterialMode(ThemeModeChoice m) {
    switch (m) {
      case ThemeModeChoice.light:
        return ThemeMode.light;
      case ThemeModeChoice.dark:
        return ThemeMode.dark;
      case ThemeModeChoice.system:
        return ThemeMode.system;
    }
  }
}
