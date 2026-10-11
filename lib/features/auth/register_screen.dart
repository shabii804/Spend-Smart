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
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _acceptTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errAcceptTerms)),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.read<UserProvider>().updateUser(UserProfile(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
        ));
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
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
          child: Form(
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryIndigo.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.person_add_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text(AppStrings.createAccountTitle,
                    style: TextStyles.h1(context)),
                const SizedBox(height: 6),
                Text(
                  AppStrings.createAccountSubtitle,
                  style: TextStyles.body(context,
                      color: AppColorsOf.secondaryText(context)),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: AppStrings.fullName,
                  controller: _nameCtrl,
                  prefix: const Icon(Icons.person_outline_rounded, size: 20),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.email,
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  prefix: const Icon(Icons.alternate_email_rounded, size: 20),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.password,
                  controller: _pwdCtrl,
                  validator: Validators.password,
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline_rounded, size: 20),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.confirmPassword,
                  controller: _confirmCtrl,
                  validator: Validators.match(_pwdCtrl.text),
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline_rounded, size: 20),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _acceptTerms,
                  onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    AppStrings.acceptTerms,
                    style: TextStyles.caption(context),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: AppStrings.createAccount,
                  loading: _loading,
                  onPressed: _register,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.alreadyHaveAccount,
                        style: TextStyles.caption(context)),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      child: Text(
                        AppStrings.signIn,
                        style: TextStyles.caption(context,
                                weight: FontWeight.w700)
                            .copyWith(color: AppColors.primaryIndigo),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
