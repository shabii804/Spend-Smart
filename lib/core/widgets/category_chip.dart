import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../constants/app_constants.dart';

/// Selectable category chip — small rounded tile with icon + name.
class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusChip),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppConstants.durFast,
          curve: AppConstants.curveDefault,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.14)
                : AppColorsOf.card(context),
            border: Border.all(
              color: selected ? color : AppColorsOf.border(context),
              width: selected ? 1.4 : 1,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusChip),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyles.caption(context).copyWith(
                  color: selected ? color : AppColorsOf.mainText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
