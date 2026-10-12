import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    vsync: this, duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _pwdCtrl.dispose(); _entrance.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.read<UserProvider>().updateUser(UserProfile(
      fullName: 'Muhammad Shoaib', email: _emailCtrl.text.trim(),
    ));
    await showPremiumSuccess(context);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()), (_) => false,
    );
  }

  void _demoSnack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — ${AppStrings.demoOnly}')));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══ Logo + heading ═══
          AuthStaggerItem(controller: _entrance, start: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthFloatingLogo(icon: Icons.account_balance_wallet_rounded),
                const SizedBox(height: AuthSpacing.md),
                Text('Welcome Back',
                    style: TextStyles.h1(context).copyWith(
                      color: AppColors.darkTextPrimary, fontSize: 28)),
                const SizedBox(height: 6),
                Text('Log in to keep tracking your spending.',
                    style: TextStyles.body(context,
                        color: AppColors.darkTextSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.lg),

          // ═══ Form (solid surface card) ═══
          AuthStaggerItem(controller: _entrance, start: 0.12,
            child: AuthGlassContainer(
              child: Form(key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Email
                  AuthTextField(
                    controller: _emailCtrl,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    label: 'Email',
                    hint: 'you@example.com',
                    prefixIcon: Icons.alternate_email_rounded,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: AuthSpacing.md),
                  // Password
                  AuthPasswordField(
                    controller: _pwdCtrl,
                    label: 'Password',
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AuthSpacing.sm),
                  // Remember me + Forgot password
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    GestureDetector(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            color: _rememberMe ? AppColors.primaryIndigo : Colors.transparent,
                            border: Border.all(
                              color: _rememberMe ? AppColors.primaryIndigo : AppColors.darkBorder,
                              width: 1.5),
                            borderRadius: BorderRadius.circular(6)),
                          alignment: Alignment.center,
                          child: _rememberMe
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                            : null),
                        const SizedBox(width: 8),
                        Text('Remember me',
                            style: TextStyles.caption(context, weight: FontWeight.w500)
                                .copyWith(color: AppColors.darkTextSecondary)),
                      ]),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        minimumSize: const Size(80, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Forgot Password?',
                          style: TextStyles.caption(context, weight: FontWeight.w700)
                              .copyWith(color: AppColors.primaryIndigo)),
                    ),
                  ]),
                  const SizedBox(height: AuthSpacing.lg),
                  // Log In button
                  MorphingLoadingButton(
                    label: 'Log In', loading: _loading, onPressed: _login),
                ]),
              ),
            ),
          ),
          const SizedBox(height: AuthSpacing.lg),

          // ═══ Social: 2 full-width outlined buttons (Google + Apple only) ═══
          AuthStaggerItem(controller: _entrance, start: 0.24,
            child: Column(children: [
              _SocialButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                iconColor: const Color(0xFFEA4335),
                onTap: () => _demoSnack('Google sign-in'),
              ),
              const SizedBox(height: AuthSpacing.sm),
              _SocialButton(
                label: 'Continue with Apple',
                icon: Icons.apple_rounded,
                iconColor: AppColors.darkTextPrimary,
                onTap: () => _demoSnack('Apple sign-in'),
              ),
            ]),
          ),
          const SizedBox(height: AuthSpacing.xl),

          // ═══ Sign up link (simple centered text) ═══
          AuthStaggerItem(controller: _entrance, start: 0.32,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: RichText(
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

/// Full-width outlined social login button.
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () { HapticFeedback.lightImpact(); onTap(); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AppColors.darkBorder, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 10),
              Text(label,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
