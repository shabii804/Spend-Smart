import 'package:flutter/gestures.dart';
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
  bool _acceptTerms = false;
  bool _loading = false;
  bool _nameValid = false;
  bool _emailValid = false;
  bool _pwdValid = false;
  late final AnimationController _entrance = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    _nameCtrl.addListener(() {
      final v = _nameCtrl.text.trim().isNotEmpty;
      if (v != _nameValid) setState(() => _nameValid = v);
    });
    _emailCtrl.addListener(() {
      final v = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(_emailCtrl.text.trim());
      if (v != _emailValid) setState(() => _emailValid = v);
    });
    _pwdCtrl.addListener(() {
      final v = _pwdCtrl.text.length >= 8;
      if (v != _pwdValid) setState(() => _pwdValid = v);
    });
  }

  bool get _isFormValid => _nameValid && _emailValid && _pwdValid && _acceptTerms;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _pwdCtrl.dispose();
    _entrance.dispose();
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
          // ═══ Logo + heading ═══
          AuthStaggerItem(controller: _entrance, start: 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthFloatingLogo(icon: Icons.person_add_rounded),
                const SizedBox(height: AuthSpacing.md),
                Text('Create Account',
                    style: TextStyles.h1(context).copyWith(
                      color: AppColors.darkTextPrimary, fontSize: 26)),
                const SizedBox(height: 4),
                Text('Start your smart spending journey.',
                    style: TextStyles.body(context,
                        color: AppColors.darkTextSecondary)),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.md),

          // ═══ Form (solid surface card) ═══
          AuthStaggerItem(controller: _entrance, start: 0.12,
            child: AuthGlassContainer(
              child: Form(key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // Full Name
                  AuthTextField(
                    controller: _nameCtrl,
                    validator: Validators.required,
                    label: 'Full Name',
                    hint: 'Muhammad Shoaib',
                    prefixIcon: Icons.person_outline_rounded,
                    autofillHints: const [AutofillHints.name],
                  ),
                  const SizedBox(height: AuthSpacing.sm),
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
                  const SizedBox(height: AuthSpacing.sm),
                  // Password (single field — no confirm)
                  AuthPasswordField(
                    controller: _pwdCtrl,
                    label: 'Password',
                  ),
                  const SizedBox(height: AuthSpacing.xs),
                  // Strength meter + requirement hint
                  PasswordStrengthMeter(password: _pwdCtrl.text),
                  const SizedBox(height: 4),
                  Text('Use at least 8 characters',
                      style: TextStyles.caption(context)
                          .copyWith(color: AppColors.darkTextTertiary, fontSize: 11)),
                  const SizedBox(height: AuthSpacing.sm),
                  // Terms checkbox (24px) with tappable links
                  GestureDetector(
                    onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: 24, height: 24, margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _acceptTerms ? AppColors.primaryIndigo : Colors.transparent,
                          border: Border.all(
                            color: _acceptTerms ? AppColors.primaryIndigo : AppColors.darkBorder,
                            width: 1.5),
                          borderRadius: BorderRadius.circular(6)),
                        alignment: Alignment.center,
                        child: _acceptTerms
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                          : null),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'I accept the '),
                              TextSpan(
                                text: 'Terms',
                                style: TextStyle(color: AppColors.primaryIndigo, fontWeight: FontWeight.w700),
                                recognizer: TapGestureRecognizer()..onTap = () => _demoSnack('Terms'),
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: AppColors.primaryIndigo, fontWeight: FontWeight.w700),
                                recognizer: TapGestureRecognizer()..onTap = () => _demoSnack('Privacy Policy'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: AuthSpacing.md),
                  // Create Account button (DISABLED until form valid)
                  MorphingLoadingButton(
                    label: 'Create Account',
                    loading: _loading,
                    onPressed: _isFormValid ? _register : null,
                  ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: AuthSpacing.md),

          // ═══ Social: 2 full-width outlined buttons (matching login) ═══
          AuthStaggerItem(controller: _entrance, start: 0.24,
            child: Column(children: [
              _SocialButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                iconColor: const Color(0xFFEA4335),
                onTap: () => _demoSnack('Google sign-up'),
              ),
              const SizedBox(height: AuthSpacing.xs),
              _SocialButton(
                label: 'Continue with Apple',
                icon: Icons.apple_rounded,
                iconColor: AppColors.darkTextPrimary,
                onTap: () => _demoSnack('Apple sign-up'),
              ),
            ]),
          ),
          const SizedBox(height: AuthSpacing.lg),

          // ═══ Sign in link (simple centered text — matching login) ═══
          AuthStaggerItem(controller: _entrance, start: 0.32,
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: AppColors.darkTextSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign In',
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

/// Full-width outlined social button (matches login screen).
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
