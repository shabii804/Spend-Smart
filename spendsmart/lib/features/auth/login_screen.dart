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
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'shared_auth_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'muhammad@gmail.com');
  final _pwdCtrl = TextEditingController(text: 'demo1234');
  bool _loading = false;
  bool _rememberMe = true;
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
    _pwdCtrl.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.read<UserProvider>().updateUser(UserProfile(
          fullName: 'Muhammad Shoaib',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Floating logo + brand
          AuthStaggerItem(controller: _entrance, start: 0.0,
            child: Column(children: [
              const AuthFloatingLogo(icon: Icons.account_balance_wallet_rounded),
              const SizedBox(height: 8),
              Text('SpendSmart',
                  style: TextStyles.h2(context).copyWith(color: Colors.white, fontSize: 26)),
              const SizedBox(height: 2),
              Text(AppStrings.appTagline,
                  style: TextStyles.caption(context).copyWith(color: Colors.white.withOpacity(0.85))),
            ]),
          ),
          const SizedBox(height: 12),
          // Heading
          AuthStaggerItem(controller: _entrance, start: 0.1,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppStrings.welcomeBack,
                  style: TextStyles.h1(context).copyWith(color: Colors.white, fontSize: 28)),
              const SizedBox(height: 4),
              Text(AppStrings.welcomeBackSubtitle,
                  style: TextStyles.body(context, color: Colors.white.withOpacity(0.78))),
            ]),
          ),
          const SizedBox(height: 12),
          // Form on glassmorphic container
          AuthStaggerItem(controller: _entrance, start: 0.18,
            child: AuthGlassContainer(
              child: Form(key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                  const SizedBox(height: 10),
                  AuthPasswordField(controller: _pwdCtrl, label: AppStrings.password,
                      textInputAction: TextInputAction.done),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    GestureDetector(onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedContainer(duration: const Duration(milliseconds: 180),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: _rememberMe ? AppColors.primaryIndigo : Colors.transparent,
                            border: Border.all(color: _rememberMe ? AppColors.primaryIndigo : Colors.white.withOpacity(0.35), width: 1.5),
                            borderRadius: BorderRadius.circular(6)),
                          alignment: Alignment.center,
                          child: _rememberMe ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null),
                        const SizedBox(width: 8),
                        Text('Remember me', style: TextStyles.caption(context, weight: FontWeight.w500).copyWith(color: Colors.white.withOpacity(0.85))),
                      ])),
                    TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child: Text(AppStrings.forgotPassword, style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(color: AppColors.primaryIndigo))),
                  ]),
                  const SizedBox(height: 20),
                  MorphingLoadingButton(label: AppStrings.logIn, loading: _loading, onPressed: _login),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AuthStaggerItem(controller: _entrance, start: 0.26, child: const AuthDividerRow()),
          const SizedBox(height: 10),
          // Social buttons
          AuthStaggerItem(controller: _entrance, start: 0.32,
            child: Row(children: [
              Expanded(child: AuthSocialButton(label: 'Google', icon: Icons.g_mobiledata_rounded, color: const Color(0xFFEA4335), onTap: () => _demoSnack('Google sign-in'))),
              const SizedBox(width: 10),
              Expanded(child: AuthSocialButton(label: 'Apple', icon: Icons.apple_rounded, color: Colors.white, onTap: () => _demoSnack('Apple sign-in'))),
              const SizedBox(width: 10),
              Expanded(child: AuthSocialButton(label: 'Facebook', icon: Icons.facebook_rounded, color: const Color(0xFF1877F2), onTap: () => _demoSnack('Facebook sign-in'))),
            ]),
          ),
          const SizedBox(height: 12),
          // Sign up link
          AuthStaggerItem(controller: _entrance, start: 0.4,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppStrings.dontHaveAccount, style: TextStyles.caption(context).copyWith(color: Colors.white.withOpacity(0.7))),
              GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text(AppStrings.signUp, style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(color: Colors.white))),
            ]),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
