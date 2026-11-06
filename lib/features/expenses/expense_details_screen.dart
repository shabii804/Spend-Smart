import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/sample_data.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final String expenseId;

  const ExpenseDetailsScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    final expense =
        context.select<ExpenseProvider, Expense?>((p) => p.byId(expenseId));
    if (expense == null) {
      // Already deleted — pop back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    final cat = SampleData.categoryById(expense.categoryId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.expenseDetails),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // Hero header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cat.color, cat.color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'expense-icon-${expense.id}',
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(cat.icon, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    Formatters.money(expense.amount),
                    style: TextStyles.moneyHero(context, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.title,
                    style: TextStyles.body(context,
                        color: Colors.white.withOpacity(0.9),
                        weight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(
                      label: AppStrings.category,
                      value: cat.name,
                      icon: cat.icon,
                      iconColor: cat.color),
                  const Divider(height: 24),
                  _DetailRow(
                    label: AppStrings.date,
                    value: Formatters.dateTime(expense.date),
                    icon: Icons.event_rounded,
                    iconColor: AppColors.blue,
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _DetailRow(
                      label: AppStrings.note,
                      value: expense.note!,
                      icon: Icons.sticky_note_2_outlined,
                      iconColor: AppColors.mint,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: AppStrings.edit,
                    icon: Icons.edit_rounded,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AddExpenseScreen(expenseId: expense.id),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: AppStrings.delete,
                    icon: Icons.delete_outline_rounded,
                    onPressed: () async {
                      final ok = await ConfirmDialog.show(
                        context,
                        title: AppStrings.deleteExpenseConfirm,
                        body: AppStrings.deleteExpenseConfirmBody,
                        confirmLabel: AppStrings.delete,
                        danger: true,
                        icon: Icons.delete_outline_rounded,
                      );
                      if (ok == true && context.mounted) {
                        context
                            .read<ExpenseProvider>()
                            .deleteExpense(expense.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(AppStrings.expenseDeleted)),
                        );
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).maybePop();
                        }
                      }
                    },
                  ),
                ),
              ],
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
  final Color iconColor;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyles.label(context)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyles.body(context, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
