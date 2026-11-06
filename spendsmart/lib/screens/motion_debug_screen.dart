import 'package:flutter/material.dart';
import '../core/constants/motion.dart';
import '../core/motion/app_logo.dart';
import '../core/motion/app_motion.dart';
import '../core/motion/haptics.dart';
import '../core/motion/motion_widgets.dart';
import '../core/motion/page_transitions.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
import '../core/theme/text_styles.dart';
import '../core/widgets/confetti_burst.dart';
import '../core/widgets/premium_motion.dart';
import '../core/widgets/success_overlay.dart';

/// Motion debug playground — showcases every motion widget and token.
/// Access via deep-link `?route=motionDebug` or push directly.
/// Useful for QA, screenshots, and verifying reduce-motion behaviour.
class MotionDebugScreen extends StatelessWidget {
  const MotionDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsOf.background(context),
      appBar: AppBar(
        title: const Text('Motion Playground'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            _sectionLabel(context, 'AppLogo'),
            _LogoShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'Pressable (press-scale feedback)'),
            _PressableShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'Smooth Fade Page Transitions (Ultra-Smooth)'),
            _PageTransitionShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'Animated Icon Bounce & Micro-Interactions'),
            _IconBounceShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'ShakeWidget (validation error)'),
            _ShakeShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'DrawnCheckmark (path draw)'),
            _CheckmarkShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'CountUpText (money roll)'),
            _CountUpShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'ShimmerSkeleton (loading placeholder)'),
            const ShimmerSkeleton(width: double.infinity, height: 48, radius: 12),
            const SizedBox(height: 8),
            const ShimmerSkeleton(width: 200, height: 16, radius: 8),
            const SizedBox(height: 8),
            const ShimmerSkeleton(width: 140, height: 16, radius: 8),
            const SizedBox(height: 24),

            _sectionLabel(context, 'MorphingLoadingButton (label → spinner)'),
            _MorphButtonShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'PremiumLoadingIndicator'),
            const Center(child: PremiumLoadingIndicator(size: 48, color: AppColors.primaryIndigo)),
            const SizedBox(height: 24),

            _sectionLabel(context, 'PasswordStrengthMeter'),
            const _StrengthShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'Success overlays (one-shot)'),
            _OverlayShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'Haptic feedback (one-shot)'),
            _HapticShowcase(),
            const SizedBox(height: 24),

            _sectionLabel(context, 'Motion tokens (read-only)'),
            _TokensCard(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(text,
          style: TextStyles.caption(context, weight: FontWeight.w700)
              .copyWith(color: AppColorsOf.secondaryText(context), letterSpacing: 0.6),),
    );
  }

  Widget _TokensCard(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('instant', '${AppMotion.instant.inMilliseconds}ms'),
      MapEntry('fast', '${AppMotion.fast.inMilliseconds}ms'),
      MapEntry('base', '${AppMotion.base.inMilliseconds}ms'),
      MapEntry('slow', '${AppMotion.slow.inMilliseconds}ms'),
      MapEntry('hero', '${AppMotion.hero.inMilliseconds}ms'),
      MapEntry('splashMax', '${AppMotion.splashMax.inMilliseconds}ms'),
      const MapEntry('pressScale', '${AppMotion.pressScale}x'),
      MapEntry('staggerStep', '${AppMotion.staggerStep.inMilliseconds}ms'),
      const MapEntry('maxStaggeredItems', '${AppMotion.maxStaggeredItems}'),
      MapEntry('reduceMotion', '${AppMotion.reduceMotion(context)}'),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsOf.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.key, style: TextStyles.caption(context, weight: FontWeight.w600)),
                  Text(r.value,
                      style: TextStyles.caption(context, weight: FontWeight.w700)
                          .copyWith(color: AppColors.primaryIndigo),),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Showcases
// ─────────────────────────────────────────────────────────────────

class _LogoShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsOf.border(context)),
      ),
      child: const Wrap(
        spacing: 24,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppLogo(size: 64, variant: AppLogoVariant.markOnly),
          AppLogo(size: 64, variant: AppLogoVariant.markWithWordmarkHorizontal),
          AppLogo(size: 80, variant: AppLogoVariant.markWithWordmarkStacked),
          AppLogo(size: 64, variant: AppLogoVariant.monochrome, showGlow: false),
        ],
      ),
    );
  }
}

class _PressableShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Pressable(
          onPressed: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Press me', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Pressable(
          onPressed: () {},
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ShakeShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Find the nearest ShakeWidgetState via a GlobalKey-like pattern is hard
    // in a stateless showcase. Instead, embed a StatefulWidget.
    return const _ShakeCard();
  }
}

class _ShakeCard extends StatefulWidget {
  const _ShakeCard();
  @override
  State<_ShakeCard> createState() => _ShakeCardState();
}

