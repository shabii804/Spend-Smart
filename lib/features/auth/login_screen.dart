import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../dashboard/main_shell.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'muhammad@gmail.com');
  final _pwdCtrl = TextEditingController(text: 'demo1234');
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.read<UserProvider>().updateUser(
          UserProfile(
            fullName: 'Muhammad Shoaib',
            email: _emailCtrl.text.trim(),
          ),
        );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  void _demoSnack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — ${AppStrings.demoOnly}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryButton,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryIndigo.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 34),
                ),
                const SizedBox(height: 24),
                Text(AppStrings.welcomeBack,
                    style: TextStyles.h1(context)),
                const SizedBox(height: 6),
                Text(AppStrings.welcomeBackSubtitle,
                    style: TextStyles.body(context,
                        color: AppColorsOf.secondaryText(context))),
                const SizedBox(height: 28),
                AppTextField(
                  label: AppStrings.email,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefix: const Icon(Icons.alternate_email_rounded, size: 20),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.password,
                  controller: _pwdCtrl,
                  validator: Validators.password,
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline_rounded, size: 20),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen()),
                    ),
                    child: Text(
                      AppStrings.forgotPassword,
                      style: TextStyles.caption(context, weight: FontWeight.w600)
                          .copyWith(color: AppColors.primaryIndigo),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: AppStrings.logIn,
                  loading: _loading,
                  onPressed: _login,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: AppColorsOf.border(context), height: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(AppStrings.orContinueWith,
                          style: TextStyles.caption(context)),
                    ),
                    Expanded(
                        child: Divider(
                            color: AppColorsOf.border(context), height: 1)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        label: 'Google',
                        icon: Icons.g_mobiledata_rounded,
                        onTap: () => _demoSnack('Google sign-in'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SocialButton(
                        label: 'Apple',
                        icon: Icons.apple_rounded,
                        onTap: () => _demoSnack('Apple sign-in'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.dontHaveAccount,
                        style: TextStyles.caption(context)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: Text(
                        AppStrings.signUp,
                        style: TextStyles.caption(context,
                                weight: FontWeight.w700)
                            .copyWith(color: AppColors.primaryIndigo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColorsOf.card(context),
            border: Border.all(color: AppColorsOf.border(context)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label, style: TextStyles.body(context, weight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
