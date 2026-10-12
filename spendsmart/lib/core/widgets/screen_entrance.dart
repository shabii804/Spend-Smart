import 'package:flutter/material.dart';

/// Wraps a screen body with a premium entrance animation: fade-in + slide-up.
/// Use on the body of any pushed screen for a consistent entrance feel.
class ScreenEntrance extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double slideOffset;

  const ScreenEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.slideOffset = 0.04,
  });

  @override
  State<ScreenEntrance> createState() => _ScreenEntranceState();
}

class _ScreenEntranceState extends State<ScreenEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration.zero, () => _c.forward());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

/// Wraps a chart card with a staggered entrance animation.
/// Use for any chart container so it slides in nicely.
class ChartEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const ChartEntrance({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 80),
  });

  @override
  State<ChartEntrance> createState() => _ChartEntranceState();
}

class _ChartEntranceState extends State<ChartEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () => _c.forward());
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}
