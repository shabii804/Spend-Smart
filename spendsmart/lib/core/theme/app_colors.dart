import 'package:flutter/material.dart';

/// Central color tokens for the SpendSmart design system.
/// All UI colors must be sourced from here — never hardcode hex values in widgets.
class AppColors {
  AppColors._();

  // ---------- LIGHT THEME ----------
  static const Color lightBackground = Color(0xFFF8FAFC); // slate-50
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB); // slate-200
  static const Color lightDivider = Color(0xFFEFF2F6);

  // ---------- DARK THEME ----------
  static const Color darkBackground = Color(0xFF0F172A); // slate-900
  static const Color darkCard = Color(0xFF1E293B); // slate-800
  static const Color darkElevated = Color(0xFF273449); // slate-700/ish
  static const Color darkBorder = Color(0x14FFFFFF); // white @ 8%
  static const Color darkDivider = Color(0x1AFFFFFF); // white @ 10%

  // ---------- BRAND ----------
  static const Color primaryIndigo = Color(0xFF6366F1); // indigo-500
  static const Color primaryPurple = Color(0xFF8B5CF6); // violet-500
  static const Color blue = Color(0xFF3B82F6); // blue-500 (legacy name kept)
  static const Color mint = Color(0xFF10B981); // emerald-500
  static const Color cyan = Color(0xFF22D3EE); // cyan-400 — chart accent

  // ---------- TEXT (LIGHT) ----------
  static const Color lightMainText = Color(0xFF0F172A); // slate-900
  static const Color lightSecondaryText = Color(0xFF64748B); // slate-500
  static const Color lightTertiaryText = Color(0xFF94A3B8); // slate-400

  // ---------- TEXT (DARK) ----------
  static const Color darkMainText = Color(0xFFF1F5F9); // slate-100
  static const Color darkSecondaryText = Color(0xFF94A3B8); // slate-400
  static const Color darkTertiaryText = Color(0xFF64748B); // slate-500

  // ---------- SEMANTICS ----------
  static const Color success = Color(0xFF10B981); // emerald-500
  static const Color warning = Color(0xFFFFA726);
  static const Color danger = Color(0xFFEF4444); // red-500
  static const Color info = Color(0xFF3B82F6);

  // ---------- CATEGORY COLORS (matches sample data) ----------
  static const Color catFood = Color(0xFFF97316); // orange-500
  static const Color catTransport = Color(0xFF3B82F6); // blue-500
  static const Color catGroceries = Color(0xFF10B981); // emerald-500
  static const Color catEntertainment = Color(0xFFEC4899); // pink-500
  static const Color catBills = Color(0xFF8B5CF6); // violet-500
  static const Color catInternet = Color(0xFF22D3EE); // cyan-400
  static const Color catShopping = Color(0xFFF472B6); // pink-400
  static const Color catOthers = Color(0xFF94A3B8); // slate-400

  // ---------- SHADOWS ----------
  static const List<BoxShadow> lightCardShadow = [
    BoxShadow(
      color: Color(0x1A14213D),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> fabGlow = [
    BoxShadow(
      color: Color(0x40635BFF),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
}

/// Theme-aware helpers: pass `BuildContext` and get the right token.
class AppColorsOf {
  static Color background(BuildContext c) =>
      Theme.of(c).brightness == Brightness.light
          ? AppColors.lightBackground
          : AppColors.darkBackground;

  static Color card(BuildContext c) => Theme.of(c).brightness == Brightness.light
      ? AppColors.lightCard
      : AppColors.darkCard;

  static Color elevated(BuildContext c) =>
      Theme.of(c).brightness == Brightness.light
          ? AppColors.lightElevated
          : AppColors.darkElevated;

  static Color border(BuildContext c) => Theme.of(c).brightness == Brightness.light
      ? AppColors.lightBorder
      : AppColors.darkBorder;

  static Color divider(BuildContext c) =>
      Theme.of(c).brightness == Brightness.light
          ? AppColors.lightDivider
          : AppColors.darkDivider;

  static Color mainText(BuildContext c) =>
      Theme.of(c).brightness == Brightness.light
          ? AppColors.lightMainText
          : AppColors.darkMainText;

  static Color secondaryText(BuildContext c) =>
      Theme.of(c).brightness == Brightness.light
          ? AppColors.lightSecondaryText
          : AppColors.darkSecondaryText;

  static Color tertiaryText(BuildContext c) =>
      Theme.of(c).brightness == Brightness.light
          ? AppColors.lightTertiaryText
          : AppColors.darkTertiaryText;

  static Color shadow(BuildContext c) => Theme.of(c).brightness == Brightness.light
      ? const Color(0x1A14213D)
      : Colors.transparent;
}
