import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/premium_motion.dart';

/// Shared auth components used by Login, Register, and Forgot Password screens.
/// Keeping these in ONE file guarantees visual consistency across all auth screens.

// ═══ Centralized spacing + sizing tokens ═══
class AuthSpacing {
  AuthSpacing._();
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double contentMaxWidth = 440;
  static const double fieldHeight = 56;
  static const double buttonHeight = 54;
}

/// Glassmorphic container — frosted-glass style card over the bg image.
/// Used by all 3 auth screens to wrap form fields.
class AuthGlassContainer extends StatelessWidget {
  final Widget child;
  const AuthGlassContainer({super.key, required this.child});

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

/// Staggered entrance animation — fade + slide up.
/// Used by all 3 auth screens for consistent entrance feel.
class AuthStaggerItem extends StatelessWidget {
  final AnimationController controller;
  final double start;
  final Widget child;
  const AuthStaggerItem({
    super.key,
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

/// Social login/signup button — consistent across Login + Register.
class AuthSocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const AuthSocialButton({
    super.key,
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

/// Password field with show/hide toggle — consistent across Login + Register.
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _show = false;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: !_show,
      textInputAction: widget.textInputAction,
      style: TextStyles.body(context).copyWith(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
        prefixIcon: Icon(Icons.lock_outline_rounded, size: 20,
            color: Colors.white.withOpacity(0.7)),
        suffixIcon: IconButton(
          icon: Icon(
            _show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          onPressed: () => setState(() => _show = !_show),
        ),
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
      ),
    );
  }
}

/// Circular back button with glassmorphic bg — used on Register + Forgot Password.
class AuthBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const AuthBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

/// Dark gradient overlay used over the background image on all auth screens.
/// Keeps text readable regardless of the app's light/dark theme setting.
class AuthBackgroundOverlay extends StatelessWidget {
  final Widget child;
  const AuthBackgroundOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

/// Floating circular logo with white bg + drop shadow.
class AuthFloatingLogo extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  const AuthFloatingLogo({
    super.key,
    required this.icon,
    this.iconColor = AppColors.primaryIndigo,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Icon(icon, color: iconColor, size: size),
    );
  }
}

/// Full-screen wrapper for ALL auth screens.
/// Handles: dark theme override, background image, gradient overlay,
/// SafeArea, scroll, horizontal padding. Guarantees identical structure.
class AuthScreenScaffold extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;
  const AuthScreenScaffold({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(brightness: Brightness.dark),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/auth_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: AuthBackgroundOverlay(
            child: SafeArea(
              child: Stack(
                children: [
                  // Ambient floating shapes behind content
                  const Positioned.fill(
                    child: AmbientBackgroundAnimation(),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: AuthSpacing.contentMaxWidth),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showBackButton) ...[
                              const SizedBox(height: AuthSpacing.sm),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AuthBackButton(
                                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                                ),
                              ),
                              const SizedBox(height: AuthSpacing.xs),
                            ] else
                              const SizedBox(height: AuthSpacing.lg),
                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Divider row with "or continue with" text — shared by Login + Register.
class AuthDividerRow extends StatelessWidget {
  final String label;
  const AuthDividerRow({super.key, this.label = 'or continue with'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.18), height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label,
              style: TextStyles.caption(context)
                  .copyWith(color: Colors.white.withOpacity(0.6))),
        ),
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.18), height: 1),
        ),
      ],
    );
  }
}

// ═══ AuthTextField — shared, consistent text field with floating label ═══
class AuthTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final Iterable<String>? autofillHints;

  const AuthTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.suffix,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autofillHints: autofillHints,
      style: TextStyles.body(context).copyWith(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        floatingLabelStyle:
            TextStyle(color: AppColors.primaryIndigo.withOpacity(0.9)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: Colors.white.withOpacity(0.5))
            : null,
        suffixIcon: suffix,
        errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// ═══ AuthSocialCircle — shared icon-only social login circle ═══
class AuthSocialCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;
  const AuthSocialCircle({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(size),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: size,
          height: size,
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

// ═══ AuthHeader — shared logo + heading + subtitle ═══
class AuthHeader extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final double titleSize;
  const AuthHeader({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AuthFloatingLogo(icon: icon, iconColor: iconColor ?? AppColors.primaryIndigo),
        const SizedBox(height: AuthSpacing.md),
        Text(title,
            style: TextStyles.h1(context).copyWith(
              color: Colors.white, fontSize: titleSize, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: TextStyles.body(context, color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center),
      ],
    );
  }
}

// ═══ AuthFooterLink — shared glassmorphic CTA button + arrow ═══
class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String action;
  final IconData arrow;
  final VoidCallback onTap;
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    this.arrow = Icons.arrow_forward_rounded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(prompt,
              style: TextStyles.body(context)
                  .copyWith(color: Colors.white.withOpacity(0.6))),
          const SizedBox(width: 4),
          Text(action,
              style: TextStyles.body(context, weight: FontWeight.w700)
                  .copyWith(color: Colors.white)),
          const SizedBox(width: 6),
          Icon(arrow, color: Colors.white, size: 18),
        ]),
      ),
    );
  }
}
