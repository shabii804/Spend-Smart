import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_gradients.dart';
import '../constants/app_constants.dart';

/// Builds the light + dark Material 3 themes for SpendSmart.
/// Uses bundled Plus Jakarta Sans (no google_fonts dependency).
/// Injects SpendSmartColors ThemeExtension for gradient + semantic tokens.
class AppTheme {
  AppTheme._();

  // ── Shared text theme using local Plus Jakarta Sans ──
  static TextTheme _textTheme(Color main, Color secondary) => TextTheme(
        displayLarge: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 48, fontWeight: FontWeight.w700, color: main, height: 1.1, letterSpacing: -1.0),
        displayMedium: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 40, fontWeight: FontWeight.w700, color: main, height: 1.15, letterSpacing: -0.8),
        titleLarge: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 22, fontWeight: FontWeight.w600, color: main, height: 1.25, letterSpacing: -0.3),
        titleMedium: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, fontWeight: FontWeight.w600, color: main, height: 1.35),
        bodyLarge: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 16, color: main, height: 1.5),
        bodyMedium: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, color: main, height: 1.5),
        bodySmall: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12, color: secondary, height: 1.4),
        labelLarge: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 14, fontWeight: FontWeight.w600, color: main),
        labelSmall: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 11, fontWeight: FontWeight.w500, color: secondary),
      );

  static InputDecorationTheme _inputTheme({
    required Color border,
    required Color bg,
    required Color hint,
  }) => InputDecorationTheme(
        filled: true,
        fillColor: bg,
        hintStyle: TextStyle(color: hint, fontSize: 14, height: 1.5),
        labelStyle: TextStyle(color: hint, fontSize: 14),
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12, height: 1.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusField), borderSide: BorderSide(color: border, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusField), borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 1.6)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusField), borderSide: const BorderSide(color: AppColors.danger, width: 1.2)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusField), borderSide: const BorderSide(color: AppColors.danger, width: 1.4)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusField), borderSide: BorderSide(color: border, width: 1)),
      );

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryIndigo,
          secondary: AppColors.blue,
          surface: AppColors.lightSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.lightTextPrimary,
          error: AppColors.danger,
          onError: Colors.white,
        ),
        extensions: const [SpendSmartColors.light],
        textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
        cardTheme: CardTheme(
          color: AppColors.lightSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            side: BorderSide(color: AppColors.lightBorder, width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: _inputTheme(
          border: AppColors.lightBorder,
          bg: AppColors.lightSurface,
          hint: AppColors.lightTextSecondary,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightSurface,
          selectedColor: AppColors.primaryIndigo.withOpacity(0.12),
          labelStyle: const TextStyle(fontSize: 14, color: AppColors.lightTextPrimary),
          brightness: Brightness.light,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            side: BorderSide(color: AppColors.lightBorder),
          ),
        ),
        dividerTheme: DividerThemeData(color: AppColors.lightDivider, thickness: 1, space: 1),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary, size: 24),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.lightTextPrimary,
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.lightSurface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          elevation: 0,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: const TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          contentTextStyle: const TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.lightTextSecondary, fontSize: 14, height: 1.5),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FadeUpTransitionsBuilder(),
            TargetPlatform.iOS: _FadeUpTransitionsBuilder(),
          },
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryIndigo,
          secondary: AppColors.blue,
          surface: AppColors.darkSurface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
          error: AppColors.danger,
          onError: Colors.white,
        ),
        extensions: const [SpendSmartColors.dark],
        textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
        cardTheme: CardTheme(
          color: AppColors.darkSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            side: BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        inputDecorationTheme: _inputTheme(
          border: AppColors.darkBorder,
          bg: AppColors.darkSurface,
          hint: AppColors.darkTextSecondary,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedColor: AppColors.primaryIndigo.withOpacity(0.18),
          labelStyle: const TextStyle(fontSize: 14, color: AppColors.darkTextPrimary),
          brightness: Brightness.dark,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusChip),
            side: BorderSide(color: AppColors.darkBorder),
          ),
        ),
        dividerTheme: DividerThemeData(color: AppColors.darkDivider, thickness: 1, space: 1),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 24),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkSurfaceElevated,
          contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          elevation: 0,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: const TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          contentTextStyle: const TextStyle(fontFamily: 'PlusJakartaSans', color: AppColors.darkTextSecondary, fontSize: 14, height: 1.5),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FadeUpTransitionsBuilder(),
            TargetPlatform.iOS: _FadeUpTransitionsBuilder(),
          },
        ),
      );
}

/// Premium page transition: fade + slide + scale (250ms, easeOutCubic).
class _FadeUpTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeUpTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondary,
    Widget child,
  ) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curved),
        child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved), alignment: Alignment.topCenter, child: child),
      ),
    );
  }
}