class _ShakeCardState extends State<_ShakeCard> {
  final _key = GlobalKey<ShakeWidgetState>();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShakeWidget(
          key: _key,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.danger.withOpacity(0.4)),
            ),
            child: const Text('Email is invalid',
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () => _key.currentState?.shake(),
          child: const Text('Trigger shake'),
        ),
      ],
    );
  }
}

class _CheckmarkShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _CheckmarkCard();
  }
}

class _CheckmarkCard extends StatefulWidget {
  const _CheckmarkCard();
  @override
  State<_CheckmarkCard> createState() => _CheckmarkCardState();
}

class _CheckmarkCardState extends State<_CheckmarkCard> {
  final _key = GlobalKey<DrawnCheckmarkState>();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DrawnCheckmark(
          key: _key,
          size: 48,
          color: AppColors.mint,
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () => _key.currentState?.play(),
          child: const Text('Draw checkmark'),
        ),
      ],
    );
  }
}

class _CountUpShowcase extends StatefulWidget {
  @override
  State<_CountUpShowcase> createState() => _CountUpShowcaseState();
}

class _CountUpShowcaseState extends State<_CountUpShowcase> {
  double _target = 1250.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsOf.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountUpText(
            target: _target,
            prefix: 'Rs. ',
            style: TextStyles.h2(context).copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: AppColors.primaryIndigo,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [500, 1500, 5000, 12500].map((v) {
              return TextButton(
                onPressed: () => setState(() => _target = v.toDouble()),
                child: Text('Rs. $v'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MorphButtonShowcase extends StatefulWidget {
  @override
  State<_MorphButtonShowcase> createState() => _MorphButtonShowcaseState();
}

class _MorphButtonShowcaseState extends State<_MorphButtonShowcase> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MorphingLoadingButton(
          label: 'Save (morphs to spinner)',
          icon: Icons.save_rounded,
          loading: _loading,
          onPressed: () async {
            setState(() => _loading = true);
            await Future.delayed(const Duration(seconds: 2));
            if (mounted) setState(() => _loading = false);
          },
        ),
      ],
    );
  }
}

class _StrengthShowcase extends StatelessWidget {
  const _StrengthShowcase();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsOf.border(context)),
      ),
      child: const Column(
        children: [
          PasswordStrengthMeter(password: ''),
          SizedBox(height: 12),
          PasswordStrengthMeter(password: 'abc'),
          SizedBox(height: 12),
          PasswordStrengthMeter(password: 'abcdef12'),
          SizedBox(height: 12),
          PasswordStrengthMeter(password: 'Abcdef12!@'),
        ],
      ),
    );
  }
}

class _OverlayShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        TextButton(
          onPressed: () => showPremiumSuccess(context),
          child: const Text('Premium success'),
        ),
        TextButton(
          onPressed: () => SuccessOverlay.show(context, label: 'Saved'),
          child: const Text('Overlay (3 rings + check)'),
        ),
        TextButton(
          onPressed: () => ConfettiBurst.show(context),
          child: const Text('Confetti burst'),
        ),
      ],
    );
  }
}

class _HapticShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const TextButton(onPressed: Haptics.light, child: Text('Light')),
        const TextButton(onPressed: Haptics.selection, child: Text('Selection')),
        const TextButton(onPressed: Haptics.success, child: Text('Success (medium)')),
        const TextButton(onPressed: Haptics.heavy, child: Text('Heavy')),
        const TextButton(onPressed: Haptics.error, child: Text('Error pattern')),
        TextButton(
          onPressed: () => Haptics.enabled = !Haptics.enabled,
          child: const Text('Toggle haptics'),
        ),
      ],
    );
  }
}


class _PageTransitionShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsOf.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test the buttery-smooth fade opacity page transitions',
            style: TextStyles.caption(context),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryIndigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.animation_rounded, size: 20),
            label: const Text('Navigate with Smooth Fade Opacity'),
            onPressed: () {
              Navigator.of(context).push(
                SmoothFadePageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Smooth Page Demo'),
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 64, color: AppColors.mint,),
                          const SizedBox(height: 16),
                          Text('Smooth Fade Page',
                              style: TextStyles.h2(context),),
                          const SizedBox(height: 8),
                          Text('Delightful opacity cross-fade active!',
                              style: TextStyles.caption(context),),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IconBounceShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColorsOf.border(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          AnimatedIconBounce(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryIndigo.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_rounded, color: AppColors.primaryIndigo, size: 28),
            ),
          ),
          AnimatedIconBounce(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.savings_rounded, color: AppColors.mint, size: 28),
            ),
          ),
          AnimatedIconBounce(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.insights_rounded, color: AppColors.primaryPurple, size: 28),
            ),
          ),
          AnimatedIconBounce(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.blue, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
