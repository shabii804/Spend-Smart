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
import '../../core/widgets/success_overlay.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _incomeCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<UserProvider>().user;
    _nameCtrl = TextEditingController(text: u.fullName);
    _emailCtrl = TextEditingController(text: u.email);
    _occupationCtrl = TextEditingController(text: u.occupation);
    _incomeCtrl = TextEditingController(
      text: u.monthlyIncome > 0 ? u.monthlyIncome.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _occupationCtrl.dispose();
    _incomeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    // IMPORTANT: copyWith on the CURRENT user — constructing a fresh
    // UserProfile here used to wipe every field that isn't on this form
    // (monthly income, occupation, phone, streak, security toggles).
    final current = context.read<UserProvider>().user;
    final incomeVal = double.tryParse(_incomeCtrl.text.trim());
    context.read<UserProvider>().updateUser(current.copyWith(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          occupation: _occupationCtrl.text.trim().isNotEmpty
              ? _occupationCtrl.text.trim()
              : current.occupation,
          monthlyIncome: (incomeVal != null && incomeVal >= 0)
              ? incomeVal
              : current.monthlyIncome,
        ));
    setState(() => _saving = false);
    if (!mounted) return;
    await SuccessOverlay.show(
      context,
      label: AppStrings.profileUpdated,
      icon: Icons.check_rounded,
    );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
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
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.fullName,
                  controller: _nameCtrl,
                  validator: Validators.required,
                  prefix: const Icon(Icons.person_outline_rounded, size: 20),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.email,
                  controller: _emailCtrl,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.alternate_email_rounded, size: 20),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Occupation',
                  hint: 'e.g. Student, Freelancer, Engineer',
                  controller: _occupationCtrl,
                  prefix: const Icon(Icons.badge_outlined, size: 20),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                // Monthly income — mirrors the Income module field so the
                // profile and the income planner always agree.
                TextFormField(
                  controller: _incomeCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  textInputAction: TextInputAction.done,
                  style: TextStyles.money(context, size: 20),
                  decoration: InputDecoration(
                    labelText: 'Monthly Income',
                    prefixText: '${Formatters.currencySymbol} ',
                    prefixStyle: TextStyles.money(context,
                        size: 20, color: AppColorsOf.secondaryText(context)),
                    hintText: '85000',
                    prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: AppStrings.save,
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
}
