import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds the light + dark Material 3 themes for SpendSmart.
/// All widget defaults (Card, AppBar, Chip, InputDecoration, etc.) are tuned here
/// so screens can stay declarative and never override raw colors.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _base(Brightness.light).copyWith(
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primaryIndigo,
          secondary: AppColors.blue,
          surface: AppColors.lightCard,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.lightMainText,
          error: AppColors.danger,
          onError: Colors.white,
        ),
        cardTheme: CardTheme(
          color: AppColors.lightCard,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.lightBorder, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightMainText,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.lightMainText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: _inputDecoration(
          border: AppColors.lightBorder,
          bg: AppColors.lightCard,
          text: AppColors.lightMainText,
          hint: AppColors.lightSecondaryText,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightCard,
          selectedColor: AppColors.primaryIndigo.withOpacity(0.12),
          labelStyle: const TextStyle(fontSize: 14, color: AppColors.lightMainText),
          secondaryLabelStyle: const TextStyle(fontSize: 14, color: AppColors.lightMainText),
          brightness: Brightness.light,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.lightBorder),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.lightDivider,
          thickness: 1,
          space: 1,
        ),
        iconTheme: const IconThemeData(color: AppColors.lightMainText, size: 24),
      );

  static ThemeData dark() => _base(Brightness.dark).copyWith(
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryIndigo,
          secondary: AppColors.blue,
          surface: AppColors.darkCard,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.darkMainText,
          error: AppColors.danger,
          onError: Colors.white,
        ),
        cardTheme: CardTheme(
          color: AppColors.darkCard,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkMainText,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: _inputDecoration(
          border: AppColors.darkBorder,
          bg: AppColors.darkCard,
          text: AppColors.darkMainText,
          hint: AppColors.darkSecondaryText,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkCard,
          selectedColor: AppColors.primaryIndigo.withOpacity(0.18),
          labelStyle: const TextStyle(fontSize: 14, color: AppColors.darkMainText),
          secondaryLabelStyle: const TextStyle(fontSize: 14, color: AppColors.darkMainText),
          brightness: Brightness.dark,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.darkBorder),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.darkDivider,
          thickness: 1,
          space: 1,
        ),
        iconTheme: const IconThemeData(color: AppColors.darkMainText, size: 24),
      );

  static ThemeData _base(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final mainText = isLight ? AppColors.lightMainText : AppColors.darkMainText;
    final secondary =
        isLight ? AppColors.lightSecondaryText : AppColors.darkSecondaryText;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        titleLarge: TextStyle(
          color: mainText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: mainText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: mainText, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: mainText, fontSize: 14, height: 1.5),
        bodySmall: TextStyle(color: secondary, fontSize: 12, height: 1.4),
      ),
      primaryTextTheme: GoogleFonts.plusJakartaSansTextTheme(),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeUpTransitionsBuilder(),
          TargetPlatform.iOS: _FadeUpTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? AppColors.lightMainText : AppColors.darkElevated,
        contentTextStyle: TextStyle(
          color: isLight ? Colors.white : AppColors.darkMainText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryIndigo,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryIndigo,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: AppColors.primaryIndigo, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? AppColors.lightCard : AppColors.darkCard,
        modalBackgroundColor: isLight ? AppColors.lightCard : AppColors.darkCard,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 0,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isLight ? AppColors.lightCard : AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: mainText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(color: secondary, fontSize: 14, height: 1.5),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primaryIndigo,
        inactiveTrackColor: AppColors.primaryIndigo.withOpacity(0.15),
        thumbColor: AppColors.primaryIndigo,
        overlayColor: AppColors.primaryIndigo.withOpacity(0.12),
        trackHeight: 6,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return Colors.white;
          return isLight ? AppColors.lightSecondaryText : AppColors.darkSecondaryText;
        }),
        trackColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return AppColors.primaryIndigo;
          return isLight ? AppColors.lightBorder : AppColors.darkBorder;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryIndigo,
        linearTrackColor: AppColors.primaryIndigo,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return AppColors.primaryIndigo;
          return Colors.transparent;
        }),
        side: BorderSide(color: secondary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.selected)) return AppColors.primaryIndigo;
          return secondary;
        }),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primaryIndigo,
        unselectedLabelColor: secondary,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primaryIndigo, width: 2.5),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightMainText : AppColors.darkElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: isLight ? Colors.white : AppColors.darkMainText,
          fontSize: 12,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecoration({
    required Color border,
    required Color bg,
    required Color text,
    required Color hint,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: bg,
      hintStyle: TextStyle(color: hint, fontSize: 14, height: 1.5),
      labelStyle: TextStyle(color: hint, fontSize: 14),
      errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12, height: 1.4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border, width: 1),
      ),
    );
  }
}

/// Premium page transition: subtle slide-up + fade + scale.
/// Used by all pushed MaterialPageRoute (Android + iOS).
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
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    );
  }
}
