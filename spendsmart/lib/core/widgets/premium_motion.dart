import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';

// ═══════════════════════════════════════════════════════════════════
// PremiumLoadingIndicator — multi-ring rotating loader with pulsing center
// ═══════════════════════════════════════════════════════════════════
class PremiumLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  const PremiumLoadingIndicator({super.key, this.size = 32, this.color});

  @override
  State<PremiumLoadingIndicator> createState() => _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _spin1;
  late final AnimationController _spin2;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _spin1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _spin2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spin1.dispose();
    _spin2.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? Colors.white;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(alignment: Alignment.center, children: [
        // Outer ring (clockwise)
        RotationTransition(turns: _spin1,
          child: SizedBox(width: widget.size, height: widget.size,
            child: CircularProgressIndicator(value: 0.7, strokeWidth: 2.5, color: c.withOpacity(0.7), backgroundColor: c.withOpacity(0.12))),
        ),
        // Inner ring (counter-clockwise)
        RotationTransition(turns: _spin2,
          child: SizedBox(width: widget.size * 0.62, height: widget.size * 0.62,
            child: CircularProgressIndicator(value: 0.5, strokeWidth: 2, color: c.withOpacity(0.9), backgroundColor: Colors.transparent))),
        // Pulsing center dot
        ScaleTransition(scale: Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _pulse, curve: Motion.easeOut)),
          child: Container(width: 6, height: 6, decoration: BoxDecoration(color: c, shape: BoxShape.circle))),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MorphingLoadingButton — label morphs to spinner, press spring
// ═══════════════════════════════════════════════════════════════════
class MorphingLoadingButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool loading;
  final VoidCallback? onPressed;
  final bool expand;

  const MorphingLoadingButton({
    super.key,
    required this.label,
    this.icon,
    this.loading = false,
    this.onPressed,
    this.expand = true,
  });

  @override
  State<MorphingLoadingButton> createState() => _MorphingLoadingButtonState();
}

