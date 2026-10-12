import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════
// SpendSmart Design System — Color Tokens
// Premium fintech palette: dark, calm, trustworthy.
// Primary gradient reserved for: main CTA, budget hero, progress fills.
// Everything else is neutral so hero elements stand out.
// ═══════════════════════════════════════════════════════════════════

class AppColors {
  AppColors._();

  // ── DARK THEME SURFACES ──
  static const Color darkBackground = Color(0xFF0B0F1A);
  static const Color darkSurface = Color(0xFF121828);
  static const Color darkSurfaceElevated = Color(0xFF1A2236);
  static const Color darkBorder = Color(0x14FFFFFF); // white @ 8%
  static const Color darkDivider = Color(0x0DFFFFFF); // white @ 5%

  // ── LIGHT THEME SURFACES ──
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0x14000000); // black @ 8%
  static const Color lightDivider = Color(0x0D000000); // black @ 5%

  // ── BRAND ──
  static const Color primaryIndigo = Color(0xFF7C6CFF); // gradient start
  static const Color primaryPurple = Color(0xFF9B5CFF); // gradient end
  static const Color blue = Color(0xFF3B82F6);
  static const Color mint = Color(0xFF34D399);
  static const Color cyan = Color(0xFF22D3EE); // accent

  // ── SEMANTIC ──
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);

  // ── DARK TEXT ──
  static const Color darkTextPrimary = Color(0xFFF4F6FB);
  static const Color darkTextSecondary = Color(0xFFA3ACC2);
  static const Color darkTextTertiary = Color(0xFF7C86A0);

  // ── LIGHT TEXT ──
  static const Color lightTextPrimary = Color(0xFF0B0F1A);
  static const Color lightTextSecondary = Color(0xFF525D72);
  static const Color lightTextTertiary = Color(0xFF7C86A0);

  // ── CATEGORY COLORS (unchanged, match sample data) ──
  static const Color catFood = Color(0xFFF97316);
  static const Color catTransport = Color(0xFF3B82F6);
  static const Color catGroceries = Color(0xFF34D399);
  static const Color catEntertainment = Color(0xFFEC4899);
  static const Color catBills = Color(0xFF8B5CF6);
  static const Color catInternet = Color(0xFF22D3EE);
  static const Color catShopping = Color(0xFFF472B6);
  static const Color catOthers = Color(0xFF94A3B8);

  // ── SHADOWS ──
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // ── Backwards compat aliases (old field names → new values) ──
  static const Color lightCard = lightSurface;
  static const Color lightElevated = lightSurfaceElevated;
  static const Color darkCard = darkSurface;
  static const Color darkElevated = darkSurfaceElevated;
  static const Color lightMainText = lightTextPrimary;
  static const Color lightSecondaryText = lightTextSecondary;
  static const Color lightTertiaryText = lightTextTertiary;
  static const Color darkMainText = darkTextPrimary;
  static const Color darkSecondaryText = darkTextSecondary;
  static const Color darkTertiaryText = darkTextTertiary;
  static const List<BoxShadow> lightCardShadow = cardShadow;
}

// ═══════════════════════════════════════════════════════════════════
// ThemeExtension — semantic tokens accessible via Theme.of(context)
// Usage: final sc = Theme.of(context).extension<SpendSmartColors>()!;
// ═══════════════════════════════════════════════════════════════════
class SpendSmartColors extends ThemeExtension<SpendSmartColors> {
  final LinearGradient primaryGradient;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;

  const SpendSmartColors({
    required this.primaryGradient,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
  });

  static const dark = SpendSmartColors(
    primaryGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
    ),
    accent: AppColors.cyan,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
  );

  static const light = SpendSmartColors(
    primaryGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
    ),
    accent: AppColors.cyan,
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.danger,
  );

  @override
  SpendSmartColors copyWith({
    LinearGradient? primaryGradient,
    Color? accent,
    Color? success,
    Color? warning,
    Color? danger,
  }) =>
      SpendSmartColors(
        primaryGradient: primaryGradient ?? this.primaryGradient,
        accent: accent ?? this.accent,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        danger: danger ?? this.danger,
      );

  @override
  SpendSmartColors lerp(SpendSmartColors? other, double t) {
    if (other == null) return this;
    return SpendSmartColors(
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Context-aware helpers (convenience — still backwards compatible)
// ═══════════════════════════════════════════════════════════════════
class AppColorsOf {
  static Brightness brightness(BuildContext c) => Theme.of(c).brightness;
  static bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color background(BuildContext c) =>
      isDark(c) ? AppColors.darkBackground : AppColors.lightBackground;
  static Color surface(BuildContext c) =>
      isDark(c) ? AppColors.darkSurface : AppColors.lightSurface;
  static Color surfaceElevated(BuildContext c) =>
      isDark(c) ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
  static Color card(BuildContext c) => surface(c);
  static Color elevated(BuildContext c) => surfaceElevated(c);
  static Color border(BuildContext c) =>
      isDark(c) ? AppColors.darkBorder : AppColors.lightBorder;
  static Color divider(BuildContext c) =>
      isDark(c) ? AppColors.darkDivider : AppColors.lightDivider;

  static Color mainText(BuildContext c) =>
      isDark(c) ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  static Color secondaryText(BuildContext c) =>
      isDark(c) ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  static Color tertiaryText(BuildContext c) =>
      isDark(c) ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

  static Color shadow(BuildContext c) =>
      isDark(c) ? Colors.transparent : const Color(0x12000000);
}
