import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/budget_provider.dart';

class EditBudgetScreen extends StatefulWidget {
  const EditBudgetScreen({super.key});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = context.read<BudgetProvider>().monthlyLimit;
    _amountCtrl = TextEditingController(
        text: current == current.roundToDouble()
            ? current.toStringAsFixed(0)
            : current.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final v = double.parse(_amountCtrl.text.trim());
    context.read<BudgetProvider>().updateBudget(v);
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.budgetUpdated)),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editBudget),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _AmountField(controller: _amountCtrl),
                const SizedBox(height: 16),
                // Period display (read-only)
                _readRow(context, AppStrings.budgetPeriod, AppStrings.budgetMonthly,
                    Icons.calendar_month_rounded),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: AppStrings.save,
                  icon: Icons.check_rounded,
                  loading: _saving,
                  onPressed: _save,
                ),
                const SizedBox(height: 16),
                Text(
                  'Current budget: ${Formatters.money(context.read<BudgetProvider>().monthlyLimit)}',
                  style: TextStyles.caption(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _readRow(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: TextStyles.label(context)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColorsOf.card(context).withOpacity(0.5),
            border: Border.all(color: AppColorsOf.border(context)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.blue, size: 20),
              const SizedBox(width: 12),
              Text(value, style: TextStyles.body(context, weight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(AppStrings.monthlyLimit, style: TextStyles.label(context)),
        ),
        TextFormField(
          controller: controller,
          validator: Validators.amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: TextStyles.money(context, size: 22),
          decoration: InputDecoration(
            prefixText: '${Formatters.currencySymbol} ',
            prefixStyle: TextStyles.money(context, size: 22,
                color: AppColorsOf.secondaryText(context)),
            hintText: '25000',
          ),
        ),
      ],
    );
  }
}
