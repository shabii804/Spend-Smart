import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/premium_motion.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../dashboard/main_shell.dart';
import 'login_screen.dart';
import 'shared_auth_components.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _acceptTerms = false;
  bool _loading = false;
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    // Rebuild when password changes (for strength meter)
    _pwdCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmCtrl.dispose();
    _entrance.dispose();
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
    await showPremiumSuccess(context);
    if (!mounted) return;
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
    return AuthScreenScaffold(
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Floating logo + brand
          AuthStaggerItem(controller: _entrance, start: 0.05,
            child: Column(children: [
              const AuthFloatingLogo(icon: Icons.person_add_rounded),
              const SizedBox(height: 14),
              Text('Create Account',
                  style: TextStyles.h2(context).copyWith(color: Colors.white, fontSize: 26)),
              const SizedBox(height: 4),
              Text(AppStrings.createAccountSubtitle,
                  style: TextStyles.caption(context).copyWith(color: Colors.white.withOpacity(0.85)),
                  textAlign: TextAlign.center),
            ]),
          ),
          const SizedBox(height: 28),
          // Form on glassmorphic container
          AuthStaggerItem(controller: _entrance, start: 0.15,
            child: AuthGlassContainer(
              child: Form(key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  TextFormField(
                    controller: _nameCtrl,
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                    style: TextStyles.body(context).copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppStrings.fullName,
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20, color: Colors.white.withOpacity(0.7)),
                      errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    style: TextStyles.body(context).copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppStrings.email,
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: Icon(Icons.alternate_email_rounded, size: 20, color: Colors.white.withOpacity(0.7)),
                      errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthPasswordField(controller: _pwdCtrl, label: AppStrings.password),
                  const SizedBox(height: 8),
                  // Premium password strength meter
                  PasswordStrengthMeter(password: _pwdCtrl.text),
                  const SizedBox(height: 16),
                  AuthPasswordField(controller: _confirmCtrl, label: AppStrings.confirmPassword,
                      validator: (v) => Validators.confirmPassword(v, _pwdCtrl.text)),
                  const SizedBox(height: 16),
                  // Terms checkbox
                  GestureDetector(onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AnimatedContainer(duration: const Duration(milliseconds: 180),
                        width: 20, height: 20, margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _acceptTerms ? AppColors.primaryIndigo : Colors.transparent,
                          border: Border.all(color: _acceptTerms ? AppColors.primaryIndigo : Colors.white.withOpacity(0.35), width: 1.5),
                          borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.center,
                        child: _acceptTerms ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null),
                      const SizedBox(width: 10),
                      Expanded(child: Text(AppStrings.acceptTerms,
                          style: TextStyles.caption(context).copyWith(color: Colors.white.withOpacity(0.85)))),
                    ])),
                  const SizedBox(height: 20),
                  MorphingLoadingButton(label: AppStrings.createAccount, loading: _loading, onPressed: _register),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AuthStaggerItem(controller: _entrance, start: 0.25, child: const AuthDividerRow()),
          const SizedBox(height: 16),
          // Social buttons
          AuthStaggerItem(controller: _entrance, start: 0.3,
            child: Row(children: [
              Expanded(child: AuthSocialButton(label: 'Google', icon: Icons.g_mobiledata_rounded, color: const Color(0xFFEA4335), onTap: () => _demoSnack('Google sign-up'))),
              const SizedBox(width: 10),
              Expanded(child: AuthSocialButton(label: 'Apple', icon: Icons.apple_rounded, color: Colors.white, onTap: () => _demoSnack('Apple sign-up'))),
              const SizedBox(width: 10),
              Expanded(child: AuthSocialButton(label: 'Facebook', icon: Icons.facebook_rounded, color: const Color(0xFF1877F2), onTap: () => _demoSnack('Facebook sign-up'))),
            ]),
          ),
          const SizedBox(height: 28),
          // Sign in link
          AuthStaggerItem(controller: _entrance, start: 0.4,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppStrings.alreadyHaveAccount, style: TextStyles.caption(context).copyWith(color: Colors.white.withOpacity(0.7))),
              GestureDetector(onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text(AppStrings.signIn, style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(color: Colors.white))),
            ]),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
