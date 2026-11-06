import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../constants/app_constants.dart';
import '../motion/app_motion.dart';

/// Floating pill bottom navigation with:
/// - BackdropFilter blur (85% opaque surface — labels always readable)
/// - Center FAB docked INSIDE a notch (never overlaps labels)
/// - Active tab: bouncing spring icon + gradient glow + label + indicator dot
/// - Upgraded micro-animations: FAB tactile spring press & rotation + haptics
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onFabPressed;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            // ── Nav pill with blur ──
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.navBarHeight / 2),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: AppConstants.navBarHeight,
                  decoration: BoxDecoration(
                    color: surfaceColor.withOpacity(0.85),
                    borderRadius:
                        BorderRadius.circular(AppConstants.navBarHeight / 2),
                    border: isDark
                        ? Border.all(color: AppColors.darkBorder, width: 1)
                        : Border.all(color: AppColors.lightBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _NavSlot(
                          label: 'Home',
                          icon: Icons.home_rounded,
                          selected: currentIndex == 0,
                          onTap: () => onTabSelected(0),
                        ),
                      ),
                      Expanded(
                        child: _NavSlot(
                          label: 'Activity',
                          icon: Icons.receipt_long_rounded,
                          selected: currentIndex == 1,
                          onTap: () => onTabSelected(1),
                        ),
                      ),
                      // Gap for FAB
                      const SizedBox(width: AppConstants.fabSize + 8),
                      Expanded(
                        child: _NavSlot(
                          label: 'Analytics',
                          icon: Icons.insights_rounded,
                          selected: currentIndex == 2,
                          onTap: () => onTabSelected(2),
                        ),
                      ),
                      Expanded(
                        child: _NavSlot(
                          label: 'More',
                          icon: Icons.more_horiz_rounded,
                          selected: currentIndex == 3,
                          onTap: () => onTabSelected(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── FAB docked on top center (creates notch effect) ──
            Positioned(
              top: -18,
              child: _FabButton(onTap: onFabPressed),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavSlot extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavSlot({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavSlot> createState() => _NavSlotState();
}

class _NavSlotState extends State<_NavSlot>
    with TickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  late final AnimationController _selectAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 360),
  );

  late final Animation<double> _iconBounce = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.0, end: 1.25)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.25, end: 0.94)
          .chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.94, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 25,
    ),
  ]).animate(_selectAnim);

  @override
  void initState() {
    super.initState();
    if (widget.selected) {
      _selectAnim.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _NavSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.selected && widget.selected) {
      _selectAnim.forward(from: 0.0);
    } else if (oldWidget.selected && !widget.selected) {
      _selectAnim.reverse();
    }
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.selected) _press.forward();
  }

  void _onTapUp(TapUpDetails _) => _press.reverse();
  void _onTapCancel() => _press.reverse();

  @override
  void dispose() {
    _press.dispose();
    _selectAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reduceMotion(context);
    const activeColor = AppColors.primaryIndigo;
    final inactiveColor = AppColorsOf.secondaryText(context);
    final color = widget.selected ? activeColor : inactiveColor;

    return Semantics(
      label: widget.label,
      button: true,
      selected: widget.selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([_press, _selectAnim]),
          builder: (context, child) {
            final pressScale = 1.0 - (_press.value * 0.12);
            return Transform.scale(
              scale: pressScale,
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Upgraded Icon Container with spring bounce & glowing pill
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: widget.selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryIndigo.withOpacity(0.18),
                            AppColors.primaryPurple.withOpacity(0.10),
                          ],
                        )
                      : null,
                  color: widget.selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: widget.selected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryIndigo.withOpacity(0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: AnimatedBuilder(
                  animation: _iconBounce,
                  builder: (context, iconChild) {
                    final scale = reduceMotion
                        ? 1.0
                        : (widget.selected ? _iconBounce.value : 1.0);
                    return Transform.scale(
                      scale: scale,
                      child: iconChild,
                    );
                  },
                  child: Icon(widget.icon, size: 21, color: color),
                ),
              ),
              const SizedBox(height: 3),
              // Animated Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: color,
                  fontSize: 10.5,
                  fontWeight:
                      widget.selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(widget.label),
              ),
              // Animated Indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                width: widget.selected ? 5 : 0,
                height: widget.selected ? 5 : 0,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: widget.selected ? AppColors.mint : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: widget.selected
                      ? [
                          BoxShadow(
                            color: AppColors.mint.withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FabButton extends StatefulWidget {
  final VoidCallback onTap;
  const _FabButton({required this.onTap});

  @override
  State<_FabButton> createState() => _FabButtonState();
}

class _FabButtonState extends State<_FabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _anim.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = AppMotion.reduceMotion(context);

    return GestureDetector(
      onTapDown: (_) {
        if (!reduceMotion) _anim.animateTo(0.25, duration: const Duration(milliseconds: 80));
      },
      onTapUp: (_) {
        if (!reduceMotion) _anim.forward();
      },
      onTapCancel: () {
        if (!reduceMotion) _anim.reverse();
      },
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) {
          // Subtle scale and rotation on tap
          final t = _anim.value;
          final scale = reduceMotion ? 1.0 : (1.0 - 0.08 * (1.0 - (2 * t - 1).abs()));
          final angle = reduceMotion ? 0.0 : (t * 1.5708); // 90 degree spin
          return Transform.scale(
            scale: scale,
            child: Container(
              width: AppConstants.fabSize,
              height: AppConstants.fabSize,
              decoration: BoxDecoration(
                gradient: AppGradients.fab,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x55635BFF),
                    blurRadius: 22 + (4 * t),
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: angle,
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
            ),
          );
        },
      ),
    );
  }
}
