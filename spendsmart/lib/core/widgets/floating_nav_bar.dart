import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/text_styles.dart';
import '../constants/app_constants.dart';

/// Floating pill bottom navigation with:
/// - BackdropFilter blur (85% opaque surface — labels always readable)
/// - Center FAB docked INSIDE a notch (never overlaps labels)
/// - Active tab: filled icon + label + small indicator dot
/// - Haptic feedback on tab change + FAB press
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
                      SizedBox(width: AppConstants.fabSize + 8),
                      Expanded(
                        child: _NavSlot(
                          label: 'Goals',
                          icon: Icons.savings_rounded,
                          selected: currentIndex == 2,
                          onTap: () => onTabSelected(2),
                        ),
                      ),
                      Expanded(
                        child: _NavSlot(
                          label: 'Profile',
                          icon: Icons.person_rounded,
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  void _onTapDown(TapDownDetails _) {
    if (!widget.selected) _press.forward();
  }

  void _onTapUp(TapUpDetails _) => _press.reverse();
  void _onTapCancel() => _press.reverse();

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primaryIndigo;
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
          animation: _press,
          builder: (context, child) {
            final pressScale = 1.0 - (_press.value * 0.14);
            return AnimatedScale(
              scale: widget.selected ? 1.06 : pressScale,
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: child,
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.selected
                      ? AppColors.primaryIndigo.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, size: 20, color: color),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: color,
                  fontSize: 10.5,
                  fontWeight:
                      widget.selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              // Indicator dot (only when selected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: widget.selected ? 4 : 0,
                height: widget.selected ? 4 : 0,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: widget.selected ? AppColors.mint : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  final VoidCallback onTap;
  const _FabButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: AppConstants.fabSize,
        height: AppConstants.fabSize,
        decoration: BoxDecoration(
          gradient: AppGradients.fab,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x40635BFF),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}
