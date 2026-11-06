import 'package:flutter/material.dart';
import '../motion/app_motion.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// Illustration-style empty state used by transactions + notifications.
/// Now animates in on first appearance: subtle fade + scale-in of the
/// icon medallion, followed by the title and subtitle (staggered).
/// Respects reduce-motion (renders instantly without animation).
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? tint;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tint,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    );
    // Icon medallion: scale 0.7 → 1.0 with easeOutBack (delightful pop)
    _iconScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.7, curve: AppMotion.celebrate)),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.0, 0.5, curve: AppMotion.enter)),
    );
    // Text: fade in + slide up, staggered after icon (starts at 30%)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.3, 1.0, curve: AppMotion.enter)),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _c, curve: const Interval(0.3, 1.0, curve: AppMotion.enter)),
    );
    Future.delayed(Duration.zero, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.tint ?? AppColors.primaryIndigo;
    // Reduce-motion: render static, no animation
    if (AppMotion.reduceMotion(context)) {
      return _buildStatic(c);
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated icon medallion ──
            ScaleTransition(
              scale: _iconScale,
              child: FadeTransition(
                opacity: _iconOpacity,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: c.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(widget.icon, size: 32, color: c),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // ── Staggered title + subtitle ──
            FadeTransition(
              opacity: _textOpacity,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.title, style: TextStyles.h3(context)),
                    const SizedBox(height: 8),
                    Text(
                      widget.subtitle,
                      style: TextStyles.caption(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Static fallback (reduce-motion enabled).
  Widget _buildStatic(Color c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: c.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(widget.icon, size: 32, color: c),
              ),
            ),
            const SizedBox(height: 18),
            Text(widget.title, style: TextStyles.h3(context)),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: TextStyles.caption(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
