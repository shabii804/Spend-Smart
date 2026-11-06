import 'package:flutter/material.dart';
import 'app_motion.dart';

/// Smooth fade & opacity page transition builder for SpendSmart.
///
/// Features:
/// - Silky smooth fade in/out with [Curves.easeOutCubic].
/// - Gentle subtle scale (0.985 -> 1.0) for tactile depth without abrupt jumps.
/// - Secondary animation handles the underlying page gracefully (fades to 0.92
///   and gently settles, preventing harsh pops).
/// - Automatically respects reduce-motion settings (pure fast fade).
class SmoothFadePageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothFadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return buildSmoothFadeTransition(
      context: context,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }

  /// Reusable transition widget builder for fade and subtle depth.
  static Widget buildSmoothFadeTransition({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final reduceMotion = AppMotion.reduceMotion(context);

    if (reduceMotion) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }

    final enterCurved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final exitCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([enterCurved, exitCurved]),
      builder: (context, _) {
        // Entering page: fade from 0 to 1, scale from 0.985 to 1.0
        final inOpacity = enterCurved.value.clamp(0.0, 1.0);
        final inScale = 0.985 + (0.015 * enterCurved.value);

        // Underneath page (when a new route is pushed on top):
        // gently scale down slightly (1.0 -> 0.98) and dim to 0.94
        final outOpacity = 1.0 - (0.06 * exitCurved.value);
        final outScale = 1.0 - (0.015 * exitCurved.value);

        return Opacity(
          opacity: (inOpacity * outOpacity).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: inScale * outScale,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }
}

/// Standalone [PageRouteBuilder] configured with the smooth fade-opacity transition.
class SmoothFadePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  SmoothFadePageRoute({
    required this.builder,
    super.settings,
    super.maintainState = true,
  }) : super(
          pageBuilder: (context, anim, secAnim) => builder(context),
          transitionDuration: const Duration(milliseconds: 320),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SmoothFadePageTransitionsBuilder.buildSmoothFadeTransition(
              context: context,
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}

/// Helper navigation extensions for pushing routes with smooth fade opacity.
extension SmoothNavigationExtension on BuildContext {
  /// Push a screen with a smooth fade & opacity transition.
  Future<T?> pushSmooth<T>(Widget page) {
    return Navigator.of(this).push<T>(
      SmoothFadePageRoute<T>(builder: (_) => page),
    );
  }

  /// Replace the current screen with a smooth fade & opacity transition.
  Future<T?> pushReplacementSmooth<T, TO>(Widget page, {TO? result}) {
    return Navigator.of(this).pushReplacement<T, TO>(
      SmoothFadePageRoute<T>(builder: (_) => page),
      result: result,
    );
  }
}
