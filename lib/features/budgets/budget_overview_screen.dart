import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/progress_bar.dart';
import '../../core/widgets/section_header.dart';
import '../../data/sample_data.dart';
import '../../models/category.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import 'edit_budget_screen.dart';

class BudgetOverviewScreen extends StatelessWidget {
  const BudgetOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetProvider>().budget;
    final expenses = context.watch<ExpenseProvider>();
    final spent = expenses.totalSpent;
    final remaining = budget.monthlyLimit - spent;
    final percent = budget.monthlyLimit == 0
        ? 0.0
        : spent / budget.monthlyLimit;
    final categoryTotals = expenses.categoryTotals;

    final perCategory = SampleData.categories.map((c) {
      final total = categoryTotals[c.id] ?? 0;
      final per = budget.monthlyLimit == 0 ? 0.0 : total / budget.monthlyLimit;
      return _CatProgress(cat: c, total: total, percent: per);
    }).where((e) => e.total > 0).toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.budgetOverview),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditBudgetScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Big budget hero card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppGradients.heroCard(context),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryIndigo.withOpacity(0.3),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.monthlyBudget,
                      style: TextStyles.label(context).copyWith(
                          color: Colors.white.withOpacity(0.85))),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.money(budget.monthlyLimit),
                    style: TextStyles.moneyHero(context, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
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
                          width: MediaQuery.sizeOf(context).width *
                              percent.clamp(0.0, 1.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeroStat(
                          label: AppStrings.spentThisMonth,
                          value: Formatters.money(spent)),
                      _HeroStat(
                          label: AppStrings.remaining,
                          value: Formatters.money(remaining)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SectionHeader(title: AppStrings.perCategory),
            const SizedBox(height: 12),
            if (perCategory.isEmpty)
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.noDataYet,
                  style: TextStyles.body(context,
                      color: AppColorsOf.secondaryText(context)),
                ),
              )
            else
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: perCategory
                      .map((c) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: c.cat.color.withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(c.cat.icon,
                                          color: c.cat.color, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(c.cat.name,
                                          style: TextStyles.body(context,
                                              weight: FontWeight.w600)),
                                    ),
                                    Text(
                                      Formatters.money(c.total),
                                      style: TextStyles.body(context,
                                          weight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ProgressBarFraction(
                                  percent: c.percent.clamp(0.0, 1.0),
                                  height: 6,
                                  gradient: LinearGradient(colors: [
                                    c.cat.color,
                                    c.cat.color.withOpacity(0.6),
                                  ]),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyles.label(context)
                .copyWith(color: Colors.white.withOpacity(0.7))),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyles.money(context, size: 16, color: Colors.white)),
      ],
    );
  }
}

class _CatProgress {
  final Category cat;
  final double total;
  final double percent;
  const _CatProgress({required this.cat, required this.total, required this.percent});
}
