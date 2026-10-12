import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
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
    duration: const Duration(milliseconds: 700),
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
    final stagger = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                opacity: stagger,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.04),
                    end: Offset.zero,
                  ).animate(stagger),
                  child: _HeroLogo(icon: _sent
                      ? Icons.mark_email_read_rounded
                      : Icons.lock_reset_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _sent
                    ? _successState(stagger)
                    : FadeTransition(
                        opacity: stagger,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(stagger),
                          child: _formState(),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          Text(AppStrings.forgotPasswordTitle, style: TextStyles.h1(context)),
          const SizedBox(height: 6),
          Text(
            AppStrings.forgotPasswordSubtitle,
            style: TextStyles.body(context,
                color: AppColorsOf.secondaryText(context)),
          ),
          const SizedBox(height: 28),
          AppTextField(
            label: AppStrings.email,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            prefix: const Icon(Icons.alternate_email_rounded, size: 20),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: AppStrings.sendResetLink,
            loading: _loading,
            onPressed: _send,
          ),
        ],
      ),
    );
  }

  Widget _successState(CurvedAnimation stagger) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Text('Check Your Inbox', style: TextStyles.h1(context),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.resetLinkSent,
            style: TextStyles.body(context,
                color: AppColorsOf.secondaryText(context)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
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

class _HeroLogo extends StatelessWidget {
  final IconData icon;
  const _HeroLogo({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: AppGradients.splash,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primaryIndigo, size: 36),
          ),
        ],
      ),
    );
  }
}
