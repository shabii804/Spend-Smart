import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      // Force dark theme so text renders white over the bg image
      data: Theme.of(context).copyWith(brightness: Brightness.dark),
      child: Scaffold(
        body: Container(
          // Premium background image (matches login + register)
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/auth_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            // Dark gradient overlay
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.42),
                  Colors.black.withOpacity(0.18),
                  AppColors.darkBackground.withOpacity(0.78),
                  AppColors.darkBackground.withOpacity(0.96),
                ],
                stops: const [0.0, 0.32, 0.62, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StaggerItem(
                        controller: _entrance,
                        start: 0.0,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                  width: 1),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Floating logo (icon changes based on _sent state)
                    _StaggerItem(
                      controller: _entrance,
                      start: 0.05,
                      child: Column(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.32),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _sent
                                  ? Icons.mark_email_read_rounded
                                  : Icons.lock_reset_rounded,
                              color: _sent ? AppColors.mint : AppColors.primaryIndigo,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _sent ? 'Check Your Inbox' : AppStrings.forgotPasswordTitle,
                            style: TextStyles.h2(context)
                                .copyWith(color: Colors.white, fontSize: 24),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _sent
                                ? AppStrings.resetLinkSent
                                : AppStrings.forgotPasswordSubtitle,
                            style: TextStyles.body(context)
                                .copyWith(color: Colors.white.withOpacity(0.78)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Glassmorphic form OR success state
                    _StaggerItem(
                      controller: _entrance,
                      start: 0.15,
                      child: _GlassContainer(
                        child: _sent
                            ? _successState()
                            : Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    AppTextField(
                                      label: AppStrings.email,
                                      controller: _emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: Validators.email,
                                      prefix: Icon(Icons.alternate_email_rounded,
                                          size: 20, color: Colors.white.withOpacity(0.7)),
                                      textInputAction: TextInputAction.done,
                                    ),
                                    const SizedBox(height: 24),
                                    PrimaryButton(
                                      label: AppStrings.sendResetLink,
                                      loading: _loading,
                                      onPressed: _send,
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Back to login link (always visible)
                    _StaggerItem(
                      controller: _entrance,
                      start: 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Remember your password? ',
                              style: TextStyles.caption(context)
                                  .copyWith(color: Colors.white.withOpacity(0.7))),
                          GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: Text(
                              AppStrings.backToLogin,
                              style: TextStyles.caption(context,
                                      weight: FontWeight.w700)
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _successState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.mint, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Email sent successfully',
                  style: TextStyles.body(context, weight: FontWeight.w600)
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'We sent a reset link to ${_emailCtrl.text.isEmpty ? "your email" : _emailCtrl.text.trim()}. Check your inbox and follow the instructions to reset your password.',
          style: TextStyles.caption(context)
              .copyWith(color: Colors.white.withOpacity(0.78)),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: AppStrings.backToLogin,
          icon: Icons.arrow_back_rounded,
          onPressed: () {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

/// Glassmorphic container — frosted-glass style card over the bg image.
class _GlassContainer extends StatelessWidget {
  final Widget child;
  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StaggerItem extends StatelessWidget {
  final AnimationController controller;
  final double start;
  final Widget child;
  const _StaggerItem({
    required this.controller,
    required this.start,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}
