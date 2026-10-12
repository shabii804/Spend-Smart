import 'package:flutter/animation.dart';

/// Centralized motion design tokens for SpendSmart.
/// All durations, curves, and stagger patterns live here.
class Motion {
  Motion._();

  // Durations
  static const Duration durSplashBg = Duration(milliseconds: 600);
  static const Duration durLogoEntry = Duration(milliseconds: 800);
  static const Duration durLogoSpring = Duration(milliseconds: 1200);
  static const Duration durTextStagger = Duration(milliseconds: 400);
  static const Duration durFieldEntrance = Duration(milliseconds: 500);
  static const Duration durButtonMorph = Duration(milliseconds: 300);
  static const Duration durSuccessRing = Duration(milliseconds: 900);
  static const Duration durErrorShake = Duration(milliseconds: 400);
  static const Duration durPageRoute = Duration(milliseconds: 350);

  // Curves
  static const Curve springOut = Curves.elasticOut;
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve springBack = Curves.easeOutBack;
  static const Curve decel = Curves.decelerate;

  // Stagger intervals (for IndexedAnimation)
  static double interval(double start, double length) =>
      (start).clamp(0.0, 1.0);
  static double intervalEnd(double start, double length) =>
      (start + length).clamp(0.0, 1.0);
}

/// Pre-baked stagger start points for N-item lists.
class Stagger {
  Stagger._();
  static const double step = 0.06; // 60ms apart for 1000ms total
  static double at(int index) => (index * step).clamp(0.0, 0.7);
  static const double duration = 0.3; // each item animates over 300ms
}
