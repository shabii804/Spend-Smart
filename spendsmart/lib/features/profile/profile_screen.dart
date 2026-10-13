import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../providers/expense_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/user_provider.dart';
import 'edit_profile_screen.dart';

/// Profile screen — simplified to just the identity card.
///
/// This screen is now accessed via the avatar tap on the home header
/// (pushed as a route, not a bottom-nav tab). It shows:
///   • Avatar (initials) + full name + email
///   • 3-column stats row (Spent this month / Txns count / Saved)
///   • Edit Profile pill
///
/// All settings (Budget, Notifications, Theme, Currency, Security, etc.)
/// have moved to the More tab. This avoids duplication — More is the
/// settings hub, Profile is the identity card.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final expenses = context.watch<ExpenseProvider>();
    final goals = context.watch<GoalProvider>();

    // ─── Initials calculation (handles single-word names) ───
    final nameParts = user.fullName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'
        : (nameParts.isNotEmpty && nameParts[0].length >= 2
            ? nameParts[0].substring(0, 2)
            : (nameParts.isNotEmpty ? nameParts[0][0] : ''))
        .toUpperCase();

    // Stats for the header
    final monthSpent = expenses.totalSpent;
    final txnCount = expenses.transactionCount;
    final goalsSaved = goals.totalSaved;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          children: [
            StaggeredEntrance(
              index: 0,
              child: GestureDetector(
                onTap: () {
                  Haptics.selection();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryButton,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryIndigo.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.fullName,
                                    style: TextStyles.h3(context),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(user.email,
                                    style: TextStyles.caption(context),
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          // Edit pill — obvious affordance
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryIndigo.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.edit_rounded,
                                    color: AppColors.primaryIndigo, size: 13),
                                const SizedBox(width: 4),
                                Text('Edit',
                                    style: TextStyles.caption(context, weight: FontWeight.w700)
                                        .copyWith(color: AppColors.primaryIndigo, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Subtle divider
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColorsOf.divider(context),
                      ),
                      const SizedBox(height: 14),
                      // ─── Stats row ───
                      Row(
                        children: [
                          Expanded(
                            child: _StatCell(
                              label: 'Spent',
                              value: Formatters.money(monthSpent),
                              color: AppColors.danger,
                            ),
                          ),
                          _StatDivider(),
                          Expanded(
                            child: _StatCell(
                              label: 'Txns',
                              value: '$txnCount',
                              color: AppColors.primaryIndigo,
                            ),
                          ),
                          _StatDivider(),
                          Expanded(
                            child: _StatCell(
                              label: 'Saved',
                              value: Formatters.money(goalsSaved),
                              color: AppColors.mint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Helpful hint pointing users to the More tab for settings
            Center(
              child: Text(
                'Find Budget, Notifications, Theme, and more in the More tab',
                textAlign: TextAlign.center,
                style: TextStyles.caption(context)
                    .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact stat cell used in the profile header.
class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: TextStyles.body(context, weight: FontWeight.w700)
                .copyWith(color: color, fontSize: 14,
                    fontFeatures: const [FontFeature.tabularFigures()])),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyles.caption(context)
                .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 10)),
      ],
    );
  }
}

/// Vertical divider between stat cells.
class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColorsOf.divider(context),
    );
  }
}
