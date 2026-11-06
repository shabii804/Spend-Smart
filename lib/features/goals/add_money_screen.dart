import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/success_overlay.dart';
import '../../core/widgets/confetti_burst.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';

class AddMoneyScreen extends StatefulWidget {
  final String goalId;
  const AddMoneyScreen({super.key, required this.goalId});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  bool _saving = false;

  static const _quickAmounts = [500.0, 1000.0, 5000.0];

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
    final provider = context.read<GoalProvider>();
    final wasComplete = (provider.byId(widget.goalId)?.isComplete ?? false);
    final newSaved = provider.addToGoal(widget.goalId, v);
    final isNowComplete = newSaved >= (provider.byId(widget.goalId)?.targetAmount ?? 0);
    setState(() => _saving = false);
    if (!mounted) return;
    // Confetti burst if this contribution completes the goal!
    if (!wasComplete && isNowComplete) {
      await ConfettiBurst.show(context);
    }
    // Premium success animation + haptic feedback
    await SuccessOverlay.show(
      context,
      label: AppStrings.moneyAdded,
      icon: Icons.check_rounded,
    );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final goal =
        context.select<GoalProvider, Goal?>((p) => p.byId(widget.goalId));
    if (goal == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.addMoney} · ${goal.name}'),
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
                // Current status
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryIndigo.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.primaryIndigo.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      Icon(goal.icon, color: AppColors.primaryIndigo, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.savedAmount,
                                style: TextStyles.label(context)),
                            Text(
                              '${Formatters.money(goal.savedAmount)} / ${Formatters.money(goal.targetAmount)}',
                              style: TextStyles.money(context, size: 16),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(goal.progressPercent * 100).toInt()}%',
                        style: TextStyles.body(context, weight: FontWeight.w700,
                            color: AppColors.primaryIndigo),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quick chips
                Text('Quick Amount',
                    style: TextStyles.label(context)),
                const SizedBox(height: 8),
                Row(
                  children: _quickAmounts
                      .map((a) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _QuickChip(
                                label: Formatters.moneyPlain(a),
                                onTap: () =>
                                    _amountCtrl.text = a.toStringAsFixed(0),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                // Amount field
                _AmountField(controller: _amountCtrl),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: AppStrings.addMoney,
                  icon: Icons.add_rounded,
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColorsOf.card(context),
            border: Border.all(color: AppColorsOf.border(context)),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyles.body(context, weight: FontWeight.w700)),
        ),
      ),
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
          child: Text(AppStrings.amount, style: TextStyles.label(context)),
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
            hintText: '0',
          ),
        ),
      ],
    );
  }
}
