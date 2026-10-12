import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Standard rounded card used everywhere. Theme-aware surface + border.
/// Now includes premium press-scale feedback (2% scale-down on tap).
class GlassCard extends StatefulWidget {
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
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.customColor ?? AppColorsOf.card(context);
    final border = widget.customBorder ??
        Border.all(color: AppColorsOf.border(context), width: 1);
    return AnimatedBuilder(
      animation: _press,
      builder: (context, child) {
        final scale = 1.0 - (_press.value * 0.02);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: widget.margin,
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
            onTap: widget.onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    widget.onTap!();
                  },
            onTapDown: widget.onTap == null
                ? null
                : (_) => _press.forward(),
            onTapUp: widget.onTap == null
                ? null
                : (_) => _press.reverse(),
            onTapCancel: widget.onTap == null
                ? null
                : () => _press.reverse(),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
