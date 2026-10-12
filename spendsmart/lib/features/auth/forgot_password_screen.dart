import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_strings.dart';
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
    vsync: this, duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _entrance.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() { _loading = false; _sent = true; });
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
          AuthStaggerItem(controller: _entrance, start: 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AuthFloatingLogo(
                  icon: _sent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
                  iconColor: _sent ? AppColors.mint : AppColors.primaryIndigo,
                  size: 38,
                ),
                const SizedBox(height: 16),
                Text(
                  _sent ? 'Check Your Inbox' : 'Reset Password',
                  style: TextStyles.h1(context).copyWith(
                    color: Colors.white, fontSize: 26, letterSpacing: -0.5),
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
          const SizedBox(height: 28),

          // ═══ Form / success (glassmorphic) ═══
          AuthStaggerItem(controller: _entrance, start: 0.12,
            child: AuthGlassContainer(
              child: _sent ? _buildSuccessState() : _buildForm(),
            ),
          ),
          const SizedBox(height: 28),

          // ═══ Back to login CTA (glassmorphic + arrow — matches login) ═══
          AuthStaggerItem(controller: _entrance, start: 0.2,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Remember your password? ',
                      style: TextStyles.body(context)
                          .copyWith(color: Colors.white.withOpacity(0.6))),
                  const SizedBox(width: 4),
                  Text('Back to Login',
                      style: TextStyles.body(context, weight: FontWeight.w700)
                          .copyWith(color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 18),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextFormField(
          controller: _emailCtrl, validator: Validators.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          style: TextStyles.body(context).copyWith(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            floatingLabelStyle: TextStyle(color: AppColors.primaryIndigo.withOpacity(0.9)),
            hintText: 'you@example.com',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
            prefixIcon: Icon(Icons.alternate_email_rounded,
                size: 20, color: Colors.white.withOpacity(0.5)),
            errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ),
        const SizedBox(height: 20),
        MorphingLoadingButton(
          label: 'Send Reset Link', loading: _loading, onPressed: _send),
      ]),
    );
  }

  Widget _buildSuccessState() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.mint.withOpacity(0.18),
            shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.check_circle_rounded,
              color: AppColors.mint, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Text('Email sent successfully',
            style: TextStyles.body(context, weight: FontWeight.w700)
                .copyWith(color: Colors.white))),
      ]),
      const SizedBox(height: 16),
      Text(
        'Check your inbox and follow the instructions to reset your password. The link will expire in 30 minutes.',
        style: TextStyles.caption(context)
            .copyWith(color: Colors.white.withOpacity(0.7)),
      ),
      const SizedBox(height: 20),
      MorphingLoadingButton(
        label: 'Back to Login',
        icon: Icons.arrow_back_rounded,
        onPressed: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      ),
    ]);
  }
}
