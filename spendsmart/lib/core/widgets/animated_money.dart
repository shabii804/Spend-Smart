import 'package:flutter/material.dart';
import '../utils/formatters.dart';

/// Animated money value that counts up/down when the amount changes.
/// Usage: AnimatedMoney(amount: totalSpent, context: context)
/// Used on dashboard budget hero + summary cards for premium polish.
class AnimatedMoney extends StatefulWidget {
  final double amount;
  final TextStyle? style;
  final int durationMs;

  const AnimatedMoney({
    super.key,
    required this.amount,
    required this.style,
    this.durationMs = 600,
  });

  @override
  State<AnimatedMoney> createState() => _AnimatedMoneyState();
}

class _AnimatedMoneyState extends State<AnimatedMoney>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late Animation<double> _animation;
  double _previous = 0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    _animation = Tween<double>(begin: 0, end: widget.amount).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
    )..addListener(() => setState(() {}));
    _c.forward();
    _previous = widget.amount;
  }

  @override
  void didUpdateWidget(covariant AnimatedMoney oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _animation = Tween<double>(begin: _previous, end: widget.amount).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
      )..addListener(() => setState(() {}));
      _c.duration = Duration(milliseconds: widget.durationMs);
      _c
        ..reset()
        ..forward();
      _previous = widget.amount;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      Formatters.money(_animation.value),
      style: widget.style,
    );
  }
}
