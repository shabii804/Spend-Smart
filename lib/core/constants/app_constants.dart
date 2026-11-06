import 'package:flutter/animation.dart';

/// App-wide spacing, radius and timing constants.
/// Used by every widget so spacing never drifts.
class AppConstants {
  AppConstants._();

  // Spacing scale
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;

  // Horizontal screen padding
  static const double screenPaddingH = 20;

  // Radius
  static const double radiusCard = 20;
  static const double radiusButton = 16;
  static const double radiusChip = 12;
  static const double radiusField = 16;
  static const double radiusSmall = 12;
  static const double radiusPill = 999;

  // Animation
  static const Duration durFast = Duration(milliseconds: 200);
  static const Duration durMed = Duration(milliseconds: 280);
  static const Duration durSlow = Duration(milliseconds: 380);
  static const Curve curveDefault = Curves.easeOutCubic;

  // SharedPreferences keys
  static const String keyFirstLaunch = 'spendsmart.first_launch';
  static const String keyThemeMode = 'spendsmart.theme_mode';
  static const String keyCurrency = 'spendsmart.currency';
  static const String keyNotifBudget = 'spendsmart.notif.budget';
  static const String keyNotifLowBalance = 'spendsmart.notif.low_balance';
  static const String keyNotifGoals = 'spendsmart.notif.goals';

  // FAB / nav
  static const double fabSize = 58;
  static const double navBarHeight = 64;
  static const double navBarBottomMargin = 16;
}
