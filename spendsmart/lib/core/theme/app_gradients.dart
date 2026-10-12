import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradients used sparingly across the app — FAB, primary CTA, progress fills, chart accents.
class AppGradients {
  AppGradients._();

  /// Indigo → purple (left to right). Primary brand gradient.
  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
  );

  /// Mint → blue. Used for positive accents (savings progress, success CTAs).
  static const Gradient positive = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.mint, AppColors.blue],
  );

  /// Cyan → blue → indigo. FAB signature gradient.
  static const Gradient fab = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
  );

  /// Splash hero gradient (indigo → purple).
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
  );

  /// Used for progress-bar fills when goal/budget progress is positive.
  static const Gradient progress = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
  );

  /// Hero card subtle wash (for dashboard main card).
  static LinearGradient heroCard(BuildContext context) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryIndigo,
          AppColors.primaryPurple,
        ],
      );
}
