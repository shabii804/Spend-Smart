import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/animated_money.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';
import 'add_money_screen.dart';

class GoalDetailsScreen extends StatelessWidget {
  final String goalId;
  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    final goal = context.select<GoalProvider, Goal?>((p) => p.byId(goalId));
    if (goal == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final pct = goal.progressPercent;
    final isComplete = goal.isComplete;

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Hero icon
            Hero(
              tag: 'goal-icon-${goal.id}',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: isComplete
                      ? AppGradients.positive
                      : AppGradients.heroCard(context),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(goal.icon, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 14),
                    AnimatedMoney(
                      amount: goal.savedAmount,
                      style: TextStyles.moneyHero(context, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.ofText} ${Formatters.money(goal.targetAmount)}',
                      style: TextStyles.body(context,
                          color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          Container(
                            height: 10,
                            color: Colors.white.withOpacity(0.22),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                            height: 10,
                            width: MediaQuery.sizeOf(context).width * pct,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(pct * 100).toInt()}% complete',
                      style: TextStyles.caption(context, weight: FontWeight.w700)
                          .copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            if (isComplete) ...[
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.mint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.emoji_events_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.goalComplete,
                              style: TextStyles.body(context,
                                  weight: FontWeight.w700,
                                  color: AppColors.mint)),
                          Text(AppStrings.goalCompleteSubtitle,
                              style: TextStyles.caption(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                    label: AppStrings.targetAmount,
                    value: Formatters.money(goal.targetAmount),
                    icon: Icons.flag_rounded,
                    color: AppColors.primaryIndigo,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: AppStrings.savedAmount,
                    value: Formatters.money(goal.savedAmount),
                    icon: Icons.savings_rounded,
                    color: AppColors.blue,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: AppStrings.monthlySaving,
                    value: Formatters.money(goal.monthlySaving),
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.mint,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: AppStrings.targetDate,
                    value: Formatters.date(goal.targetDate),
                    icon: Icons.event_rounded,
                    color: AppColors.catBills,
                  ),
                  if (!isComplete) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      label: AppStrings.remainingToSave,
                      value: Formatters.money(goal.remaining),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.catEntertainment,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!isComplete)
              PrimaryButton(
                label: AppStrings.addMoney,
                icon: Icons.add_rounded,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddMoneyScreen(goalId: goal.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
              Text(label, style: TextStyles.label(context)),
              const SizedBox(height: 2),
              Text(value, style: TextStyles.body(context, weight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
