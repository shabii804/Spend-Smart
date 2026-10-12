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
  // Track password text so the strength meter rebuilds on every keystroke
  // (not only when validity changes).
  String _pwdText = '';
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
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
      final v = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$')
          .hasMatch(_emailCtrl.text.trim());
      if (v != _emailValid) setState(() => _emailValid = v);
    });
    // Password listener — update validity AND the live strength meter text.
    // This ensures the PasswordStrengthMeter (StatelessWidget) rebuilds
    // whenever the password changes, not just when validity crosses the
    // 8-char threshold.
    _pwdCtrl.addListener(() {
      final v = _pwdCtrl.text.length >= 8;
      if (v != _pwdValid) {
        setState(() {
          _pwdValid = v;
          _pwdText = _pwdCtrl.text;
        });
      } else {
        // Even if validity didn't change, the meter still needs to rebuild.
        setState(() => _pwdText = _pwdCtrl.text);
      }
    });
  }

  bool get _isFormValid => _nameValid && _emailValid && _pwdValid && _acceptTerms;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
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
          // ═══ Logo + heading ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.05,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AppLogo(size: 72, variant: AppLogoVariant.markOnly),
                const SizedBox(height: AuthSpacing.md),
                Text(
                  'Create Account',
                  style: TextStyles.h1(context).copyWith(
                    color: AppColors.darkTextPrimary,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start your smart spending journey.',
                  style: TextStyles.body(context,
                      color: AppColors.darkTextSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.md),

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
                    // Full Name
                    AuthTextField(
                      controller: _nameCtrl,
                      validator: Validators.required,
                      label: 'Full Name',
                      hint: 'Muhammad Shoaib',
                      prefixIcon: Icons.person_outline_rounded,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AuthSpacing.md),
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
                    // Password — same permanent-label design as other fields.
                    AuthPasswordField(
                      controller: _pwdCtrl,
                      label: 'Password',
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AuthSpacing.xs),
                    // Strength meter — now updates on every keystroke because
                    // _pwdText is rebuilt via setState in the listener above.
                    // Removed the redundant "Use at least 8 characters" hint
                    // because the meter's "Too short" label already conveys
                    // that — single source of truth, less crowding.
                    PasswordStrengthMeter(password: _pwdText),
                    const SizedBox(height: AuthSpacing.sm),

                    // Terms checkbox — uses the shared AuthTermsRow widget so
                    // the checkbox stays top-anchored and the RichText wraps
                    // cleanly on small screens.
                    AuthTermsRow(
                      accepted: _acceptTerms,
                      onToggle: (v) {
                        HapticFeedback.selectionClick();
                        setState(() => _acceptTerms = v);
                      },
                      onTermsTap: () => _demoSnack('Terms'),
                      onPrivacyTap: () => _demoSnack('Privacy Policy'),
                    ),
                    const SizedBox(height: AuthSpacing.md),

                    // Create Account button — DISABLED until form is valid.
                    // Sits below the terms section with breathing room.
                    MorphingLoadingButton(
                      label: 'Create Account',
                      loading: _loading,
                      onPressed: _isFormValid ? _register : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AuthSpacing.md),

          // ═══ Social: 2 full-width outlined buttons (matching login) ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.24,
            child: Column(
              children: [
                AuthSocialButtonWide(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  iconColor: const Color(0xFFEA4335),
                  onTap: () => _demoSnack('Google sign-up'),
                ),
                const SizedBox(height: AuthSpacing.sm),
                AuthSocialButtonWide(
                  label: 'Continue with Apple',
                  icon: Icons.apple_rounded,
                  iconColor: AppColors.darkTextPrimary,
                  onTap: () => _demoSnack('Apple sign-up'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.lg),

          // ═══ Sign in link (centered text — matching login) ═══
          AuthStaggerItem(
            controller: _entrance,
            start: 0.32,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
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
