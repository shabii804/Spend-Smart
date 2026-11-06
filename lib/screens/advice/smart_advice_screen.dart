import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/expense_provider.dart';

class SmartAdviceScreen extends StatelessWidget {
  const SmartAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>();
    final adviceCards = _buildAdvice(expenses);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.smartAdvice),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Greeting card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppGradients.positive,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.waving_hand_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.adviceGreeting,
                          style: TextStyles.h3(context).copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.adviceGreetingSubtitle,
                          style: TextStyles.caption(context).copyWith(
                              color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.adviceDemoLabel,
                    style: TextStyles.caption(context, weight: FontWeight.w600)
                        .copyWith(color: AppColors.warning),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...adviceCards.map((c) => _AdviceCard(card: c)),
          ],
        ),
      ),
    );
  }

  List<_AdviceCardData> _buildAdvice(ExpenseProvider expenses) {
    final out = <_AdviceCardData>[];

    // 1. Top category advice
    final top = expenses.topCategories(1);
    if (top.isNotEmpty) {
      final c = top.first;
      final pct = (c.value / (expenses.totalSpent == 0 ? 1 : expenses.totalSpent) * 100)
          .clamp(0, 100)
          .toInt();
      out.add(_AdviceCardData(
        icon: c.key.icon,
        color: c.key.color,
        title: '${c.key.name} is ${pct}% of your spending',
        body: 'Try reducing ${c.key.name.toLowerCase()} by 20% to save around '
            '${Formatters.money(c.value * 0.2)} this month.',
      ));
    }

    // 2. Transport advice
    final transportTotal = expenses.categoryTotals['transport'] ?? 0;
    if (transportTotal > 0) {
      out.add(_AdviceCardData(
        icon: Icons.directions_bus_rounded,
        color: AppColors.catTransport,
        title: AppStrings.adviceTransport,
        body: '${AppStrings.adviceTransportBody} '
            '(You\'ve spent ${Formatters.money(transportTotal)} so far.)',
      ));
    } else {
      out.add(_AdviceCardData(
        icon: Icons.directions_bus_rounded,
        color: AppColors.catTransport,
        title: AppStrings.adviceTransport,
        body: AppStrings.adviceTransportBody,
      ));
    }

    // 3. Budget pacing
    final pct = expenses.percentUsed;
    final pacingMsg = pct < 0.5
        ? 'Great pacing — you\'re well under budget. Daily average is ${Formatters.money(expenses.averageDailySpend)}.'
        : pct < 0.8
            ? 'You\'re at ${(pct * 100).toInt()}% of your budget. Keep daily spend under ${Formatters.money(expenses.averageDailySpend * 1.1)} to stay on track.'
            : 'Warning: you\'ve used ${(pct * 100).toInt()}% of your budget. Consider pausing non-essential spending.';
    out.add(_AdviceCardData(
      icon: Icons.speed_rounded,
      color: AppColors.primaryIndigo,
      title: AppStrings.adviceBudget,
      body: pacingMsg,
    ));

    // 4. Savings boost
    final remaining = expenses.remaining;
    out.add(_AdviceCardData(
      icon: Icons.savings_rounded,
      color: AppColors.mint,
      title: AppStrings.adviceSaving,
      body: remaining > 0
          ? 'You have ${Formatters.money(remaining)} left this month. Move '
              '${Formatters.money(remaining * 0.5)} to your Emergency Fund before you spend it.'
          : 'You\'re over budget this month. Review your largest categories and pause discretionary spending.',
    ));

    return out;
  }
}

class _AdviceCardData {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _AdviceCardData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}

class _AdviceCard extends StatelessWidget {
  final _AdviceCardData card;
  const _AdviceCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: card.color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(card.icon, color: card.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title, style: TextStyles.body(context, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(card.body, style: TextStyles.caption(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
