import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/success_overlay.dart';
import '../../data/sample_data.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import 'voice_entry_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? prefill;
  final String? expenseId; // when editing

  const AddExpenseScreen({
    super.key,
    this.prefill,
    this.expenseId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _selectedCategoryId;
  DateTime _date = DateTime.now();
  bool _isEdit = false;
  bool _saving = false;
  int _mode = 0; // 0=Manual, 1=Voice

  static const _quickAdd = [
    ('Food', 'food', Icons.restaurant_rounded, AppColors.catFood),
    ('Transport', 'transport', Icons.directions_bus_rounded, AppColors.catTransport),
    ('Coffee', 'food', Icons.coffee_rounded, AppColors.catFood),
    ('Shopping', 'shopping', Icons.shopping_bag_rounded, AppColors.catShopping),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _isEdit = true;
      final e = context.read<ExpenseProvider>().byId(widget.expenseId!);
      if (e != null) {
        _titleCtrl.text = e.title;
        _amountCtrl.text = e.amount == e.amount.roundToDouble()
            ? e.amount.toStringAsFixed(0)
            : e.amount.toStringAsFixed(2);
        _selectedCategoryId = e.categoryId;
        _date = e.date;
        _noteCtrl.text = e.note ?? '';
      }
    } else if (widget.prefill != null) {
      final e = widget.prefill!;
      _titleCtrl.text = e.title;
      _amountCtrl.text = e.amount == e.amount.roundToDouble()
          ? e.amount.toStringAsFixed(0)
          : e.amount.toStringAsFixed(2);
      _selectedCategoryId = e.categoryId;
      _date = e.date;
      _noteCtrl.text = e.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2025),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_date),
      );
      if (t != null) {
        setState(() => _date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
      } else {
        setState(() => _date = d);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final amount = double.parse(_amountCtrl.text.trim());
    final expense = Expense(
      id: _isEdit
          ? (widget.expenseId ?? widget.prefill?.id ?? DateTime.now().millisecondsSinceEpoch.toString())
          : 'e${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      amount: amount,
      categoryId: _selectedCategoryId!,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    final prov = context.read<ExpenseProvider>();
    if (_isEdit) {
      prov.updateExpense(expense);
    } else {
      prov.addExpense(expense);
    }
    setState(() => _saving = false);
    if (!mounted) return;
    // Premium success animation + haptic feedback
    await SuccessOverlay.show(
      context,
      label: _isEdit ? AppStrings.expenseUpdated : AppStrings.expenseAdded,
      icon: Icons.check_rounded,
    );
    if (!mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? AppStrings.editExpense : AppStrings.addExpense),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              const SizedBox(height: 8),
              _modeToggle(),
              const SizedBox(height: 20),
              _amountField(context),
              const SizedBox(height: 16),
              _label(context, AppStrings.category),
              const SizedBox(height: 8),
              _categoryGrid(),
              const SizedBox(height: 16),
              _label(context, AppStrings.date),
              const SizedBox(height: 8),
              _dateRow(context),
              const SizedBox(height: 16),
              _noteField(),
              const SizedBox(height: 24),
              PrimaryButton(
                label: _isEdit ? AppStrings.save : 'Save Expense',
                icon: Icons.arrow_forward_rounded,
                loading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: 24),
              if (!_isEdit) ...[
                _label(context, 'Quick Add'),
                const SizedBox(height: 8),
                _quickAddRow(),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Manual / Voice segmented toggle (capsule shape)
  // ────────────────────────────────────────────────────────────────
  Widget _modeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        border: Border.all(color: AppColorsOf.border(context)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _toggleItem(0, Icons.keyboard_rounded, 'Manual'),
          _toggleItem(1, Icons.mic_rounded, 'Voice'),
        ],
      ),
    );
  }

  Widget _toggleItem(int idx, IconData icon, String label) {
    final sel = _mode == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (idx == 1) {
            // Voice mode → push to VoiceEntryScreen
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VoiceEntryScreen()),
            );
          } else {
            setState(() => _mode = idx);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: sel ? AppGradients.primaryButton : null,
            color: sel ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: sel ? Colors.white : AppColorsOf.secondaryText(context)),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyles.caption(context, weight: FontWeight.w700)
                      .copyWith(
                          color: sel ? Colors.white : AppColorsOf.secondaryText(context))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: TextStyles.label(context)),
    );
  }

  Widget _amountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(AppStrings.amount, style: TextStyles.label(context)),
        ),
        TextFormField(
          controller: _amountCtrl,
          validator: Validators.amount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          style: TextStyles.money(context, size: 28),
          decoration: InputDecoration(
            prefixText: '${Formatters.currencySymbol} ',
            prefixStyle: TextStyles.money(context, size: 28,
                color: AppColorsOf.secondaryText(context)),
            hintText: '0.00',
            suffixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.primaryIndigo),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Category grid — 8 categories inline (4 cols x 2 rows)
  // ────────────────────────────────────────────────────────────────
  Widget _categoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.92,
      ),
      itemCount: SampleData.categories.length,
      itemBuilder: (_, i) {
        final c = SampleData.categories[i];
        final sel = _selectedCategoryId == c.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategoryId = c.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: sel
                  ? c.color.withOpacity(0.18)
                  : AppColorsOf.card(context),
              border: Border.all(
                color: sel ? c.color : AppColorsOf.border(context),
                width: sel ? 1.6 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c.color.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(c.icon, color: c.color, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  c.name.length > 10 ? c.name.substring(0, 8) + '…' : c.name,
                  style: TextStyles.caption(context, weight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dateRow(BuildContext context) {
    return Material(
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
              const Icon(Icons.calendar_today_rounded,
                  color: AppColors.primaryIndigo, size: 18),
              const SizedBox(width: 12),
              Text(Formatters.dateTime(_date),
                  style: TextStyles.body(context, weight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primaryIndigo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Note (Optional)', style: TextStyles.label(context)),
        ),
        TextFormField(
          controller: _noteCtrl,
          maxLines: 2,
          maxLength: 80,
          style: TextStyles.body(context),
          decoration: InputDecoration(
            hintText: 'What was this expense for?',
            prefixIcon: const Icon(Icons.edit_rounded, size: 18),
            counterText: '',
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Quick Add — horizontal chips for common categories
  // ────────────────────────────────────────────────────────────────
  Widget _quickAddRow() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickAdd.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final q = _quickAdd[i];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedCategoryId = q.$2;
              if (_titleCtrl.text.isEmpty) _titleCtrl.text = q.$1;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColorsOf.card(context),
                border: Border.all(color: AppColorsOf.border(context)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: q.$4.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(q.$3, color: q.$4, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(q.$1,
                      style: TextStyles.caption(context, weight: FontWeight.w700)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
