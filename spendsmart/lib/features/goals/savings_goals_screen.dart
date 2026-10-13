import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/confetti_burst.dart';
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

          // ═══ OVERVIEW HERO CARD WITH DONUT CHART ═══
          // Premium visualization at the top: donut chart showing overall
          // saved vs remaining across all goals + breakdown legend listing
          // each goal's share. Replaces the plain summary strip.
          if (goals.isNotEmpty) ...[
            const SizedBox(height: 12),
            _GoalsOverviewCard(goals: goals),
          ],

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
                      return _DismissibleGoalCard(
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

// ═══════════════════════════════════════════════════════════════════
// _GoalsOverviewCard — donut chart hero at the top of the Goals screen.
//
// Layout:
//   ┌─────────────────────────────────────────────────────┐
//   │ Savings Overview              [N goals • M days avg]│
//   │                                                     │
//   │  ┌──────────┐     Total saved                       │
//   │  │   62%    │     Rs. 25,000                         │
//   │  │  saved   │     of Rs. 40,000 target              │
//   │  └──────────┘     Rs. 15,000 remaining              │
//   │                                                     │
//   │  ─────────────────────────────────────────────────  │
//   │  ● Emergency   Rs. 12,000   ● Bike         Rs. 8,000 │
//   │  ● Vacation    Rs. 5,000    ● Other        Rs. 0    │
//   └─────────────────────────────────────────────────────┘
//
// Premium polish:
//   • Donut chart with mint→indigo gradient for the filled slice and a
//     subtle white/translucent ring for the remaining slice.
//   • Center text animates from 0 → final % via TweenAnimationBuilder
//     in sync with the ring sweep (900ms easeOutCubic).
//   • Breakdown legend uses each goal's accent color as the dot.
// ═══════════════════════════════════════════════════════════════════
class _GoalsOverviewCard extends StatelessWidget {
  final List<Goal> goals;
  const _GoalsOverviewCard({required this.goals});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final totalSaved = provider.totalSaved;
    final totalTarget = provider.totalTarget;
    final remaining = (totalTarget - totalSaved).clamp(0.0, double.infinity);
    final overallPct = provider.overallProgress; // 0.0 - 1.0
    final pctInt = (overallPct * 100).clamp(0, 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header row ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Savings Overview',
                    style: TextStyles.h3(context)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mint.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${goals.length} ${goals.length == 1 ? 'goal' : 'goals'}',
                    style: TextStyles.caption(context, weight: FontWeight.w700)
                        .copyWith(color: AppColors.mint, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Donut + breakdown row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Donut chart with animated percent text in center
                SizedBox(
                  width: 110,
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: PieChart(
                          duration: const Duration(milliseconds: 1100),
                          curve: Curves.easeOutCubic,
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 38,
                            // Two sections: filled (mint→blue gradient
                            // approximation via solid mint) + remaining
                            // (subtle white/translucent).
                            sections: [
                              PieChartSectionData(
                                color: AppColors.mint,
                                value: overallPct == 0
                                    ? 0.0001
                                    : overallPct,
                                title: '',
                                radius: 26,
                                borderSide: BorderSide(
                                  color: AppColorsOf.card(context),
                                  width: 1.5,
                                ),
                              ),
                              PieChartSectionData(
                                color: AppColorsOf.tertiaryText(context)
                                    .withOpacity(0.18),
                                value: overallPct == 0
                                    ? 0.9999
                                    : (1.0 - overallPct),
                                title: '',
                                radius: 26,
                                borderSide: BorderSide(
                                  color: AppColorsOf.card(context),
                                  width: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Center text animates 0 → final % in sync with the
                      // ring sweep (900ms easeOutCubic, same easing as the
                      // chart's own animation).
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: overallPct),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) {
                          final pct = (v * 100).clamp(0, 100).toInt();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$pct%',
                                  style: TextStyles.money(context,
                                      size: 22, color: AppColors.mint)),
                              Text('saved',
                                  style: TextStyles.caption(context)
                                      .copyWith(fontSize: 9, color: AppColorsOf.tertiaryText(context))),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // ── Right column: total saved / target / remaining ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total saved',
                          style: TextStyles.caption(context)
                              .copyWith(color: AppColorsOf.tertiaryText(context))),
                      const SizedBox(height: 2),
                      Text(Formatters.money(totalSaved),
                          style: TextStyles.money(context, size: 18, color: AppColors.mint)
                              .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                      const SizedBox(height: 6),
                      Text('of ${Formatters.money(totalTarget)} target',
                          style: TextStyles.caption(context)
                              .copyWith(color: AppColorsOf.secondaryText(context))),
                      const SizedBox(height: 4),
                      Text('${Formatters.money(remaining)} to go',
                          style: TextStyles.caption(context, weight: FontWeight.w700)
                              .copyWith(color: AppColors.primaryIndigo)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            // ── Divider before breakdown legend ──
            Divider(
              height: 1,
              thickness: 1,
              color: AppColorsOf.divider(context),
            ),
            const SizedBox(height: 12),

            // ── Breakdown legend: each goal's share ──
            // Two-column wrap of (color dot + name + amount) per goal.
            // Hidden if only 1 goal (no breakdown needed).
            if (goals.length > 1)
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: goals.map((g) {
                  final isComplete = g.isComplete;
                  final accent = isComplete ? AppColors.mint : AppColors.primaryIndigo;
                  final sharePct = totalTarget == 0
                      ? 0
                      : (g.savedAmount / totalTarget * 100).round();
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${g.name} ',
                          style: TextStyles.caption(context, weight: FontWeight.w600)),
                      Text(Formatters.moneyPlain(g.savedAmount),
                          style: TextStyles.caption(context, weight: FontWeight.w700)
                              .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                      const SizedBox(width: 4),
                      Text('· $sharePct%',
                          style: TextStyles.caption(context)
                              .copyWith(color: AppColorsOf.tertiaryText(context), fontSize: 10)),
                    ],
                  );
                }).toList(),
              )
            else
              // Single goal — show its completion status instead
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: goals.first.isComplete ? AppColors.mint : AppColors.primaryIndigo,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    goals.first.isComplete ? 'Goal achieved!' : 'Still saving',
                    style: TextStyles.caption(context, weight: FontWeight.w700),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// _DismissibleGoalCard — wraps _GoalCard in a Dismissible so the user
// can swipe LEFT to delete a goal. Shows a confirmation dialog first
// since deleting a goal is destructive (saved money is "lost" from
// the app's tracking perspective). Includes an UNDO snackbar after.
// ═══════════════════════════════════════════════════════════════════
class _DismissibleGoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _DismissibleGoalCard({
    required this.goal,
    required this.onTap,
    required this.onAdd,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    // Show a destructive-action confirmation dialog. Deleting a goal
    // is more serious than deleting an expense — the saved-amount
    // metadata is lost — so we require explicit confirmation.
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete goal?'),
            content: Text(
              'Delete "${goal.name}"? You\'ve saved ${Formatters.money(goal.savedAmount)} '
              'toward this goal. This action can\'t be undone from within the app.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Delete',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showUndo(BuildContext context, GoalProvider provider) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(
      content: Text('Deleted "${goal.name}"'),
      duration: const Duration(seconds: 6),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'UNDO',
        textColor: AppColors.primaryIndigo,
        onPressed: () {
          // Re-insert the goal at the top of the list (matches addGoal).
          provider.addGoal(goal);
          Haptics.selection();
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('goal-${goal.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.danger.withOpacity(0.85),
              AppColors.danger,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text('Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
      dismissThresholds: const {
        DismissDirection.endToStart: 0.4, // higher threshold than txns — goals are destructive
      },
      confirmDismiss: (direction) async => _confirmDelete(context),
      onDismissed: (direction) {
        final provider = context.read<GoalProvider>();
        Haptics.heavy();
        provider.deleteGoal(goal.id);
        _showUndo(context, provider);
      },
      child: _GoalCard(
        goal: goal,
        onTap: onTap,
        onAdd: onAdd,
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
              // ─── HEADER (icon + name + % / Achieved badge) ───
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
              // ─── STATUS GROUP: saved + target ───
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

              // ─── PROGRESS BAR WITH MILESTONE DOTS ───
              // Milestone dots at 25% / 50% / 75% / 100% positions —
              // gives the user a visual sense of which milestones they've
              // passed (and which are still ahead). Dots fill with the
              // accent color when crossed, otherwise translucent.
              Stack(
                alignment: Alignment.centerLeft,
                children: [
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
                  // Milestone dots — positioned at 25%, 50%, 75%.
                  // The 100% mark is implied by the bar's right edge.
                  for (final m in [0.25, 0.50, 0.75])
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // ProgressBarFraction fills its parent's width,
                          // so we use constraints.maxWidth to position dots.
                          final dotX = constraints.maxWidth * m;
                          final crossed = pct >= m;
                          return SizedBox(
                            height: 10,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: dotX - 5,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: crossed
                                          ? Colors.white
                                          : AppColorsOf.card(context),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: crossed
                                            ? accent
                                            : AppColorsOf.tertiaryText(context).withOpacity(0.4),
                                        width: 1.5,
                                      ),
                                      boxShadow: crossed
                                          ? [
                                              BoxShadow(
                                                color: accent.withOpacity(0.4),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ]
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ─── ACTION GROUP: "Rs. X to go - on track for MMM YYYY" + Add ───
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
