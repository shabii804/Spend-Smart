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
      SnackBar(content: Text('$label — ${AppStrings.demoOnly}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══ Logo + heading merged (premium compact) ═══
          AuthStaggerItem(controller: _entrance, start: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthFloatingLogo(icon: Icons.account_balance_wallet_rounded),
                const SizedBox(height: 16),
                Text('Welcome Back',
                    style: TextStyles.h1(context).copyWith(
                      color: Colors.white, fontSize: 28, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Log in to keep tracking your spending.',
                    style: TextStyles.body(context,
                        color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ═══ Form (glassmorphic) ═══
          AuthStaggerItem(controller: _entrance, start: 0.12,
            child: AuthGlassContainer(
              child: Form(key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Email
                  TextFormField(
                    controller: _emailCtrl, validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
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
                  const SizedBox(height: 16),
                  // Password
                  AuthPasswordField(controller: _pwdCtrl, label: 'Password',
                      textInputAction: TextInputAction.done),
                  const SizedBox(height: 14),
                  // Remember me + Forgot
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
                              color: _rememberMe ? AppColors.primaryIndigo : Colors.white.withOpacity(0.3),
                              width: 1.5),
                            borderRadius: BorderRadius.circular(6)),
                          alignment: Alignment.center,
                          child: _rememberMe
                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                            : null),
                        const SizedBox(width: 8),
                        Text('Remember me',
                            style: TextStyles.caption(context, weight: FontWeight.w500)
                                .copyWith(color: Colors.white.withOpacity(0.8))),
                      ]),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('Forgot Password?',
                          style: TextStyles.caption(context, weight: FontWeight.w700)
                              .copyWith(color: AppColors.primaryIndigo)),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // Login button (primary CTA)
                  MorphingLoadingButton(
                    label: 'Log In', loading: _loading, onPressed: _login),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ═══ Social (icon-only circles — premium) ═══
          AuthStaggerItem(controller: _entrance, start: 0.24,
            child: Column(children: [
              Text('or continue with',
                  style: TextStyles.caption(context)
                      .copyWith(color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _SocialCircle(
                  icon: Icons.g_mobiledata_rounded,
                  color: const Color(0xFFEA4335),
                  onTap: () => _demoSnack('Google sign-in')),
                const SizedBox(width: 16),
                _SocialCircle(
                  icon: Icons.apple_rounded,
                  color: Colors.white,
                  onTap: () => _demoSnack('Apple sign-in')),
                const SizedBox(width: 16),
                _SocialCircle(
                  icon: Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                  onTap: () => _demoSnack('Facebook sign-in')),
              ]),
            ]),
          ),
          const SizedBox(height: 32),
          // ═══ Signup CTA (prominent) ═══
          AuthStaggerItem(controller: _entrance, start: 0.32,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? ",
                      style: TextStyles.body(context)
                          .copyWith(color: Colors.white.withOpacity(0.6))),
                  const SizedBox(width: 4),
                  Text('Sign Up',
                      style: TextStyles.body(context, weight: FontWeight.w700)
                          .copyWith(color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
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
}

/// Premium social login circle — icon only, no text label.
class _SocialCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialCircle({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 24, color: color),
        ),
      ),
    );
  }
}
