import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Standard rounded card used everywhere. Theme-aware surface + border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? customColor;
  final BoxBorder? customBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.customColor,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final color = customColor ?? AppColorsOf.card(context);
    final border = customBorder ??
        Border.all(color: AppColorsOf.border(context), width: 1);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: border,
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightCardShadow
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
