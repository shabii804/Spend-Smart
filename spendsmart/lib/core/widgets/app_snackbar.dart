import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Premium snackbar with optional Undo action + haptic feedback.
/// Usage:
///   AppSnackbar.show(context, 'Expense deleted', actionLabel: 'Undo', onAction: () { ... });
///   AppSnackbar.show(context, 'Saved');
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: duration,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: AppColors.primaryIndigo,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onAction();
                  },
                )
              : null,
        ),
      );
  }

  static void undo(
    BuildContext context,
    String message,
    VoidCallback onUndo,
  ) {
    show(context, message, actionLabel: 'Undo', onAction: onUndo);
  }
}
