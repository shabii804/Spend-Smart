import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/notif_prefs_provider.dart';

class NotificationPreferencesScreen extends StatelessWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<NotifPrefsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifPreferences),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _ToggleRow(
              icon: Icons.warning_amber_rounded,
              color: AppColors.warning,
              title: AppStrings.budgetAlerts,
              subtitle: AppStrings.budgetAlertsSubtitle,
              value: prefs.budgetAlerts,
              onChanged: prefs.setBudgetAlerts,
            ),
            _ToggleRow(
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.danger,
              title: AppStrings.lowBalanceReminder,
              subtitle: AppStrings.lowBalanceSubtitle,
              value: prefs.lowBalance,
              onChanged: prefs.setLowBalance,
            ),
            _ToggleRow(
              icon: Icons.emoji_events_outlined,
              color: AppColors.mint,
              title: AppStrings.savingsGoalUpdates,
              subtitle: AppStrings.savingsGoalSubtitle,
              value: prefs.goalUpdates,
              onChanged: prefs.setGoalUpdates,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyles.body(context, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyles.caption(context)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
