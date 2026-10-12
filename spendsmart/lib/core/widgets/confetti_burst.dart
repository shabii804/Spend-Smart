import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Lightweight confetti burst overlay — particles fly out from the center.
/// Show via: ConfettiBurst.show(context);
/// Auto-dismisses after 1.4 seconds.
class ConfettiBurst {
  static Future<void> show(BuildContext context) {
    HapticFeedback.heavyImpact();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => const _ConfettiDialog(),
    );
  }
}

class _ConfettiDialog extends StatefulWidget {
  const _ConfettiDialog();

  @override
  State<_ConfettiDialog> createState() => _ConfettiDialogState();
}

class _ConfettiDialogState extends State<_ConfettiDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;

  static const _colors = [
    AppColors.primaryIndigo,
    AppColors.primaryPurple,
    AppColors.mint,
    AppColors.blue,
    AppColors.warning,
    AppColors.catEntertainment,
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    final rng = Random();
    _particles = List.generate(28, (_) {
      return _Particle(
        angle: rng.nextDouble() * 2 * pi,
        speed: 80 + rng.nextDouble() * 220,
        color: _colors[rng.nextInt(_colors.length)],
        size: 5 + rng.nextDouble() * 7,
        rotation: rng.nextDouble() * 2 * pi,
        rotationSpeed: (rng.nextDouble() - 0.5) * 6,
      );
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          return SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: _particles.map((p) {
                final dist = p.speed * t;
                final dx = cos(p.angle) * dist;
                final dy = sin(p.angle) * dist + (t * t * 80); // gravity
                final opacity = (1 - t).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(dx, dy),
                  child: Transform.rotate(
                    angle: p.rotation + p.rotationSpeed * t * 2 * pi,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: p.size,
                        height: p.size * 1.6,
                        decoration: BoxDecoration(
                          color: p.color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;

  const _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}
