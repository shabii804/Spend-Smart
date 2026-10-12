import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/premium_motion.dart';
import '../../core/widgets/progress_bar.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';
import 'create_goal_screen.dart';
import 'goal_details_screen.dart';

/// Bottom sheet for adding money to a goal — replaces full-screen push.
void _showAddMoneySheet(BuildContext context, String goalId, String goalName) {
  final amountCtrl = TextEditingController();
  final provider = context.read<GoalProvider>();
  final goal = provider.byId(goalId);
  final wasComplete = goal?.isComplete ?? false;
  final oldPct = goal?.progressPercent ?? 0;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColorsOf.tertiaryText(context).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2)))),
            Text(goalName, style: TextStyles.h2(context), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('${Formatters.money(goal?.savedAmount ?? 0)} of ${Formatters.money(goal?.targetAmount ?? 0)}',
                style: TextStyles.caption(context), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyles.moneyDisplay(context),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: '${Formatters.currencySymbol} ',
                hintText: '0',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColorsOf.border(context))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [500, 1000, 5000].map((amt) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => amountCtrl.text = amt.toString(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColorsOf.card(context),
                          border: Border.all(color: AppColorsOf.border(context)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(Formatters.moneyPlain(amt.toDouble()),
                            style: TextStyles.body(context, weight: FontWeight.w700)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            MorphingLoadingButton(
              label: 'Add Money',
              icon: Icons.check_rounded,
              onPressed: () {
                final v = double.tryParse(amountCtrl.text.trim());
                if (v == null || v <= 0) return;
                provider.addToGoal(goalId, v);
                final updatedGoal = provider.byId(goalId);
                final newPct = updatedGoal?.progressPercent ?? 0;
                final isNowComplete = updatedGoal?.isComplete ?? false;
                Navigator.of(sheetContext).maybePop();
                // Confetti if milestone crossed or goal completed
                var crossed = false;
                for (final t in [0.25, 0.50, 0.75, 1.0]) {
                  if (oldPct < t && newPct >= t) crossed = true;
                }
                if (crossed || (!wasComplete && isNowComplete)) {
                  ConfettiBurst.show(context);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${Formatters.money(v)} to $goalName')));
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

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
                Text('Savings Goals', style: TextStyles.h1(context)),
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
          // Header summary strip
          if (goals.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mint.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.savings_rounded, size: 16, color: AppColors.mint),
                    const SizedBox(width: 8),
                    Text('Total saved ${Formatters.money(goals.fold(0.0, (s, g) => s + g.savedAmount))} across ${goals.length} ${goals.length == 1 ? 'goal' : 'goals'}',
                        style: TextStyles.caption(context, weight: FontWeight.w700)),
                  ],
                ),
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
                        onAdd: () {
                          _showAddMoneySheet(context, g.id, g.name);
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
              // ─── ACTION GROUP: "Rs. X to go - on track for MMM YYYY" + compact Add button ───
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.isComplete
                          ? 'Goal achieved!'
                          : '${Formatters.money(goal.remaining)} to go · on track for ${Formatters.date(goal.targetDate)}',
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColorsOf.card(context),
                          border: Border.all(color: AppColorsOf.border(context)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 14),
                            const SizedBox(width: 4),
                            Text('Add',
                                style: TextStyles.caption(context, weight: FontWeight.w700)),
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
}
