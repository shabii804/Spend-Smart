import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/progress_bar.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';
import 'add_money_screen.dart';
import 'create_goal_screen.dart';
import 'goal_details_screen.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<GoalProvider>().goals;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.savingsGoals, style: TextStyles.h1(context)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CreateGoalScreen()),
                  ),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryButton,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryIndigo.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: goals.isEmpty
                ? EmptyState(
                    icon: Icons.savings_outlined,
                    title: AppStrings.noGoals,
                    subtitle: AppStrings.noGoalsSubtitle,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    itemCount: goals.length,
                    itemBuilder: (_, i) {
                      final g = goals[i];
                      return _GoalCard(
                        goal: g,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GoalDetailsScreen(goalId: g.id),
                          ),
                        ),
                        onAdd: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddMoneyScreen(goalId: g.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _GoalCard(
      {required this.goal, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final pct = goal.progressPercent;
    final accent = goal.isComplete ? AppColors.mint : AppColors.primaryIndigo;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: GlassCard(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HEADER (icon + name) ───
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withOpacity(0.22),
                          accent.withOpacity(0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(goal.icon, color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(goal.name,
                        style: TextStyles.body(context, weight: FontWeight.w700),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  if (goal.isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events_rounded,
                              color: AppColors.mint, size: 12),
                          const SizedBox(width: 4),
                          Text('Achieved',
                              style: TextStyles.caption(context, weight: FontWeight.w700)
                                  .copyWith(color: AppColors.mint, fontSize: 10)),
                        ],
                      ),
                    )
                  else
                    Text(
                      '${(pct * 100).round()}%',
                      style: TextStyles.body(context, weight: FontWeight.w700)
                          .copyWith(color: accent,
                              fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // ─── STATUS GROUP: saved + target, anchored % pill, progress bar ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You\'ve saved',
                          style: TextStyles.caption(context)
                              .copyWith(fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.money(goal.savedAmount),
                        style: TextStyles.money(context, size: 18)
                            .copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                      ),
                    ],
                  ),
                  Text(
                    'of ${Formatters.money(goal.targetAmount)}',
                    style: TextStyles.caption(context)
                        .copyWith(color: AppColorsOf.secondaryText(context)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar with subtle shadow + rounded caps
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ProgressBarFraction(
                  percent: pct,
                  height: 10,
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: goal.isComplete
                        ? [AppColors.mint, AppColors.blue]
                        : [accent, AppColors.primaryPurple],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ─── ACTION GROUP: positive milestone hint + Add Money CTA ───
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.isComplete
                          ? 'Goal achieved! 🎉'
                          : 'Next milestone: ${Formatters.money(_nextMilestone(goal))}',
                      style: TextStyles.caption(context).copyWith(
                          color: goal.isComplete ? AppColors.mint : null,
                          fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!goal.isComplete)
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryButton,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryIndigo.withOpacity(0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.addMoney,
                              style: TextStyles.caption(context, weight: FontWeight.w700)
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Next "round number" milestone to celebrate.
  double _nextMilestone(Goal g) {
    if (g.targetAmount <= 0) return g.targetAmount;
    final step = g.targetAmount / 10; // 10%, 20%, ..., 100%
    final current = g.savedAmount;
    final next = (current / step).ceil() + 1;
    return (next * step).clamp(0.0, g.targetAmount);
  }
}
