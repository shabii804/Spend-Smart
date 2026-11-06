import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/text_styles.dart';
import '../core/utils/formatters.dart';
import '../core/utils/validators.dart';
import '../core/widgets/glass_card.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/success_overlay.dart';
import '../providers/budget_provider.dart';
import '../providers/user_provider.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _incomeCtrl;
  bool _autoSetBudget = true;
  bool _saving = false;

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
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final incomeVal = double.tryParse(_incomeCtrl.text.trim()) ?? 0.0;
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.user;

    // Update user profile with occupation and monthly income
    userProvider.updateUser(
      currentUser.copyWith(
        occupation: _occupationCtrl.text.trim().isNotEmpty
            ? _occupationCtrl.text.trim()
            : 'Employed Professional',
        monthlyIncome: incomeVal,
      ),
    );

    // If auto set budget is enabled, set the monthly budget limit according to income
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

  @override
  Widget build(BuildContext context) {
    final currentBudget = context.watch<BudgetProvider>().monthlyLimit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income & Auto Budget'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Banner Card
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
                              'Add your work earnings and let SpendSmart automatically calibrate your monthly budget.',
                              style: TextStyles.caption(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Occupation / Job Title Field
                Text('Occupation / Job Title',
                    style: TextStyles.label(context),),
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
                // Monthly Income Field
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
                // Auto Budget Toggle Card
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
          ),
        ),
      ),
    );
  }
}
