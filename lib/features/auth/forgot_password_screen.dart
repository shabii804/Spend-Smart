import 'package:flutter/material.dart';
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

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _sent ? _successState() : _formState(),
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
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryButton,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.lock_reset_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 24),
          Text(AppStrings.forgotPasswordTitle,
              style: TextStyles.h1(context)),
          const SizedBox(height: 6),
          Text(
            AppStrings.forgotPasswordSubtitle,
            style: TextStyles.body(context,
                color: AppColorsOf.secondaryText(context)),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: AppStrings.email,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            prefix: const Icon(Icons.alternate_email_rounded, size: 20),
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
    );
  }

  Widget _successState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 96,
          height: 96,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.mint.withOpacity(0.16),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.mark_email_read_rounded,
              color: AppColors.mint, size: 44),
        ),
        const SizedBox(height: 24),
        Text('Check Your Inbox', style: TextStyles.h1(context), textAlign: TextAlign.center),
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
