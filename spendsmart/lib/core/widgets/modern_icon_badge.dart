import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Next-level modern icon badge with squircle container, vibrant multi-stop
/// gradient, glowing shadow, subtle border, and optional spring tap animation.
class ModernIconBadge extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double borderRadius;
  final bool showGlow;
  final bool animateOnTap;
  final VoidCallback? onTap;

  const ModernIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 44,
    this.iconSize = 22,
    this.borderRadius = 14,
    this.showGlow = true,
    this.animateOnTap = true,
    this.onTap,
  });

  @override
  State<ModernIconBadge> createState() => _ModernIconBadgeState();
}

class _ModernIconBadgeState extends State<ModernIconBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.animateOnTap) _controller.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.animateOnTap) _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.animateOnTap) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget badge = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.withOpacity(isDark ? 0.32 : 0.22),
            c.withOpacity(isDark ? 0.12 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: c.withOpacity(isDark ? 0.45 : 0.35),
          width: 1.2,
        ),
        boxShadow: widget.showGlow
            ? [
                BoxShadow(
                  color: c.withOpacity(isDark ? 0.30 : 0.20),
                  blurRadius: widget.size * 0.35,
                  offset: Offset(0, widget.size * 0.12),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        widget.icon,
        color: c,
        size: widget.iconSize,
      ),
    );

    if (widget.onTap != null || widget.animateOnTap) {
      badge = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(
            scale: _scale.value,
            child: child,
          ),
          child: badge,
        ),
      );
    }

    return badge;
  }
}
