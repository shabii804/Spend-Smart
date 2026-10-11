import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/text_styles.dart';
import '../constants/app_constants.dart';

/// Primary CTA button. Indigo→blue gradient fill, white label, 16px radius.
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
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final scale = 1.0 - (_c.value * 0.03);
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  widget.onPressed!();
                }
              : null,
          child: Ink(
            decoration: BoxDecoration(
              gradient: enabled
                  ? AppGradients.primaryButton
                  : LinearGradient(
                      colors: [
                        AppColors.primaryIndigo.withOpacity(0.4),
                        AppColors.blue.withOpacity(0.4),
                      ],
                    ),
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primaryIndigo.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              constraints: const BoxConstraints(minHeight: 52),
              width: widget.expand ? double.infinity : null,
              child: widget.loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Row(
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
          ),
        ),
      ),
    );
  }
}
