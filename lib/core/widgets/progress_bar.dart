import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../constants/app_constants.dart';

/// Animated progress bar with optional gradient fill.
class ProgressBar extends StatelessWidget {
  final double percent; // 0..1+
  final Gradient? gradient;
  final Color? trackColor;
  final double height;
  final BorderRadius? radius;

  const ProgressBar({
    super.key,
    required this.percent,
    this.gradient,
    this.trackColor,
    this.height = 8,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(
            height: height,
            color: trackColor ??
                AppColors.primaryIndigo.withOpacity(0.12),
          ),
          AnimatedContainer(
            duration: AppConstants.durMed,
            curve: AppConstants.curveDefault,
            height: height,
            width: clamped *
                (MediaQuery.sizeOf(context).width), // will be clipped below
            decoration: BoxDecoration(
              gradient: gradient ?? AppGradients.progress,
            ),
          ),
        ],
      ),
    );
  }
}

/// A FractionallySized progress bar that respects parent width.
class ProgressBarFraction extends StatelessWidget {
  final double percent; // 0..1+
  final Gradient? gradient;
  final Color? trackColor;
  final double height;
  final BorderRadius? radius;

  const ProgressBarFraction({
    super.key,
    required this.percent,
    this.gradient,
    this.trackColor,
    this.height = 8,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: radius ?? BorderRadius.circular(height),
          child: Stack(
            children: [
              Container(
                height: height,
                width: constraints.maxWidth,
                color: trackColor ??
                    AppColors.primaryIndigo.withOpacity(0.12),
              ),
              AnimatedContainer(
                duration: AppConstants.durMed,
                curve: AppConstants.curveDefault,
                height: height,
                width: constraints.maxWidth * clamped,
                decoration: BoxDecoration(
                  gradient: gradient ?? AppGradients.progress,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
