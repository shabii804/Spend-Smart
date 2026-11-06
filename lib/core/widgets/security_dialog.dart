import 'package:flutter/material.dart';

import '../../providers/user_provider.dart';
import '../motion/haptics.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

/// Security & Privacy dialog — toggles biometric authentication and the
/// 4-digit app-lock PIN. When either is enabled the main shell gates the
/// app behind [AppLockScreen] on launch.
void showSecurityDialog(BuildContext context, UserProvider userProvider) {
  Haptics.selection();
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final u = userProvider.user;
        return AlertDialog(
          backgroundColor: AppColorsOf.card(ctx),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, color: AppColors.mint, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Security & Privacy', style: TextStyles.h3(ctx)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text('Biometric Authentication',
                    style: TextStyles.body(ctx, weight: FontWeight.w600)),
                subtitle: Text('Face ID / Fingerprint on launch',
                    style: TextStyles.caption(ctx)),
                value: u.biometricsEnabled,
                activeColor: AppColors.mint,
                onChanged: (val) {
                  Haptics.selection();
                  userProvider.toggleBiometrics(val);
                  setDialogState(() {});
                },
              ),
              const Divider(),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text('App Lock PIN',
                    style: TextStyles.body(ctx, weight: FontWeight.w600)),
                subtitle: Text('Require 4-digit PIN for access',
                    style: TextStyles.caption(ctx)),
                value: u.appLockEnabled,
                activeColor: AppColors.primaryIndigo,
                onChanged: (val) {
                  Haptics.selection();
                  userProvider.toggleAppLock(val);
                  setDialogState(() {});
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    ),
  );
}
