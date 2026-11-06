import 'package:flutter/services.dart';

/// Centralized haptic feedback. Can be globally disabled.
/// Usage: Haptics.light() / Haptics.success() / Haptics.error()
class Haptics {
  Haptics._();

  /// Set to false to disable all haptics (e.g., in settings).
  static bool enabled = true;

  /// Light tap — primary actions, tab changes, chip selections.
  static void light() {
    if (!enabled) return;
    HapticFeedback.lightImpact();
  }

  /// Medium — success animations, goal milestones.
  static void success() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy — confetti, major celebrations.
  static void heavy() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection click — tab switches, toggles.
  static void selection() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
  }

  /// Error — validation failures, shake animations.
  static void error() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 60), () {
      if (enabled) HapticFeedback.lightImpact();
    });
  }
}
