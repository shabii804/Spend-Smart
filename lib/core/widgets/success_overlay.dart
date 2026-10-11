import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Premium success overlay with an animated checkmark + haptic feedback.
/// Usage:
///   await SuccessOverlay.show(context, label: 'Expense Added');
/// Then call Navigator.maybePop() after the await completes.
class SuccessOverlay {
  static Future<void> show(
    BuildContext context, {
    String label = 'Success',
    IconData icon = Icons.check_rounded,
  }) {
    HapticFeedback.mediumImpact();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.32),
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
  late final AnimationController _ring;
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale.forward();
    Future.delayed(const Duration(milliseconds: 80), () => _ring.forward());
    Future.delayed(const Duration(milliseconds: 700), () {
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
    _ring.dispose();
    _fade.dispose();
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
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              color: AppColorsOf.card(context),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withOpacity(0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Expanding ring
                AnimatedBuilder(
                  animation: _ring,
                  builder: (context, _) {
                    final t = _ring.value;
                    return Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Container(
                        width: 80 + (t * 80),
                        height: 80 + (t * 80),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.mint.withOpacity(0.6 * (1 - t)),
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Check gradient circle
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.mint, AppColors.blue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _scale,
                      curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 36,
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
