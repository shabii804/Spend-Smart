import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/goal.dart';
import '../../providers/goal_provider.dart';

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _monthlyCtrl = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  IconData _icon = Icons.savings_rounded;
  bool _saving = false;

  static const _icons = [
    Icons.laptop_mac_rounded,
    Icons.flight_takeoff_rounded,
    Icons.health_and_safety_rounded,
    Icons.smartphone_rounded,
    Icons.savings_rounded,
    Icons.school_rounded,
    Icons.directions_car_rounded,
    Icons.home_rounded,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _monthlyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now().add(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (d != null) setState(() => _targetDate = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final g = Goal(
      id: 'g${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      icon: _icon,
      targetAmount: double.parse(_targetCtrl.text.trim()),
      savedAmount: 0,
      monthlySaving: double.parse(_monthlyCtrl.text.trim()),
      targetDate: _targetDate,
    );
    context.read<GoalProvider>().addGoal(g);
    setState(() => _saving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.goalCreated)),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createGoal),
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
                AppTextField(
                  label: 'Goal Name',
                  controller: _nameCtrl,
                  hint: 'e.g. New Laptop',
                  validator: Validators.required,
                  prefix: const Icon(Icons.flag_outlined, size: 20),
                ),
                const SizedBox(height: 16),
                _AmountField(
                  label: AppStrings.targetAmount,
                  controller: _targetCtrl,
                ),
                const SizedBox(height: 16),
                _AmountField(
                  label: AppStrings.monthlySaving,
                  controller: _monthlyCtrl,
                ),
                const SizedBox(height: 16),
                _iconPicker(),
                const SizedBox(height: 16),
                _dateRow(context),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: AppStrings.createGoal,
                  icon: Icons.check_rounded,
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

  Widget _iconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Icon', style: TextStyles.label(context)),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _icons.map((ic) {
            final sel = _icon == ic;
            return GestureDetector(
              onTap: () => setState(() => _icon = ic),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: sel
                      ? AppColors.primaryIndigo
                      : AppColorsOf.card(context),
                  border: Border.all(
                    color: sel
                        ? AppColors.primaryIndigo
                        : AppColorsOf.border(context),
                    width: sel ? 1.4 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(ic,
                    color: sel ? Colors.white : AppColorsOf.secondaryText(context),
                    size: 20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _dateRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(AppStrings.targetDate, style: TextStyles.label(context)),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColorsOf.card(context),
                border: Border.all(color: AppColorsOf.border(context)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_rounded, color: AppColors.blue, size: 20),
                  const SizedBox(width: 12),
                  Text(Formatters.date(_targetDate),
                      style: TextStyles.body(context, weight: FontWeight.w600)),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.blue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _AmountField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: TextStyles.label(context)),
        ),
        TextFormField(
          controller: controller,
          validator: Validators.amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: TextStyles.money(context, size: 20),
          decoration: InputDecoration(
            prefixText: '${Formatters.currencySymbol} ',
            prefixStyle: TextStyles.money(context, size: 20,
                color: AppColorsOf.secondaryText(context)),
            hintText: '0',
          ),
        ),
      ],
    );
  }
}