class _MorphingLoadingButtonState extends State<MorphingLoadingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) { if (enabled) _press.forward(); },
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      onTap: enabled ? () { HapticFeedback.lightImpact(); widget.onPressed!(); } : null,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) {
          final scale = 1.0 - (_press.value * 0.03);
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedContainer(
          duration: Motion.durButtonMorph,
          curve: Motion.easeOut,
          constraints: const BoxConstraints(minHeight: 54),
          width: widget.expand ? double.infinity : null,
          decoration: BoxDecoration(
            gradient: enabled ? AppGradients.primaryButton : LinearGradient(colors: [AppColors.primaryIndigo.withOpacity(0.4), AppColors.primaryPurple.withOpacity(0.4)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled ? [BoxShadow(color: AppColors.primaryIndigo.withOpacity(0.32), blurRadius: 16, offset: const Offset(0, 6))] : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Stack(alignment: Alignment.center, children: [
            // Label (fades out when loading)
            AnimatedOpacity(opacity: widget.loading ? 0.0 : 1.0, duration: Motion.durButtonMorph,
              child: AnimatedScale(scale: widget.loading ? 0.7 : 1.0, duration: Motion.durButtonMorph, curve: Motion.easeOut,
                child: Row(mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (widget.icon != null) ...[Icon(widget.icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
                  Text(widget.label, style: TextStyles.body(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                ]))),
            // Spinner (fades in when loading)
            AnimatedOpacity(opacity: widget.loading ? 1.0 : 0.0, duration: Motion.durButtonMorph,
              child: const PremiumLoadingIndicator(size: 22, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// AmbientBackgroundAnimation — floating shapes + particles for auth screens
// ═══════════════════════════════════════════════════════════════════
class AmbientBackgroundAnimation extends StatefulWidget {
  const AmbientBackgroundAnimation({super.key});

  @override
  State<AmbientBackgroundAnimation> createState() => _AmbientBackgroundAnimationState();
}

class _AmbientBackgroundAnimationState extends State<AmbientBackgroundAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _float1;
  late final AnimationController _float2;
  late final AnimationController _float3;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _float1 = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _float2 = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _float3 = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(reverse: true);
    _glow = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float1.dispose();
    _float2.dispose();
    _float3.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Large floating shape 1
      AnimatedBuilder(animation: _float1, builder: (context, _) {
        return Transform.translate(offset: Offset(60 * _float1.value - 30, 40 * _float1.value - 20),
          child: Opacity(opacity: 0.06,
            child: Container(width: 200, height: 200, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryIndigo))));
      }),
      // Large floating shape 2
      Positioned(right: -40, top: 200,
        child: AnimatedBuilder(animation: _float2, builder: (context, _) {
          return Transform.translate(offset: Offset(-40 * _float2.value + 20, 50 * _float2.value - 25),
            child: Opacity(opacity: 0.05,
              child: Container(width: 160, height: 160, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryPurple))));
        })),
      // Small floating shape 3
      Positioned(left: 30, bottom: 150,
        child: AnimatedBuilder(animation: _float3, builder: (context, _) {
          return Transform.translate(offset: Offset(30 * _float3.value - 15, -30 * _float3.value + 15),
            child: Opacity(opacity: 0.04,
              child: Container(width: 100, height: 100, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.mint))));
        })),
      // Ambient glow pulse
      Center(child: AnimatedBuilder(animation: _glow, builder: (context, _) {
        return Container(width: 300, height: 300,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: RadialGradient(colors: [AppColors.primaryIndigo.withOpacity(0.08 * _glow.value), Colors.transparent], stops: const [0.4, 1.0])));
      })),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════
// PasswordStrengthMeter — animated bar + label
// ═══════════════════════════════════════════════════════════════════
class PasswordStrengthMeter extends StatelessWidget {
  final String password;
  const PasswordStrengthMeter({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = _calcStrength(password);
    final (label, color) = _labelColor(strength);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Motion.easeOut,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(3),
          child: Stack(children: [
            Container(height: 4, color: AppColors.primaryIndigo.withOpacity(0.12)),
            AnimatedContainer(duration: const Duration(milliseconds: 300), curve: Motion.easeOut,
              height: 4, width: (strength * MediaQuery.sizeOf(context).width).clamp(0.0, double.infinity),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]), borderRadius: BorderRadius.circular(3))),
          ])),
        const SizedBox(height: 6),
        Text(label, style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(color: color, fontSize: 11)),
      ]),
    );
  }

  double _calcStrength(String pwd) {
    if (pwd.isEmpty) return 0;
    double score = 0;
    if (pwd.length >= 6) score += 0.25;
    if (pwd.length >= 10) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(pwd)) score += 0.15;
    if (RegExp(r'[0-9]').hasMatch(pwd)) score += 0.2;
    if (RegExp(r'[!@#$]').hasMatch(pwd)) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  (String, Color) _labelColor(double strength) {
    if (strength < 0.25) return ('Too short', AppColors.danger);
    if (strength < 0.5) return ('Weak', AppColors.warning);
    if (strength < 0.75) return ('Good', AppColors.blue);
    return ('Strong', AppColors.mint);
  }
}

// ═══════════════════════════════════════════════════════════════════
// PremiumSuccessAnimation — checkmark + 3 expanding rings + particles
// ═══════════════════════════════════════════════════════════════════
class PremiumSuccessAnimation extends StatefulWidget {
  final VoidCallback? onComplete;
  const PremiumSuccessAnimation({super.key, this.onComplete});

  @override
  State<PremiumSuccessAnimation> createState() => _PremiumSuccessAnimationState();
}

class _PremiumSuccessAnimationState extends State<PremiumSuccessAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _scale;
  late final AnimationController _ring1;
  late final AnimationController _ring2;
  late final AnimationController _fade;

  @override
  void initState() {
    super.initState();
    _scale = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..forward();
    _ring1 = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _ring2 = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _fade = AnimationController(vsync: this, duration: const Duration(milliseconds: 280), value: 1.0);
    Future.delayed(const Duration(milliseconds: 60), () => _ring1.forward());
    Future.delayed(const Duration(milliseconds: 200), () => _ring2.forward());
    Future.delayed(const Duration(milliseconds: 900), () {
      _fade.reverse();
      if (mounted) Future.delayed(const Duration(milliseconds: 280), () => widget.onComplete?.call());
    });
  }

  @override
  void dispose() {
    _scale.dispose(); _ring1.dispose(); _ring2.dispose(); _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _scale, curve: Motion.springOut),
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow halo
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
                // Expanding rings
                _ring(_ring1, 70),
                _ring(_ring2, 55),
                // Center circle with checkmark
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.mint, AppColors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                      parent: _scale,
                      curve: const Interval(0.4, 1.0, curve: Motion.springOut),
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 46),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ring(AnimationController c, double max) {
    return AnimatedBuilder(animation: c, builder: (context, _) {
      final t = c.value;
      return Opacity(opacity: (1 - t).clamp(0.0, 1.0),
        child: Container(width: 70 + t * max * 2, height: 70 + t * max * 2,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.mint.withOpacity(0.7 * (1 - t)), width: 3))));
    });
  }
}

// ═══════════════════════════════════════════════════════════════════
// AnimatedAuthRoute — premium PageRouteBuilder for auth transitions
// ═══════════════════════════════════════════════════════════════════
class AnimatedAuthRoute<T> extends PageRouteBuilder<T> {
  AnimatedAuthRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, anim, _) => builder(context),
          transitionDuration: Motion.durPageRoute,
          reverseTransitionDuration: Motion.durPageRoute,
          transitionsBuilder: (context, anim, _, child) {
            final curved = CurvedAnimation(parent: anim, curve: Motion.easeOut);
            return FadeTransition(opacity: curved,
              child: SlideTransition(position: Tween(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(curved),
                child: ScaleTransition(scale: Tween(begin: 0.97, end: 1.0).animate(curved), alignment: Alignment.topCenter, child: child)));
          },
        );
}

/// Show the premium success overlay as a dialog.
Future<void> showPremiumSuccess(BuildContext context, {VoidCallback? onComplete}) {
  HapticFeedback.mediumImpact();
  return showDialog<void>(context: context, barrierDismissible: false, barrierColor: Colors.black.withOpacity(0.34),
    builder: (_) => PremiumSuccessAnimation(onComplete: () { if (Navigator.of(context).canPop()) Navigator.of(context).maybePop(); onComplete?.call(); }));
}
