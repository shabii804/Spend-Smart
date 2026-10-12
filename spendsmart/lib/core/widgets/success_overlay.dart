import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Premium success overlay with an animated checkmark, glow halo,
/// and multiple expanding rings. Plays an iOS-style haptic pattern
/// (light → medium → heavy in quick succession).
///
/// Usage:
///   await SuccessOverlay.show(context, label: 'Expense Added');
/// Then call Navigator.maybePop() after the await completes.
class SuccessOverlay {
  static Future<void> show(
    BuildContext context, {
    String label = 'Success',
    IconData icon = Icons.check_rounded,
  }) async {
    // iOS-style success haptic pattern: light → medium → heavy
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    await HapticFeedback.heavyImpact();
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.34),
      builder: (_) => _SuccessDialog(label: label, icon: icon),
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  final String label;
  final IconData icon;
  const _SuccessDialog({required this.label, required this.icon});

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with TickerProviderStateMixin {
  late final AnimationController _scale;
  late final AnimationController _ring1;
  late final AnimationController _ring2;
  late final AnimationController _ring3;
  late final AnimationController _fade;
  late final AnimationController _checkDraw;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _ring1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ring2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _ring3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1.0,
    );
    _checkDraw = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scale.forward();
    Future.delayed(const Duration(milliseconds: 60), () => _ring1.forward());
    Future.delayed(const Duration(milliseconds: 180), () => _ring2.forward());
    Future.delayed(const Duration(milliseconds: 320), () => _ring3.forward());
    Future.delayed(const Duration(milliseconds: 280), () => _checkDraw.forward());
    Future.delayed(const Duration(milliseconds: 900), () {
      _fade.reverse();
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 280), () {
          if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
        });
      }
    });
  }

  @override
  void dispose() {
    _scale.dispose();
    _ring1.dispose();
    _ring2.dispose();
    _ring3.dispose();
    _fade.dispose();
    _checkDraw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _scale,
            curve: Curves.elasticOut,
          ),
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow halo (always visible)
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.mint.withOpacity(0.32),
                        AppColors.mint.withOpacity(0.0),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                // Ring 1 — outermost expanding ring
                _ExpandingRing(animation: _ring1, maxRadius: 70, color: AppColors.mint),
                // Ring 2 — middle ring (delayed)
                _ExpandingRing(animation: _ring2, maxRadius: 55, color: AppColors.mint),
                // Ring 3 — innermost (latest)
                _ExpandingRing(animation: _ring3, maxRadius: 40, color: AppColors.mint),
                // Inner gradient circle with the checkmark
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.mint, AppColors.blue],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mint.withOpacity(0.5),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _checkDraw,
                      curve: Curves.elasticOut,
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandingRing extends StatelessWidget {
  final Animation<double> animation;
  final double maxRadius;
  final Color color;
  const _ExpandingRing({
    required this.animation,
    required this.maxRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Container(
            width: 70 + (t * maxRadius * 2),
            height: 70 + (t * maxRadius * 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.7 * (1 - t)),
                width: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}
