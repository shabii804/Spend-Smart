import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/success_overlay.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../dashboard/main_shell.dart';
import 'login_screen.dart';

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
    await SuccessOverlay.show(context, label: 'Account created!');
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
    return Theme(
      // Force dark theme so form fields render white over the bg image
      data: Theme.of(context).copyWith(brightness: Brightness.dark),
      child: Scaffold(
        body: Container(
          // Premium background image (same as login)
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/auth_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            // Dark gradient overlay for readability
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.42),
                  Colors.black.withOpacity(0.18),
                  AppColors.darkBackground.withOpacity(0.78),
                  AppColors.darkBackground.withOpacity(0.96),
                ],
                stops: const [0.0, 0.32, 0.62, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Back button (top-left)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _StaggerItem(
                        controller: _entrance,
                        start: 0.0,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.18),
                                  width: 1),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Floating logo + brand
                    _StaggerItem(
                      controller: _entrance,
                      start: 0.05,
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.32),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: AppColors.primaryIndigo,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text('Create Account',
                              style: TextStyles.h2(context)
                                  .copyWith(color: Colors.white, fontSize: 26)),
                          const SizedBox(height: 4),
                          Text(AppStrings.createAccountSubtitle,
                              style: TextStyles.caption(context)
                                  .copyWith(color: Colors.white.withOpacity(0.85)),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Form on glassmorphic container
                    _StaggerItem(
                      controller: _entrance,
                      start: 0.15,
                      child: _GlassContainer(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                label: AppStrings.fullName,
                                controller: _nameCtrl,
                                validator: Validators.required,
                                prefix: Icon(Icons.person_outline_rounded,
                                    size: 20, color: Colors.white.withOpacity(0.7)),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                label: AppStrings.email,
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validators.email,
                                prefix: Icon(Icons.alternate_email_rounded,
                                    size: 20, color: Colors.white.withOpacity(0.7)),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              _PasswordField(
                                controller: _pwdCtrl,
                                label: AppStrings.password,
                              ),
                              const SizedBox(height: 16),
                              _PasswordField(
                                controller: _confirmCtrl,
                                label: AppStrings.confirmPassword,
                                validator: (v) =>
                                    Validators.confirmPassword(v, _pwdCtrl.text),
                              ),
                              const SizedBox(height: 16),
                              // Terms checkbox
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _acceptTerms = !_acceptTerms),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: _acceptTerms
                                            ? AppColors.primaryIndigo
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: _acceptTerms
                                              ? AppColors.primaryIndigo
                                              : Colors.white.withOpacity(0.35),
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      margin: const EdgeInsets.only(top: 2),
                                      alignment: Alignment.center,
                                      child: _acceptTerms
                                          ? const Icon(Icons.check_rounded,
                                              color: Colors.white, size: 14)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        AppStrings.acceptTerms,
                                        style: TextStyles.caption(context)
                                            .copyWith(
                                                color: Colors.white
                                                    .withOpacity(0.85)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              PrimaryButton(
                                label: AppStrings.createAccount,
                                loading: _loading,
                                onPressed: _register,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Divider
                    _StaggerItem(
                      controller: _entrance,
                      start: 0.25,
                      child: Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: Colors.white.withOpacity(0.18),
                                  height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(AppStrings.orContinueWith,
                                style: TextStyles.caption(context)
                                    .copyWith(color: Colors.white.withOpacity(0.6))),
                          ),
                          Expanded(
                              child: Divider(
                                  color: Colors.white.withOpacity(0.18),
                                  height: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Social buttons
                    _StaggerItem(
                      controller: _entrance,
                      start: 0.3,
                      child: Row(
                        children: [
                          Expanded(
                            child: _SocialButton(
                              label: 'Google',
                              icon: Icons.g_mobiledata_rounded,
                              color: const Color(0xFFEA4335),
                              onTap: () => _demoSnack('Google sign-up'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SocialButton(
                              label: 'Apple',
                              icon: Icons.apple_rounded,
                              color: Colors.white,
                              onTap: () => _demoSnack('Apple sign-up'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SocialButton(
                              label: 'Facebook',
                              icon: Icons.facebook_rounded,
                              color: const Color(0xFF1877F2),
                              onTap: () => _demoSnack('Facebook sign-up'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Sign in link
                    _StaggerItem(
                      controller: _entrance,
                      start: 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppStrings.alreadyHaveAccount,
                              style: TextStyles.caption(context)
                                  .copyWith(color: Colors.white.withOpacity(0.7))),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            ),
                            child: Text(
                              AppStrings.signIn,
                              style: TextStyles.caption(context,
                                      weight: FontWeight.w700)
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphic container — frosted-glass style card over the bg image.
class _GlassContainer extends StatelessWidget {
  final Widget child;
  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StaggerItem extends StatelessWidget {
  final AnimationController controller;
  final double start;
  final Widget child;
  const _StaggerItem({
    required this.controller,
    required this.start,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: controller,
      curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(anim),
        child: child,
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  const _PasswordField({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _show = false;
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      validator: widget.validator ?? Validators.password,
      obscureText: !_show,
      prefix: Icon(Icons.lock_outline_rounded, size: 20,
          color: Colors.white.withOpacity(0.7)),
      suffix: IconButton(
        icon: Icon(
          _show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        onPressed: () => setState(() => _show = !_show),
      ),
      textInputAction: TextInputAction.next,
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    style: TextStyles.body(context, weight: FontWeight.w600)
                        .copyWith(color: Colors.white, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
