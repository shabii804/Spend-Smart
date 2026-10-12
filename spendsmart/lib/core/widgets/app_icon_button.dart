import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Premium icon button with guaranteed 48x48 touch target + Semantics label.
/// Used everywhere icon-only buttons appear (back, edit, delete, bell, etc.).
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final Color? color;
  final double iconSize;
  final double? size;
  final Color? bg;
  final Color? borderColor;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.color,
    this.iconSize = 22,
    this.size,
    this.bg,
    this.borderColor,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
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
    final touchSize = widget.size ?? 48.0;
    final iconColor = widget.color ?? AppColorsOf.mainText(context);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: GestureDetector(
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
            final scale = 1.0 - (_press.value * 0.05);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: touchSize,
            height: touchSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.bg ?? Colors.transparent,
              shape: BoxShape.circle,
              border: widget.borderColor != null
                  ? Border.all(color: widget.borderColor!, width: 1)
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: enabled ? iconColor : iconColor.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}
