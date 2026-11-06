import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/confetti_burst.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/premium_motion.dart';
import '../../core/widgets/staggered_entrance.dart';
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
    // Show back button only when this screen is pushed as a route (not when
    // it's accessed some other way). ModalRoute.of(context)?.canPop is true
    // only for pushed routes.
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (canPop) {
              Navigator.of(context).maybePop();
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateGoalScreen()),
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
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ═══ OVERVIEW HERO CARD WITH DONUT CHART ═══
            if (goals.isNotEmpty) ...[
              const SizedBox(height: 8),
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
                        return _ExpandableGoalCard(
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
                // Donut chart — reduced from 110→80px to save vertical space.
                // Uses CircularProgressIndicator (always renders full circle — no gaps).
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: overallPct.clamp(0.0, 1.0),
                          strokeWidth: 8,
                          backgroundColor:
                              AppColorsOf.tertiaryText(context).withOpacity(0.18),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.mint),
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: overallPct),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) {
                          final pct = (v * 100).clamp(0, 100).toInt();
                          return Text('$pct%',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.mint,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // ── Right column: total saved / remaining (simplified) ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Formatters.money(totalSaved),
                          style: TextStyles.money(context, size: 18, color: AppColors.mint)
                              .copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
                      const SizedBox(height: 2),
                      Text('of ${Formatters.money(totalTarget)}',
                          style: TextStyles.caption(context)
                              .copyWith(color: AppColorsOf.secondaryText(context))),
                      const SizedBox(height: 2),
                      Text('${Formatters.money(remaining)} to go',
                          style: TextStyles.caption(context, weight: FontWeight.w700)
                              .copyWith(color: AppColors.primaryIndigo, fontSize: 11)),
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
// _ExpandableGoalCard — TAP TO REVEAL Delete + Edit + Details buttons.
// Matches the transactions screen's tap-to-expand pattern. Consistent
// UX across both screens. NO SWIPE needed.
// ═══════════════════════════════════════════════════════════════════
class _ExpandableGoalCard extends StatefulWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ExpandableGoalCard({
    required this.goal,
    required this.onTap,
    required this.onAdd,
  });

  @override
  State<_ExpandableGoalCard> createState() => _ExpandableGoalCardState();
}

class _ExpandableGoalCardState extends State<_ExpandableGoalCard> {
  bool _isExpanded = false;

  void _toggle() {
    Haptics.selection();
    setState(() => _isExpanded = !_isExpanded);
  }

  Future<void> _confirmDelete() async {
    final ok = await ConfirmDialog.show(
      context,
      title: 'Delete goal?',
      body: 'Delete "${widget.goal.name}"? You\'ve saved ${Formatters.money(widget.goal.savedAmount)} '
          'toward this goal. This action can\'t be undone from within the app.',
      confirmLabel: 'Delete',
      danger: true,
      icon: Icons.delete_outline_rounded,
    );
    if (ok == true && context.mounted) {
      final provider = context.read<GoalProvider>();
      Haptics.heavy();
      provider.deleteGoal(widget.goal.id);
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(SnackBar(
        content: Text('Deleted "${widget.goal.name}"'),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryIndigo,
          onPressed: () {
            provider.addGoal(widget.goal);
            Haptics.selection();
          },
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GoalCard(
      goal: widget.goal,
      onTap: _toggle,
      onAdd: widget.onAdd,
      isExpanded: _isExpanded,
      onEdit: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GoalDetailsScreen(goalId: widget.goal.id),
        ),
      ),
      onDelete: _confirmDelete,
      onDetails: widget.onTap,
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool isExpanded;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onDetails;

  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onAdd,
    this.isExpanded = false,
    this.onEdit,
    this.onDelete,
    this.onDetails,
  });

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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HEADER (icon + name + circular ring / Achieved badge) ───
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accent.withOpacity(0.22),
                          accent.withOpacity(0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(goal.icon, color: accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(goal.name,
                            style: TextStyles.body(context, weight: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatters.money(goal.savedAmount)} of ${Formatters.money(goal.targetAmount)}',
                          style: TextStyles.caption(context)
                              .copyWith(fontSize: 10, color: AppColorsOf.secondaryText(context)),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
                    // ── CIRCULAR PROGRESS RING per goal ──
                    // This is the ONLY progress visualization per goal.
                    // Removed the redundant linear progress bar + milestone dots
                    // that were below — they showed the same info as the ring.
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: CircularProgressIndicator(
                              value: pct.clamp(0.0, 1.0),
                              strokeWidth: 4,
                              backgroundColor: accent.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(accent),
                            ),
                          ),
                          Text(
                            '${(pct * 100).round()}%',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accent,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // ─── ACTION ROW: remaining + Add button (more prominent) ───
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.isComplete
                          ? 'Goal achieved!'
                          : '${Formatters.money(goal.remaining)} to go',
                      style: TextStyles.caption(context).copyWith(
                          color: goal.isComplete ? AppColors.mint : null,
                          fontWeight: FontWeight.w600, fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!goal.isComplete)
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryButton,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryIndigo.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Add Money',
                                style: TextStyles.caption(context, weight: FontWeight.w700)
                                    .copyWith(color: Colors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // ─── EXPANDED ACTION BUTTONS (tap-to-reveal) ───
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: isExpanded
                    ? Column(
                        children: [
                          const SizedBox(height: 10),
                          Divider(height: 1, color: AppColorsOf.divider(context)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _inlineAction(
                                  icon: Icons.edit_outlined,
                                  label: 'Edit',
                                  color: AppColors.primaryIndigo,
                                  onTap: onEdit,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _inlineAction(
                                  icon: Icons.visibility_outlined,
                                  label: 'Details',
                                  color: AppColors.blue,
                                  onTap: onDetails,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _inlineAction(
                                  icon: Icons.delete_outline_rounded,
                                  label: 'Delete',
                                  color: AppColors.danger,
                                  onTap: onDelete,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inlineAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.20), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
