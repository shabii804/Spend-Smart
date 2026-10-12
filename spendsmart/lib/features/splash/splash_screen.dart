import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../onboarding/onboarding_screen.dart';
import '../dashboard/main_shell.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/forgot_password_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Multiple controllers for layered animation
  late final AnimationController _bg;
  late final AnimationController _logo;
  late final AnimationController _rings;
  late final AnimationController _text;
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _bg = AnimationController(vsync: this, duration: Motion.durSplashBg);
    _logo = AnimationController(vsync: this, duration: Motion.durLogoSpring);
    _rings = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _text = AnimationController(vsync: this, duration: Motion.durTextStagger);
    _progress = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));

    _bg.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _logo.forward());
    Future.delayed(const Duration(milliseconds: 800), () => _rings.forward());
    Future.delayed(const Duration(milliseconds: 1000), () => _text.forward());
    Future.delayed(const Duration(milliseconds: 1200), () => _progress.forward());
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(AppConstants.keyFirstLaunch) ?? false;
    final auth = Uri.base.queryParameters['auth'];

    if (auth == 'login') {
      _goTo((context) => const LoginScreen());
    } else if (auth == 'register') {
      _goTo((context) => const RegisterScreen());
    } else if (auth == 'forgot') {
      _goTo((context) => const ForgotPasswordScreen());
    } else if (seen) {
      _goTo((context) => const MainShell());
    } else {
      _goTo((context) => const OnboardingScreen());
    }
  }

  void _goTo(WidgetBuilder builder) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: builder),
    );
  }

  @override
  void dispose() {
    _bg.dispose();
    _logo.dispose();
    _rings.dispose();
    _text.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.splash),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Stack(alignment: Alignment.center, children: [
              // Layered floating shapes
              _floatingShapes(),

              // Center content
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Spacer(flex: 2),

                // Logo + orbital rings
                SizedBox(width: 160, height: 160, child: Stack(alignment: Alignment.center, children: [
                  // Orbital rings (rotating)
                  RotationTransition(turns: _rings,
                    child: SizedBox(width: 140, height: 140,
                      child: CustomPaint(painter: _OrbitalRingPainter()))),

                  // White circle with logo
                  ScaleTransition(scale: CurvedAnimation(parent: _logo, curve: Motion.springOut),
                    child: FadeTransition(opacity: CurvedAnimation(parent: _logo, curve: Motion.easeOut),
                      child: Container(width: 90, height: 90,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 16))]),
                        alignment: Alignment.center,
                        child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryIndigo, size: 44)))),

                  // Expanding ring pulse
                  AnimatedBuilder(animation: _rings, builder: (context, _) {
                    final t = _rings.value;
                    return Opacity(opacity: (1 - t).clamp(0.0, 1.0),
                      child: Container(width: 90 + t * 60, height: 90 + t * 60,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3 * (1 - t)), width: 2))));
                  }),
                ])),

                const SizedBox(height: 28),

                // App name — staggered character reveal
                FadeTransition(opacity: CurvedAnimation(parent: _text, curve: Motion.easeOut),
                  child: SlideTransition(position: Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _text, curve: Motion.springBack)),
                    child: Text('SpendSmart', style: TextStyles.h1(context).copyWith(color: Colors.white, fontSize: 32, letterSpacing: 1)))),

                const SizedBox(height: 10),

                // Tagline
                FadeTransition(opacity: CurvedAnimation(parent: _text, curve: const Interval(0.3, 1.0, curve: Motion.easeOut)),
                  child: Text('Track · Plan · Achieve', style: TextStyles.body(context).copyWith(color: Colors.white.withOpacity(0.85), letterSpacing: 2, fontSize: 13))),

                const Spacer(flex: 1),

                // Progress indicator
                FadeTransition(opacity: CurvedAnimation(parent: _progress, curve: Motion.easeOut),
                  child: SizedBox(width: 28, height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white.withOpacity(0.7)))),

                const Spacer(flex: 1),
              ]),

              // Background fade
              FadeTransition(opacity: _bg, child: Container(color: Colors.transparent)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _floatingShapes() {
    return Stack(children: [
      Positioned(top: 100, left: -40,
        child: _floatingCircle(120, AppColors.primaryPurple.withOpacity(0.08), _rings)),
      Positioned(bottom: 200, right: -30,
        child: _floatingCircle(80, AppColors.mint.withOpacity(0.06), _rings)),
      Positioned(top: 300, right: 60,
        child: _floatingCircle(50, Colors.white.withOpacity(0.04), _rings)),
    ]);
  }

  Widget _floatingCircle(double size, Color color, AnimationController anim) {
    return AnimatedBuilder(animation: anim, builder: (context, _) {
      return Transform.translate(offset: Offset(0, 20 * anim.value - 10),
        child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)));
    });
  }
}

/// Custom painter for orbital ring decoration.
class _OrbitalRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, paint);

    // Dashed orbit
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.85, dashPaint);
    canvas.drawCircle(center, radius * 0.7, dashPaint);

    // Small orbiting dot
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.4)..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx + radius, center.dy), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
