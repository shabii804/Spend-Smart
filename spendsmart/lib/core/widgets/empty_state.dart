import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// Illustration-style empty state used by transactions + notifications.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? tint;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final c = tint ?? AppColors.primaryIndigo;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: c.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 32, color: c),
              ),
            ),
            const SizedBox(height: 18),
            Text(title, style: TextStyles.h3(context)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyles.caption(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
