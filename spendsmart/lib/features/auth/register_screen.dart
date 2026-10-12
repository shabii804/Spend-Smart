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
    vsync: this, duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    _pwdCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _pwdCtrl.dispose();
    _confirmCtrl.dispose(); _entrance.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.errAcceptTerms)));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    context.read<UserProvider>().updateUser(UserProfile(
      fullName: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(),
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
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ═══ Logo + heading (compact — fits screen) ═══
          AuthStaggerItem(controller: _entrance, start: 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthFloatingLogo(icon: Icons.person_add_rounded),
                const SizedBox(height: 10),
                Text('Create Account',
                    style: TextStyles.h2(context).copyWith(
                      color: Colors.white, fontSize: 22, letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text('Start your smart spending journey.',
                    style: TextStyles.caption(context)
                        .copyWith(color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ═══ Form (glassmorphic — compact spacing) ═══
          AuthStaggerItem(controller: _entrance, start: 0.12,
            child: AuthGlassContainer(
              child: Form(key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Full name
                  TextFormField(
                    controller: _nameCtrl, validator: Validators.required,
                    textInputAction: TextInputAction.next,
                    style: TextStyles.body(context).copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      floatingLabelStyle: TextStyle(color: AppColors.primaryIndigo.withOpacity(0.9)),
                      hintText: 'Muhammad Shoaib',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
                      prefixIcon: Icon(Icons.person_outline_rounded,
                          size: 20, color: Colors.white.withOpacity(0.5)),
                      errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Password + strength meter
                  AuthPasswordField(controller: _pwdCtrl, label: 'Password'),
                  const SizedBox(height: 4),
                  PasswordStrengthMeter(password: _pwdCtrl.text),
                  const SizedBox(height: 10),
                  // Confirm password
                  AuthPasswordField(controller: _confirmCtrl, label: 'Confirm Password',
                      validator: (v) => Validators.confirmPassword(v, _pwdCtrl.text)),
                  const SizedBox(height: 10),
                  // Terms
                  GestureDetector(
                    onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: 20, height: 20, margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _acceptTerms ? AppColors.primaryIndigo : Colors.transparent,
                          border: Border.all(
                            color: _acceptTerms ? AppColors.primaryIndigo : Colors.white.withOpacity(0.3),
                            width: 1.5),
                          borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.center,
                        child: _acceptTerms
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                          : null),
                      const SizedBox(width: 10),
                      Expanded(child: Text(AppStrings.acceptTerms,
                          style: TextStyles.caption(context)
                              .copyWith(color: Colors.white.withOpacity(0.8)))),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  // Create Account button
                  MorphingLoadingButton(
                    label: 'Create Account', loading: _loading, onPressed: _register),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ═══ Social (icon-only circles — compact) ═══
          AuthStaggerItem(controller: _entrance, start: 0.24,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _SocialCircle(icon: Icons.g_mobiledata_rounded,
                  color: const Color(0xFFEA4335),
                  onTap: () => _demoSnack('Google sign-up')),
              const SizedBox(width: 14),
              _SocialCircle(icon: Icons.apple_rounded,
                  color: Colors.white,
                  onTap: () => _demoSnack('Apple sign-up')),
              const SizedBox(width: 14),
              _SocialCircle(icon: Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                  onTap: () => _demoSnack('Facebook sign-up')),
            ]),
          ),
          const SizedBox(height: 20),

          // ═══ Sign in CTA (glassmorphic + arrow) ═══
          AuthStaggerItem(controller: _entrance, start: 0.32,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Already have an account? ',
                      style: TextStyles.caption(context)
                          .copyWith(color: Colors.white.withOpacity(0.6))),
                  const SizedBox(width: 4),
                  Text('Sign In',
                      style: TextStyles.body(context, weight: FontWeight.w700)
                          .copyWith(color: Colors.white)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 16),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}
