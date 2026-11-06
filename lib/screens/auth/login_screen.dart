import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/motion/app_logo.dart';
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
          // ═══ Logo + heading ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppLogo(size: 72, variant: AppLogoVariant.markOnly),
                const SizedBox(height: AuthSpacing.md),
                Text(
                  'Welcome Back',
                  style: TextStyles.h1(context).copyWith(
                    color: AppColors.darkTextPrimary,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Log in to keep tracking your spending.',
                  style: TextStyles.body(context,
                      color: AppColors.darkTextSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.lg),

          // ═══ Form (solid surface card) ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.12,
            child: AuthGlassContainer(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email
                    AuthTextField(
                      controller: _emailCtrl,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      label: 'Email',
                      hint: 'you@example.com',
                      prefixIcon: Icons.alternate_email_rounded,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AuthSpacing.md),
                    // Password — now uses the SAME permanent-label design
                    // as AuthTextField, so no clipping, no floating-label
                    // collision with prefix icon.
                    AuthPasswordField(
                      controller: _pwdCtrl,
                      label: 'Password',
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AuthSpacing.sm),
                    // Remember me + Forgot password — Flexible on both sides
                    // so the row never overflows on small screens.
                    AuthRememberMeRow(
                      remember: _rememberMe,
                      onRememberChanged: (v) =>
                          setState(() => _rememberMe = v),
                      onForgotPassword: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: AuthSpacing.lg),
                    // Log In button
                    MorphingLoadingButton(
                      label: 'Log In',
                      loading: _loading,
                      onPressed: _login,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AuthSpacing.lg),

          // ═══ Social: 2 full-width outlined buttons ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.24,
            child: Column(
              children: [
                AuthSocialButtonWide(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: const Color(0xFFEA4335),
                  onTap: () => _demoSnack('Google sign-in'),
                ),
                const SizedBox(height: AuthSpacing.sm),
                AuthSocialButtonWide(
                  label: 'Continue with Apple',
                  icon: Icons.apple_rounded,
                  iconColor: AppColors.darkTextPrimary,
                  onTap: () => _demoSnack('Apple sign-in'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.xl),

          // ═══ Sign up link (centered text — matches register's pattern) ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.32,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: AppColors.darkTextSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'New here? '),
                      TextSpan(
                        text: 'Create account',
                        style: TextStyle(
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AuthSpacing.lg),
        ],
      ),
    );
  }
}
