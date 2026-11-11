import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/success_overlay.dart';
import '../../models/income_entry.dart';
import '../../providers/budget_provider.dart';
import '../../providers/income_provider.dart';
import '../../providers/user_provider.dart';

/// Income module v2 — handles BOTH income kinds in one place:
///  1. 💼 Job income — fixed monthly salary, optionally auto-calibrates
///     the monthly budget.
///  2. 💸 Other earnings — one-off / random income (freelance, gifts,
///     cashback...), stored as a running ledger with a monthly summary.
class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  bool _jobTab = true; // true = Job Income, false = Other Earnings

  // ── Job tab controllers ──
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _incomeCtrl;
  bool _autoSetBudget = true;
  bool _saving = false;

  // ── Earnings tab controllers ──
  final _earnFormKey = GlobalKey<FormState>();
  final _sourceCtrl = TextEditingController();
  final _earnAmountCtrl = TextEditingController();
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _occupationCtrl = TextEditingController(text: user.occupation);
    _incomeCtrl = TextEditingController(
      text: user.monthlyIncome > 0 ? user.monthlyIncome.toInt().toString() : '',
    );
  }

  @override
  void dispose() {
    _occupationCtrl.dispose();
    _incomeCtrl.dispose();
    _sourceCtrl.dispose();
    _earnAmountCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Job income save (updates profile + optionally the budget)
  // ─────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final incomeVal = double.tryParse(_incomeCtrl.text.trim()) ?? 0.0;
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.user;

    userProvider.updateUser(
      currentUser.copyWith(
        occupation: _occupationCtrl.text.trim().isNotEmpty
            ? _occupationCtrl.text.trim()
            : 'Employed Professional',
        monthlyIncome: incomeVal,
      ),
    );

    // Keep the income module in sync with the profile.
    context.read<IncomeProvider>().setJobIncome(incomeVal);

    // If auto set budget is enabled, set the monthly budget limit to income.
    if (_autoSetBudget && incomeVal > 0) {
      context.read<BudgetProvider>().updateBudget(incomeVal);
    }

    setState(() => _saving = false);
    if (!mounted) return;

    await SuccessOverlay.show(
      context,
      label: _autoSetBudget
          ? 'Income saved & Budget updated automatically!'
          : 'Income updated successfully!',
      icon: Icons.check_circle_rounded,
    );
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  // ─────────────────────────────────────────────────────────────
  // One-off earning add
  // ─────────────────────────────────────────────────────────────
  Future<void> _addEarning() async {
    if (!_earnFormKey.currentState!.validate()) return;
    setState(() => _adding = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final amount = double.tryParse(_earnAmountCtrl.text.trim()) ?? 0.0;
    context.read<IncomeProvider>().addEarning(_sourceCtrl.text, amount);

    _sourceCtrl.clear();
    _earnAmountCtrl.clear();
    setState(() => _adding = false);
    if (!mounted) return;

    await SuccessOverlay.show(
      context,
      label: 'Earning added!',
      icon: Icons.savings_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _segmented(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: _jobTab ? _jobTabContent() : _earningsTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Segmented control
  // ─────────────────────────────────────────────────────────────
  Widget _segmented() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColorsOf.card(context),
          border: Border.all(color: AppColorsOf.border(context)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _segment(
              icon: Icons.work_rounded,
              label: 'Job Income',
              selected: _jobTab,
              onTap: () {
                Haptics.selection();
                setState(() => _jobTab = true);
              },
            ),
            _segment(
              icon: Icons.bolt_rounded,
              label: 'Other Earnings',
              selected: !_jobTab,
              onTap: () {
                Haptics.selection();
                setState(() => _jobTab = false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.primaryButton : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 17,
                  color: selected
                      ? Colors.white
                      : AppColorsOf.secondaryText(context),),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyles.caption(context, weight: FontWeight.w700)
                    .copyWith(
                  fontSize: 12.5,
                  color: selected
                      ? Colors.white
                      : AppColorsOf.secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 1 — Job income (monthly salary + auto budget)
  // ─────────────────────────────────────────────────────────────
  Widget _jobTabContent() {
    final currentBudget = context.watch<BudgetProvider>().monthlyLimit;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.mint.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.work_rounded,
                      color: AppColors.mint, size: 24,),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Job & Income Planner',
                          style: TextStyles.h3(context),),
                      const SizedBox(height: 2),
                      Text(
                        'Your fixed monthly salary. SpendSmart can automatically calibrate your monthly budget from it.',
                        style: TextStyles.caption(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Occupation / Job Title', style: TextStyles.label(context),),
          const SizedBox(height: 6),
          TextFormField(
            controller: _occupationCtrl,
            validator: Validators.required,
            textInputAction: TextInputAction.next,
            style: TextStyles.body(context, weight: FontWeight.w600),
            decoration: const InputDecoration(
              hintText: 'e.g. Software Engineer, Designer, Manager',
              prefixIcon: Icon(Icons.badge_outlined, size: 20),
            ),
          ),
          const SizedBox(height: 20),
          Text('Monthly Income (${Formatters.currencySymbol})',
              style: TextStyles.label(context),),
          const SizedBox(height: 6),
          TextFormField(
            controller: _incomeCtrl,
            validator: Validators.amount,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            textInputAction: TextInputAction.done,
            style: TextStyles.money(context, size: 22),
            decoration: InputDecoration(
              prefixText: '${Formatters.currencySymbol} ',
              prefixStyle: TextStyles.money(context,
                  size: 22, color: AppColorsOf.secondaryText(context),),
              hintText: '85000',
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Auto-Set Budget From Income',
                style: TextStyles.body(context, weight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Automatically set your monthly budget limit to match your income (${Formatters.money(currentBudget)} current).',
                  style: TextStyles.caption(context),
                ),
              ),
              value: _autoSetBudget,
              activeColor: AppColors.primaryIndigo,
              onChanged: (val) => setState(() => _autoSetBudget = val),
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Save & Calibrate Budget',
            icon: Icons.check_circle_rounded,
            loading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 2 — Other earnings (one-off / random income)
  // ─────────────────────────────────────────────────────────────
  Widget _earningsTabContent() {
    final income = context.watch<IncomeProvider>();
    final monthOther = income.otherEarningsIn();
    final monthTotal = income.totalIn();

    return Form(
      key: _earnFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary card
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.mint.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.bolt_rounded,
                          color: AppColors.mint, size: 26,),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('This Month',
                              style: TextStyles.caption(context),),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.money(monthTotal),
                            style: TextStyles.money(context, size: 24,
                                color: AppColors.mint,),
                          ),
                          Text(
                            '${Formatters.money(income.jobIncome)} salary + ${Formatters.money(monthOther)} other',
                            style: TextStyles.caption(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Add-earning form
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Earning', style: TextStyles.h3(context)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sourceCtrl,
                  textInputAction: TextInputAction.next,
                  style: TextStyles.body(context, weight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Source — e.g. Freelance, Gift, Cashback',
                    prefixIcon: Icon(Icons.label_outline_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _earnAmountCtrl,
                  validator: Validators.amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  textInputAction: TextInputAction.done,
                  style: TextStyles.money(context, size: 20),
                  decoration: InputDecoration(
                    prefixText: '${Formatters.currencySymbol} ',
                    prefixStyle: TextStyles.money(context,
                        size: 20, color: AppColorsOf.secondaryText(context),),
                    hintText: 'Amount',
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Add Earning',
                  icon: Icons.add_circle_outline_rounded,
                  loading: _adding,
                  onPressed: _addEarning,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // History
          if (income.earnings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded,
                      size: 40, color: AppColorsOf.tertiaryText(context),),
                  const SizedBox(height: 8),
                  Text('No other earnings yet',
                      style: TextStyles.caption(context),),
                ],
              ),
            )
          else ...[
            Text('Recent Earnings', style: TextStyles.label(context)),
            const SizedBox(height: 8),
            ...income.earnings.map(_earningTile),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _earningTile(IncomeEntry e) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.trending_up_rounded,
                  color: AppColors.mint, size: 20,),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.source,
                      style: TextStyles.body(context,
                          weight: FontWeight.w600),
                      // Single line + ellipsis — long sources like
                      // "Freelance project" wrapped to 2 lines and made the
                      // row taller than its siblings.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM yyyy').format(e.date),
                    style: TextStyles.caption(context),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Text(
                '+${Formatters.money(e.amount)}',
                style: TextStyles.money(context,
                    size: 15, color: AppColors.mint,),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            // 44px tap target + confirmation — deleting a persisted earning
            // used to happen instantly on a 20px icon with no undo.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                Haptics.selection();
                final confirmed = await ConfirmDialog.show(
                  context,
                  title: 'Delete earning?',
                  body: '"${e.source}" (${Formatters.money(e.amount)}) will be removed from your income history.',
                  confirmLabel: 'Delete',
                  danger: true,
                  icon: Icons.delete_outline_rounded,
                );
                if (confirmed != true) return;
                final messenger = ScaffoldMessenger.of(context);
                context.read<IncomeProvider>().deleteEarning(e.id);
                Haptics.success();
                messenger.clearSnackBars();
                messenger.showSnackBar(SnackBar(
                  content: Text('Removed ${e.source}'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: AppColors.mint,
                    onPressed: () => context.read<IncomeProvider>().restoreEarning(e),
                  ),
                ));
              },
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                child: Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppColorsOf.tertiaryText(context),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
