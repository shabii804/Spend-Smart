import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// Centralized motion design tokens for SpendSmart.
/// Use ONLY these — no magic numbers in screens.
///
/// Calm, smooth, trustworthy, a little delightful.
/// Never flashy, never slow, never blocking.
class AppMotion {
  AppMotion._();

  // ── Durations ──
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration hero = Duration(milliseconds: 800);
  static const Duration splashMax = Duration(milliseconds: 2200);
  static const Duration splashMin = Duration(milliseconds: 1200);

  // ── Curves ──
  static const Curve standard = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutQuart;
  static const Curve exit = Curves.easeInCubic;
  static const Curve celebrate = Curves.easeOutBack;

  /// Gentle spring (damping ratio ~0.8, no big overshoot).
  static SpringDescription get spring => const SpringDescription(
        mass: 1.0,
        stiffness: 200.0,
        damping: 20.0,
      );

  /// Build a SpringSimulation from `from` to `to`.
  static SpringSimulation springSim(double from, double to) {
    return SpringSimulation(spring, from, to, (to - from) * 0.5);
  }

  // ── Stagger ──
  static const int maxStaggeredItems = 8;
  static const Duration staggerStep = Duration(milliseconds: 40);

  /// Returns the delay for item [index] in a staggered entrance.
  /// Items beyond [maxStaggeredItems] get zero delay (appear instantly).
  static Duration staggerDelay(int index) {
    if (index >= maxStaggeredItems) return Duration.zero;
    return Duration(milliseconds: index * staggerStep.inMilliseconds);
  }

  // ── Press feedback ──
  static const double pressScale = 0.97;
  static const Duration pressDuration = Duration(milliseconds: 80);

  // ── Reduce motion ──
  /// Check if the user has reduce-motion enabled.
  /// If true: replace movement/scale with 150ms fade, skip confetti/shake/parallax/looping.
  static bool reduceMotion(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
  }

  /// Returns the effective duration: if reduce-motion, cap at 150ms.
  static Duration effective(BuildContext context, Duration duration) {
    if (reduceMotion(context)) return fast;
    return duration;
  }

  /// Returns the effective curve: if reduce-motion, use standard (no overshoot).
  static Curve effectiveCurve(BuildContext context, Curve curve) {
    if (reduceMotion(context)) return standard;
    return curve;
  }
}

/// Convenience extension on BuildContext for motion checks.
extension MotionContext on BuildContext {
  bool get reduceMotion => AppMotion.reduceMotion(this);
}
