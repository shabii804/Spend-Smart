import 'package:flutter/material.dart';

/// Wraps a list of children with staggered fade+slide entrance animation.
/// Each item appears 60ms after the previous one, with a fade + 8px slide up.
class StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  final int baseDelayMs;
  final int stepDelayMs;

  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
    this.baseDelayMs = 40,
    this.stepDelayMs = 55,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    final start = (widget.baseDelayMs + widget.index * widget.stepDelayMs) / 1000;
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _c,
        curve: Interval(start.clamp(0.0, 0.85), 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _c,
        curve: Interval(start.clamp(0.0, 0.85), 1.0, curve: Curves.easeOutCubic),
      ),
    );
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
