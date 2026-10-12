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
          // Floating logo (icon changes based on _sent state)
          AuthStaggerItem(controller: _entrance, start: 0.05,
            child: Column(children: [
              AuthFloatingLogo(
                icon: _sent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
                iconColor: _sent ? AppColors.mint : AppColors.primaryIndigo,
                size: 38,
              ),
              const SizedBox(height: 14),
              Text(
                _sent ? 'Check Your Inbox' : AppStrings.forgotPasswordTitle,
                style: TextStyles.h2(context).copyWith(color: Colors.white, fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                _sent ? AppStrings.resetLinkSent : AppStrings.forgotPasswordSubtitle,
                style: TextStyles.body(context).copyWith(color: Colors.white.withOpacity(0.78)),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
          const SizedBox(height: 32),
          // Glassmorphic form OR success state
          AuthStaggerItem(controller: _entrance, start: 0.15,
            child: AuthGlassContainer(
              child: _sent ? _buildSuccessState() : _buildForm(),
            ),
          ),
          const SizedBox(height: 28),
          // Back to login link
          AuthStaggerItem(controller: _entrance, start: 0.25,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Remember your password? ',
                  style: TextStyles.caption(context).copyWith(color: Colors.white.withOpacity(0.7))),
              GestureDetector(onTap: () => Navigator.of(context).maybePop(),
                child: Text(AppStrings.backToLogin,
                    style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(color: Colors.white))),
            ]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextFormField(
          controller: _emailCtrl,
          validator: Validators.email,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          style: TextStyles.body(context).copyWith(color: Colors.white),
          decoration: InputDecoration(
            labelText: AppStrings.email,
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            prefixIcon: Icon(Icons.alternate_email_rounded, size: 20, color: Colors.white.withOpacity(0.7)),
            errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ),
        const SizedBox(height: 24),
        MorphingLoadingButton(label: AppStrings.sendResetLink, loading: _loading, onPressed: _send),
      ]),
    );
  }

  Widget _buildSuccessState() {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.mint.withOpacity(0.18), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Text('Email sent successfully',
            style: TextStyles.body(context, weight: FontWeight.w600).copyWith(color: Colors.white))),
      ]),
      const SizedBox(height: 16),
      Text(
        'We sent a reset link to ${_emailCtrl.text.isEmpty ? "your email" : _emailCtrl.text.trim()}. Check your inbox and follow the instructions to reset your password.',
        style: TextStyles.caption(context).copyWith(color: Colors.white.withOpacity(0.78)),
      ),
      const SizedBox(height: 20),
      MorphingLoadingButton(
        label: AppStrings.backToLogin,
        icon: Icons.arrow_back_rounded,
        onPressed: () { if (Navigator.of(context).canPop()) Navigator.of(context).pop(); },
      ),
    ]);
  }
}
