import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/text_styles.dart';
import '../constants/app_constants.dart';

/// Primary CTA button. Indigo→blue gradient fill, white label, 16px radius.
/// Premium press animation: scale-down + spring back, smooth loading fade.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  void _onTapDown() {
    if (widget.onPressed != null && !widget.loading) {
      _press.forward();
    }
  }

  void _onTapUp() {
    _press.reverse();
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapUp(),
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            }
          : null,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          // Scale down to 0.96 when pressed, spring back to 1.0
          final scale = 1.0 - (_press.value * 0.04);
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 52),
          width: widget.expand ? double.infinity : null,
          decoration: BoxDecoration(
            gradient: enabled
                ? AppGradients.primaryButton
                : LinearGradient(
                    colors: [
                      AppColors.primaryIndigo.withOpacity(0.4),
                      AppColors.primaryPurple.withOpacity(0.4),
                    ],
                  ),
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.primaryIndigo.withOpacity(0.32),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Label fades out when loading
              AnimatedOpacity(
                opacity: widget.loading ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 180),
                child: Row(
                  mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyles.body(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Spinner fades in when loading (overlays the label)
              AnimatedOpacity(
                opacity: widget.loading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
