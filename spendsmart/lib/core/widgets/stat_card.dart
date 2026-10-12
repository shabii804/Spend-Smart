import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'glass_card.dart';

/// Small stat card with a label + value. Used in analytics + dashboard.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconBg;
  final Color? iconColor;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconBg,
    this.iconColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconBg ?? AppColors.primaryIndigo).withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? (iconBg ?? AppColors.primaryIndigo),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(label, style: TextStyles.label(context)),
          const SizedBox(height: 4),
          Text(value, style: TextStyles.money(context, size: 20)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyles.caption(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tappable quick-action tile for the dashboard quick actions grid.
class QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionTile({
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
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyles.caption(context, weight: FontWeight.w600)
                    .copyWith(color: AppColorsOf.mainText(context)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
