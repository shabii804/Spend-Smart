import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_motion.dart';
import 'haptics.dart';

/// Wraps any widget with press-scale feedback (0.97 on press, spring back).
/// Uses AnimatedBuilder for 60fps — no setState in animation listeners.
/// Respects reduce-motion (skips scale, just does tap).
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double scale;
  final bool haptic;

  const Pressable({
    super.key,
    required this.child,
    this.onPressed,
    this.scale = AppMotion.pressScale,
    this.haptic = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: AppMotion.pressDuration,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: widget.scale)
        .animate(CurvedAnimation(parent: _c, curve: AppMotion.standard));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = AppMotion.reduceMotion(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: reduce ? null : (_) => _c.forward(),
      onTapUp: reduce ? null : (_) => _c.reverse(),
      onTapCancel: reduce ? null : () => _c.reverse(),
      onTap: () {
        if (widget.haptic) Haptics.light();
        widget.onPressed?.call();
      },
      child: reduce
          ? widget.child
          : AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                return Transform.scale(scale: _scaleAnim.value, child: child);
              },
              child: widget.child,
            ),
    );
  }
}

/// Horizontal shake for validation errors (3 oscillations, 6px, 300ms).
/// Respects reduce-motion (skips shake, does 150ms fade instead).
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const ShakeWidget({super.key, required this.child, this.onComplete});

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void shake() {
    if (AppMotion.reduceMotion(context)) {
      widget.onComplete?.call();
      return;
    }
    Haptics.error();
    _c.forward(from: 0).then((_) => widget.onComplete?.call());
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotion(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // 3 oscillations: sin curve * 3 * 2π → amplitude 6px
        final offset = math.sin(_c.value * 3 * math.pi * 2) * 6;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Checkmark drawn with CustomPainter path animation.
/// Path draws over [duration] (default 250ms), with easeOutCubic.
class DrawnCheckmark extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final VoidCallback? onComplete;

  const DrawnCheckmark({
    super.key,
    this.size = 28,
    this.color = Colors.white,
    this.duration = const Duration(milliseconds: 250),
    this.onComplete,
  });

  @override
  State<DrawnCheckmark> createState() => DrawnCheckmarkState();
}

class DrawnCheckmarkState extends State<DrawnCheckmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _progress = CurvedAnimation(parent: _c, curve: AppMotion.standard);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void play() {
    _c.forward(from: 0).then((_) => widget.onComplete?.call());
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CheckPainter(_progress.value, widget.color),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  _CheckPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p = Path()
      ..moveTo(size.width * 0.25, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.68)
      ..lineTo(size.width * 0.75, size.height * 0.35);

    final pathMetrics = p.computeMetrics();
    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}

/// Count-up text for money values (0 → target over [duration]).
/// Uses tabularFigures so digits align during count.
class CountUpText extends StatefulWidget {
  final double target;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;
  final bool compact;

  const CountUpText({
    super.key,
    required this.target,
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.prefix = '',
    this.suffix = '',
    this.compact = false,
  });

  @override
  State<CountUpText> createState() => _CountUpTextState();
}

class _CountUpTextState extends State<CountUpText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _anim = Tween<double>(begin: 0, end: widget.target)
        .animate(CurvedAnimation(parent: _c, curve: AppMotion.standard));
    _c.forward();
  }

  @override
  void didUpdateWidget(CountUpText old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _anim = Tween<double>(begin: _anim.value, end: widget.target)
          .animate(CurvedAnimation(parent: _c, curve: AppMotion.standard));
      _c
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dur = AppMotion.effective(context, widget.duration);
    if (dur != widget.duration) {
      // Reduce-motion: show final value immediately
      return Text('${widget.prefix}${_format(widget.target)}${widget.suffix}',
          style: widget.style);
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Text(
          '${widget.prefix}${_format(_anim.value)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }

  String _format(double v) {
    if (widget.compact) {
      if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
      if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    }
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
  }
}

/// Skeleton shimmer placeholder — soft diagonal highlight sweeping every 1400ms.
/// Base color = surface-elevated. Matches final layout sizes/radii.
class ShimmerSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 12,
    this.radius = 8,
  });

  @override
  State<ShimmerSkeleton> createState() => _ShimmerSkeletonState();
}

class _ShimmerSkeletonState extends State<ShimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotion(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF1A2236),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF1A2236),
                Color(0x12FFFFFF), // white @ 6%
                Color(0xFF1A2236),
              ],
              stops: [0.0, _c.value, 1.0],
            ).createShader(rect);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        );
      },
    );
  }
}
