import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/premium_motion.dart';
import 'shared_auth_components.dart';

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
    return AuthScreenScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══ Logo + heading (matches login style) ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AuthFloatingLogo(
                  icon: _sent
                      ? Icons.mark_email_read_rounded
                      : Icons.lock_reset_rounded,
                  iconColor: _sent ? AppColors.mint : AppColors.primaryIndigo,
                  size: 38,
                ),
                const SizedBox(height: AuthSpacing.md),
                Text(
                  _sent ? 'Check Your Inbox' : 'Reset Password',
                  style: TextStyles.h1(context).copyWith(
                    color: Colors.white,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _sent
                      ? 'We sent a reset link to ${_emailCtrl.text.isEmpty ? "your email" : _emailCtrl.text.trim()}.'
                      : 'Enter your email and we will send you a reset link.',
                  style: TextStyles.body(context,
                      color: Colors.white.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.lg),

          // ═══ Form / success (solid surface card) ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.12,
            child: AuthGlassContainer(
              child: _sent ? _buildSuccessState() : _buildForm(),
            ),
          ),
          const SizedBox(height: AuthSpacing.lg),

          // ═══ Bottom CTA ═══
          // In the form state, show the "Remember password? Back to Login"
          // glassmorphic link. In the success state, the in-card button IS
          // the primary back action — no duplicate CTA at the bottom.
          if (!_sent)
            AuthStaggerItem(
              controller: _entrance,
              start: 0.2,
              child: AuthFooterLink(
                prompt: 'Remember your password?',
                action: 'Back to Login',
                arrow: Icons.arrow_back_rounded,
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ),
          const SizedBox(height: AuthSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _emailCtrl,
            validator: Validators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            label: 'Email',
            hint: 'you@example.com',
            prefixIcon: Icons.alternate_email_rounded,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: AuthSpacing.lg),
          MorphingLoadingButton(
            label: 'Send Reset Link',
            loading: _loading,
            onPressed: _send,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.mint,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Email sent successfully',
                style: TextStyles.body(context, weight: FontWeight.w700)
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: AuthSpacing.md),
        Text(
          'Check your inbox and follow the instructions to reset your password. The link will expire in 30 minutes.',
          style: TextStyles.caption(context)
              .copyWith(color: Colors.white.withOpacity(0.7)),
        ),
        const SizedBox(height: AuthSpacing.lg),
        MorphingLoadingButton(
          label: 'Back to Login',
          icon: Icons.arrow_back_rounded,
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
