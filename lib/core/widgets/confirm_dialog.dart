import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../constants/app_strings.dart';

/// Reusable confirmation dialog. Used for delete + logout.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool danger;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    this.confirmLabel = AppStrings.confirm,
    this.cancelLabel = AppStrings.cancel,
    this.danger = false,
    this.icon,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String body,
    String confirmLabel = AppStrings.confirm,
    String cancelLabel = AppStrings.cancel,
    bool danger = false,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        danger: danger,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = danger ? AppColors.danger : AppColors.primaryIndigo;
    return AlertDialog(
      icon: icon != null
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 26),
            )
          : null,
      title: Text(title, textAlign: TextAlign.center),
      content: Text(body, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColorsOf.secondaryText(context),
              side: BorderSide(color: AppColorsOf.border(context), width: 1),
            ),
            child: Text(cancelLabel),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(confirmLabel,
                style: TextStyles.body(context).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ),
      ],
    );
  }
}
