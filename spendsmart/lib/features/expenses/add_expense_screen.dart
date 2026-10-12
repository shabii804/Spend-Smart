import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/motion/app_motion.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/premium_motion.dart';
import '../../core/widgets/success_overlay.dart';
import '../../data/sample_data.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import 'voice_entry_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? prefill;
  final String? expenseId;

  const AddExpenseScreen({
    super.key,
    this.prefill,
    this.expenseId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String? _selectedCategoryId;
  DateTime _date = DateTime.now();
  bool _isEdit = false;
  bool _saving = false;
  int _dateChip = 0; // 0=Today, 1=Yesterday, 2=Pick

  static const _quickAdd = [
    ('Canteen', 'food', Icons.restaurant_rounded, AppColors.catFood),
    ('Transport', 'transport', Icons.directions_bus_rounded, AppColors.catTransport),
    ('Printing', 'others', Icons.print_rounded, AppColors.catOthers),
    ('Shopping', 'shopping', Icons.shopping_bag_rounded, AppColors.catShopping),
  ];

  // Shortened category labels (never truncate)
  static const _shortLabels = {
    'food': 'Food',
    'transport': 'Transport',
    'groceries': 'Groceries',
    'entertainment': 'Fun',
    'bills': 'Bills',
    'internet': 'Internet',
    'shopping': 'Shopping',
    'others': 'Other',
  };

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
    // Listen to amount changes for live formatting + button state
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  bool get _hasAmount {
    final v = double.tryParse(_amountCtrl.text.trim());
    return v != null && v > 0;
  }

  String _formattedAmount() {
    final v = double.tryParse(_amountCtrl.text.trim());
    if (v == null || v <= 0) return '0';
    return Formatters.moneyPlain(v);
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
        setState(() {
          _date = DateTime(d.year, d.month, d.day, t.hour, t.minute);
          _dateChip = 2;
        });
      } else {
        setState(() { _date = d; _dateChip = 2; });
      }
    }
  }

  void _selectDateChip(int chip) {
    setState(() {
      _dateChip = chip;
      final now = DateTime.now();
      if (chip == 0) {
        _date = now;
      } else if (chip == 1) {
        _date = now.subtract(const Duration(days: 1));
      } else {
        _pickDate();
      }
    });
  }

  Future<void> _save() async {
    if (!_hasAmount) return;
    if (_selectedCategoryId == null) {
      Haptics.error();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')));
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
      title: _titleCtrl.text.trim().isEmpty
          ? SampleData.categoryById(_selectedCategoryId!).name
          : _titleCtrl.text.trim(),
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
    await showPremiumSuccess(context);
    if (!mounted) return;

    // ── Undo snackbar (only on create, not on edit) ──
    // Shows a snack with an UNDO action that removes the just-added expense.
    if (!_isEdit && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      // Clear any existing snack first so the new one is visible.
      messenger.clearSnackBars();
      messenger.showSnackBar(SnackBar(
        content: Text('Added ${Formatters.money(amount)} to ${SampleData.categoryById(expense.categoryId).name}'),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryIndigo,
          onPressed: () {
            prov.deleteExpense(expense.id);
            Haptics.selection();
            if (mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense removed'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ));
    }

    if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Expense' : 'Add Expense'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // ═══ Amount HERO (48px centered display) ═══
              _amountHero(context),
              const SizedBox(height: 16),

              // ═══ Quick Add (directly under amount) ═══
              if (!_isEdit) ...[
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickAdd.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final q = _quickAdd[i];
                      final qSel = _selectedCategoryId == q.$2;
                      return GestureDetector(
                        onTap: () {
                          Haptics.selection();
                          setState(() {
                            _selectedCategoryId = q.$2;
                            if (_titleCtrl.text.isEmpty) _titleCtrl.text = q.$1;
                          });
                        },
                        child: AnimatedScale(
                          scale: qSel ? 1.06 : 1.0,
                          duration: AppMotion.base,
                          curve: AppMotion.celebrate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: qSel
                                  ? q.$4.withOpacity(0.18)
                                  : AppColorsOf.card(context),
                              border: Border.all(
                                color: qSel ? q.$4 : AppColorsOf.border(context),
                                width: qSel ? 1.6 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(q.$3, size: 14, color: q.$4),
                                const SizedBox(width: 6),
                                Text(q.$1,
                                    style: TextStyles.caption(context, weight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ═══ Category grid (shortened labels, never truncate) ═══
              _label(context, 'Category'),
              const SizedBox(height: 8),
              _categoryGrid(),
              const SizedBox(height: 16),

              // ═══ Date chips (Today / Yesterday / Pick date) ═══
              _label(context, 'Date'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _dateChipBtn(0, 'Today')),
                  const SizedBox(width: 8),
                  Expanded(child: _dateChipBtn(1, 'Yesterday')),
                  const SizedBox(width: 8),
                  Expanded(child: _dateChipBtn(2, 'Pick date')),
                ],
              ),
              const SizedBox(height: 4),
              if (_dateChip == 2)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(Formatters.dateTime(_date),
                      style: TextStyles.caption(context)),
                ),
              const SizedBox(height: 16),

              // ═══ Title (optional — defaults to category name) ═══
              _label(context, 'Title (optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                style: TextStyles.body(context),
                decoration: InputDecoration(
                  hintText: 'e.g. Lunch at cafe',
                  prefixIcon: const Icon(Icons.edit_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 16),

              // ═══ Note (optional) ═══
              _label(context, 'Note (optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                maxLength: 80,
                style: TextStyles.body(context),
                decoration: InputDecoration(
                  hintText: 'What was this expense for?',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),

              // ═══ Save button (DISABLED until amount > 0) ═══
              MorphingLoadingButton(
                label: _isEdit ? 'Save' : 'Save Expense',
                icon: _isEdit ? Icons.save_rounded : Icons.check_circle_rounded,
                loading: _saving,
                onPressed: _hasAmount ? _save : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ═══ Amount hero — centered 48px display ═══
  Widget _amountHero(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
          textAlign: TextAlign.center,
          autofocus: true,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: AppColorsOf.mainText(context),
            height: 1.05,
            letterSpacing: -1.0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            prefixText: 'Rs. ',
            prefixStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColorsOf.secondaryText(context),
              height: 1.05,
              letterSpacing: -1.0,
            ),
            hintText: '0',
            hintStyle: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: AppColorsOf.tertiaryText(context).withOpacity(0.3),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
        ),
        // Live formatted preview with subtle scale-pop when amount changes.
        // This is the "digit roll" feel — the formatted preview pulses
        // whenever the parsed amount changes, giving visual confirmation.
        if (_hasAmount)
          TweenAnimationBuilder<double>(
            key: ValueKey(_formattedAmount()),
            tween: Tween(begin: 0.92, end: 1.0),
            duration: AppMotion.base,
            curve: AppMotion.celebrate,
            builder: (context, v, child) {
              return Transform.scale(scale: v, child: child);
            },
            child: Text(_formattedAmount(),
                style: TextStyles.caption(context)
                    .copyWith(color: AppColorsOf.secondaryText(context))),
          ),
      ],
    );
  }

  // ═══ Date chip button ═══
  Widget _dateChipBtn(int chip, String label) {
    final sel = _dateChip == chip;
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        _selectDateChip(chip);
      },
      child: AnimatedScale(
        scale: sel ? 1.04 : 1.0,
        duration: AppMotion.base,
        curve: AppMotion.celebrate,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppColors.primaryIndigo : AppColorsOf.card(context),
            border: Border.all(
              color: sel ? AppColors.primaryIndigo : AppColorsOf.border(context),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyles.caption(context, weight: FontWeight.w600)
                  .copyWith(color: sel ? Colors.white : AppColorsOf.secondaryText(context))),
        ),
      ),
    );
  }

  // ═══ Category grid — shortened labels, clear selected state ═══
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
      itemBuilder: (ctx, i) {
        final c = SampleData.categories[i];
        final sel = _selectedCategoryId == c.id;
        final shortName = _shortLabels[c.id] ?? c.name;
        // ── Scale pop on selection ──
        // Selected items scale up to 1.06 with an easeOutBack curve for a
        // delightful pop. Unselected items scale to 1.0 (default).
        return GestureDetector(
          onTap: () {
            Haptics.selection();
            setState(() => _selectedCategoryId = c.id);
          },
          child: AnimatedScale(
            scale: sel ? 1.06 : 1.0,
            duration: AppMotion.effective(ctx, AppMotion.base),
            curve: AppMotion.effectiveCurve(ctx, AppMotion.celebrate),
            child: AnimatedContainer(
              duration: AppMotion.base,
              curve: AppMotion.standard,
              decoration: BoxDecoration(
                color: sel ? c.color.withOpacity(0.18) : AppColorsOf.card(context),
                border: Border.all(
                  color: sel ? c.color : AppColorsOf.border(context),
                  width: sel ? 1.6 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Icon also pops (scales up when selected) ──
                      AnimatedScale(
                        scale: sel ? 1.12 : 1.0,
                        duration: AppMotion.base,
                        curve: AppMotion.celebrate,
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: c.color.withOpacity(0.16),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(c.icon, color: c.color, size: 18),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(shortName,
                          style: TextStyles.caption(context, weight: FontWeight.w600),
                          textAlign: TextAlign.center,
                          maxLines: 1),
                    ],
                  ),
                  // Check mark when selected (drawn in with scale)
                  if (sel)
                    Positioned(
                      top: 6, right: 6,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: AppMotion.base,
                        curve: AppMotion.celebrate,
                        builder: (context, v, child) {
                          return Transform.scale(scale: v, child: child);
                        },
                        child: Container(
                          width: 18, height: 18,
                          decoration: BoxDecoration(
                            color: c.color,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: TextStyles.label(context)),
    );
  }
}
