import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

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

// ═══ Shared label style used by AuthTextField + AuthPasswordField ═══
// A permanent label rendered ABOVE the field — never clips, never floats,
// never collides with the prefix icon. Same look on every auth screen.
const TextStyle _kFieldLabelStyle = TextStyle(
  fontFamily: 'PlusJakartaSans',
  fontSize: 12,
  fontWeight: FontWeight.w600,
  color: Color(0x80FFFFFF), // white @ 50%
  height: 1.2,
);

/// Solid surface card (not see-through glass). Used by all 3 auth screens.
/// Padding reduced from 20 to 18 for tighter, more spacious feel — fields
/// already have their own contentPadding so the card no longer needs a thick
/// inner margin.
class AuthGlassContainer extends StatelessWidget {
  final Widget child;
  const AuthGlassContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.darkBorder,
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

/// Full-width outlined social login/signup button — shared by Login + Register.
/// Same design on both screens so users recognise the pattern.
class AuthSocialButtonWide extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  const AuthSocialButtonWide({
    super.key,
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
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
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
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact icon-only social circle — kept for completeness (used if a layout
/// ever wants the icon-row variant).
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

/// Password field with show/hide toggle — uses the SAME permanent-label-above
/// design as AuthTextField so email/name/password all look identical.
/// Fixes:
///   • Floating label no longer clips into the prefix icon.
///   • Field height matches AuthTextField (theme's contentPadding).
///   • Label is always visible, even when field is focused or filled.
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.autofocus = false,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(widget.label, style: _kFieldLabelStyle),
        ),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: !_show,
          textInputAction: widget.textInputAction,
          autofocus: widget.autofocus,
          autofillHints: widget.autofillHints ?? const [AutofillHints.password],
          style: TextStyles.body(context).copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: widget.hint ?? '••••••••',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 16,
              letterSpacing: 4,
            ),
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              size: 20,
              color: Colors.white.withOpacity(0.7),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _show
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              onPressed: () => setState(() => _show = !_show),
            ),
            errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

/// Circular back button with glassmorphic bg — used on Register + Forgot Password.
class AuthBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const AuthBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Back',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
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
    this.iconColor = Colors.white,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryIndigo, AppColors.primaryPurple],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryIndigo.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: size),
    );
  }
}

/// Full-screen wrapper for ALL auth screens.
/// Clean dark gradient (#0B0F1A → #1B1240) + subtle purple glow.
/// Sets the system status bar to transparent with LIGHT icons so the
/// status-bar area never shows a bright blue color that clashes with the
/// dark theme (the bug the user reported).
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
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // Android
          statusBarBrightness: Brightness.dark, // iOS — light icons on dark bg
          systemNavigationBarColor: Color(0xFF0B0F1A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B0F1A), Color(0xFF1B1240)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Subtle purple glow behind logo position
                  Positioned(
                    top: 40,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryIndigo.withOpacity(0.15),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AuthSpacing.contentMaxWidth,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        // The Scaffold's default `resizeToAvoidBottomInset`
                        // already shrinks the body when the keyboard opens,
                        // and the SingleChildScrollView scrolls hidden
                        // fields into view — no manual viewInsets padding
                        // needed (that would double-offset the content).
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showBackButton) ...[
                              const SizedBox(height: AuthSpacing.sm),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AuthBackButton(
                                  onTap: onBack ??
                                      () => Navigator.of(context).maybePop(),
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
          child: Divider(
            color: Colors.white.withOpacity(0.18),
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: TextStyles.caption(context)
                .copyWith(color: Colors.white.withOpacity(0.6)),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.white.withOpacity(0.18),
            height: 1,
          ),
        ),
      ],
    );
  }
}

/// AuthTextField — shared, consistent text field with PERMANENT label above.
/// No floating label, no clip risk. Same height as AuthPasswordField because
/// both use the theme's contentPadding (no override here).
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
  final bool autofocus;

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
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: _kFieldLabelStyle),
        ),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          autofocus: autofocus,
          autofillHints: autofillHints,
          style: TextStyles.body(context).copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 14,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 20,
                    color: Colors.white.withOpacity(0.7),
                  )
                : null,
            suffixIcon: suffix,
            errorStyle: const TextStyle(
              color: AppColors.danger,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// AuthHeader — shared logo + heading + subtitle
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
        AuthFloatingLogo(
          icon: icon,
          iconColor: iconColor ?? AppColors.primaryIndigo,
        ),
        const SizedBox(height: AuthSpacing.md),
        Text(
          title,
          style: TextStyles.h1(context).copyWith(
            color: Colors.white,
            fontSize: titleSize,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyles.body(context, color: Colors.white.withOpacity(0.7)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// AuthFooterLink — shared glassmorphic CTA button + arrow
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  children: [
                    TextSpan(text: '$prompt '),
                    TextSpan(
                      text: action,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(arrow, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

/// AuthRememberMeRow — shared Remember-Me checkbox + Forgot-Password link row.
/// Wraps both in `Flexible` so the row never overflows on small screens.
class AuthRememberMeRow extends StatelessWidget {
  final bool remember;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onForgotPassword;
  const AuthRememberMeRow({
    super.key,
    required this.remember,
    required this.onRememberChanged,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remember me — flexible so it shrinks on narrow screens
        Flexible(
          child: GestureDetector(
            onTap: () => onRememberChanged(!remember),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: remember
                        ? AppColors.primaryIndigo
                        : Colors.transparent,
                    border: Border.all(
                      color: remember
                          ? AppColors.primaryIndigo
                          : AppColors.darkBorder,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: remember
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Remember me',
                    style: TextStyles.caption(context, weight: FontWeight.w500)
                        .copyWith(color: AppColors.darkTextSecondary),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Forgot password — flexible so it shrinks on narrow screens
        Flexible(
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              minimumSize: const Size(80, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password?',
              style: TextStyles.caption(context, weight: FontWeight.w700)
                  .copyWith(color: AppColors.primaryIndigo),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// AuthTermsRow — shared Terms-and-Privacy-Policy checkbox row.
/// Uses `crossAxisAlignment: CrossAxisAlignment.start` so the checkbox stays
/// anchored at the top of the first line while the RichText wraps to multiple
/// lines on small screens. The RichText is `Expanded` so it has full width
/// to wrap properly without overflow.
class AuthTermsRow extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final String promptText;
  final String termsLabel;
  final String privacyLabel;
  final String conjunctionText;
  const AuthTermsRow({
    super.key,
    required this.accepted,
    required this.onToggle,
    required this.onTermsTap,
    required this.onPrivacyTap,
    this.promptText = 'I accept the ',
    this.termsLabel = 'Terms',
    this.conjunctionText = ' and ',
    this.privacyLabel = 'Privacy Policy',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!accepted),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Checkbox — anchored to first line of text ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: accepted ? AppColors.primaryIndigo : Colors.transparent,
              border: Border.all(
                color: accepted
                    ? AppColors.primaryIndigo
                    : AppColors.darkBorder,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: accepted
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          // ── Terms text — Expanded so it can wrap on small screens ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    color: AppColors.darkTextSecondary,
                    height: 1.45,
                  ),
                  children: [
                    TextSpan(text: promptText),
                    TextSpan(
                      text: termsLabel,
                      style: TextStyle(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = onTermsTap,
                    ),
                    TextSpan(text: conjunctionText),
                    TextSpan(
                      text: privacyLabel,
                      style: TextStyle(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w700,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = onPrivacyTap,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
