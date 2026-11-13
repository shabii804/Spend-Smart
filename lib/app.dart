import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'providers/theme_provider.dart';

/// Wide-screen layout: phones fill the viewport as usual, but on desktop /
/// laptop browsers the whole app is clamped to a phone-width column, centred
/// with hairline side borders. Without this every screen stretched edge to
/// edge on large monitors — summary cards, lists and buttons all became
/// unusably wide (reported as "no proper alignment").
const double _kMaxAppWidth = 480.0;

/// Root widget. Rebuilds when ThemeProvider / CurrencyProvider change.
class SpendSmartApp extends StatelessWidget {
  const SpendSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'SpendSmart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _toMaterialMode(theme.mode),
      home: const SplashScreen(),
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        final size = MediaQuery.sizeOf(context);
        // Phone / small tablet — keep the natural full-width layout.
        if (size.width <= _kMaxAppWidth) return child;

        // Desktop — frame the app in a centred phone-width column and feed
        // the child routes a matching MediaQuery so every screen (Scaffold,
        // dialogs, snackbars, FABs) lays out at that width instead of
        // stretching across the monitor.
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: Container(
              width: _kMaxAppWidth,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Theme.of(context).dividerColor),
                  right: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(_kMaxAppWidth, size.height),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
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
