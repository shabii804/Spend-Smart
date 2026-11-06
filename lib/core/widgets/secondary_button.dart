import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// Outlined secondary button — neutral, same height as PrimaryButton.
/// Used for: Cancel, Back to Login, secondary CTAs.
class SecondaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expand = true,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
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
    final enabled = widget.onPressed != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) { if (enabled) _press.forward(); },
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      onTap: enabled
          ? () { HapticFeedback.lightImpact(); widget.onPressed!(); }
          : null,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          final scale = 1.0 - (_press.value * 0.03);
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          width: widget.expand ? double.infinity : null,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            border: Border.all(
              color: enabled
                  ? AppColorsOf.border(context)
                  : AppColorsOf.border(context).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: AppColorsOf.mainText(context)),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColorsOf.mainText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
