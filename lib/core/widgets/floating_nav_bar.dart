import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/text_styles.dart';
import '../constants/app_constants.dart';

/// Floating pill bottom navigation bar with central gradient FAB.
/// Spec: 5 slots (Home, Transactions, [FAB], Goals, Profile).
/// Light: white + soft shadow | Dark: #101D30 + subtle border.
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          AppConstants.navBarBottomMargin,
        ),
        child: AnimatedContainer(
          duration: AppConstants.durMed,
          curve: AppConstants.curveDefault,
          height: AppConstants.navBarHeight,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.navBarHeight / 2),
            border: isDark
                ? Border.all(color: AppColors.darkBorder, width: 1)
                : null,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF14213D).withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
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
              SizedBox(
                width: AppConstants.fabSize + 8,
                child: _FabButton(onTap: onFabPressed),
              ),
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
    );
  }
}

class _NavSlot extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final activeColor = AppColors.primaryIndigo;
    final inactiveColor = AppColorsOf.secondaryText(context);
    final color = selected ? activeColor : inactiveColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedScale(
          scale: selected ? 1.05 : 1.0,
          duration: AppConstants.durFast,
          curve: AppConstants.curveDefault,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Soft pill highlight behind the icon when selected.
              AnimatedContainer(
                duration: AppConstants.durFast,
                curve: AppConstants.curveDefault,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryIndigo.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyles.caption(context).copyWith(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 120),
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
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
