import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/motion/app_motion.dart';
import '../../core/motion/haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/premium_motion.dart';
import '../../data/sample_data.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import 'receipt_scanner_screen.dart';
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
  bool _saved = false; // set once the expense is written — stops the dirty guard
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
        // Sync the date chip with the loaded date so the chip selection
        // reflects the actual date (Today / Yesterday / Pick date).
        _dateChip = _chipForDate(e.date);
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
      _dateChip = _chipForDate(e.date);
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

  /// Save is enabled only when BOTH amount > 0 AND a category is selected.
  /// Previously the button was enabled with just amount, then tapping it
  /// with no category showed a snackbar — confusing UX. Now the disabled
  /// state itself communicates the requirement.
  bool get _canSave => _hasAmount && _selectedCategoryId != null;

  String _formattedAmount() {
    final v = double.tryParse(_amountCtrl.text.trim());
    if (v == null || v <= 0) return '0';
    // Use Formatters.money (includes currency symbol) so the preview shows
    // "Rs. 1,500" instead of just "1,500" — clearer confirmation of the
    // total the user is about to save.
    return Formatters.money(v);
  }

  /// Map a DateTime to the matching quick-chip index (0=Today, 1=Yesterday,
  /// 2=Pick date). Used when prefilling from a scan or editing an existing
  /// expense so the chip selection reflects the actual date.
  int _chipForDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly == today) return 0;
    if (dateOnly == yesterday) return 1;
    return 2;
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    // User canceled the date picker — don't change _dateChip, the previous
    // selection stays active. (Previously _dateChip was set to 2 inside
    // _selectDateChip BEFORE the picker opened, so canceling left the chip
    // selected with no date picked — confusing.)
    if (d == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    setState(() {
      _dateChip = 2;
      if (t != null) {
        _date = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      } else {
        // Time sheet dismissed — keep the previous time-of-day instead of
        // silently resetting the expense to midnight.
        _date = DateTime(d.year, d.month, d.day, _date.hour, _date.minute);
      }
    });
  }

  void _selectDateChip(int chip) {
    if (chip == 2) {
      // Don't pre-set _dateChip = 2 — wait until a date is actually picked.
      // _pickDate() will set _dateChip = 2 inside setState once a date is
      // chosen; if the user cancels, the previous chip stays selected.
      _pickDate();
      return;
    }
    setState(() {
      _dateChip = chip;
      final now = DateTime.now();
      if (chip == 0) {
        _date = now;
      } else if (chip == 1) {
        _date = now.subtract(const Duration(days: 1));
      }
    });
  }

  /// True when the form holds content the user could lose by leaving.
  /// Guards the back button / system back gesture with a discard confirm.
  bool get _isDirty {
    if (_saved) return false;
    if (_isEdit) {
      final e = context.read<ExpenseProvider>().byId(widget.expenseId!);
      if (e == null) return _hasAmount || _selectedCategoryId != null;
      return _selectedCategoryId != e.categoryId ||
          _titleCtrl.text.trim() != e.title ||
          _noteCtrl.text.trim() != (e.note ?? '') ||
          double.tryParse(_amountCtrl.text.trim()) != e.amount ||
          _date.year != e.date.year ||
          _date.month != e.date.month ||
          _date.day != e.date.day ||
          _date.hour != e.date.hour ||
          _date.minute != e.date.minute;
    }
    return _hasAmount ||
        _selectedCategoryId != null ||
        _titleCtrl.text.trim().isNotEmpty ||
        _noteCtrl.text.trim().isNotEmpty;
  }

  Future<void> _confirmDiscard() async {
    final leave = await ConfirmDialog.show(
      context,
      title: 'Discard changes?',
      body: _isEdit
          ? 'Your edits to this expense will be lost.'
          : 'This expense hasn\u2019t been saved yet.',
      confirmLabel: 'Discard',
      danger: true,
      icon: Icons.delete_sweep_rounded,
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    // tryParse guards the window where the amount could have been cleared
    // mid-save (double.parse would crash on an empty string).
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _saving = false);
      return;
    }
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
    _saved = true; // back guard no longer needed — data is committed
    setState(() => _saving = false);
    if (!mounted) return;
    await showPremiumSuccess(context);
    if (!mounted) return;

    // ── Undo snackbar (only on create, not on edit) ──
    // Shows a snack with an UNDO action that removes the just-added expense.
    // Duration bumped from 4s → 6s so distracted users have more time to tap.
    if (!_isEdit && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(SnackBar(
        content: Text('Added ${Formatters.money(amount)} to ${SampleData.categoryById(expense.categoryId).name}'),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppColors.primaryIndigo,
          onPressed: () {
            prov.deleteExpense(expense.id);
            Haptics.selection();
            // Use the messenger captured before the pop — this State is
            // already unmounted when the undo fires, but the messenger
            // still serves the shell underneath.
            messenger.clearSnackBars();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Expense removed'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ));
    }

    if (Navigator.of(context).canPop()) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Block back (button or system gesture) while there is unsaved form
      // content and confirm before discarding. After a successful save
      // _saved flips _isDirty off so the normal pop goes through untouched.
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmDiscard();
      },
      child: Scaffold(
      appBar: AppBar(
        // Title removed — saves vertical space so the form fits on screen.
        title: const SizedBox.shrink(),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // Scan + Voice buttons moved OUT of the AppBar and into a prominent
        // row below the amount card — much more visible and beautiful.
      ),
      body: SafeArea(
        // Tap anywhere outside a field to dismiss the keyboard — on web/phone
        // there is no back gesture that reliably closes it, so an accidental
        // focus on the big amount field left the Save button hidden.
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            // The Scaffold already resizes for the keyboard (default
            // resizeToAvoidBottomInset) — padding viewInsets here as well
            // double-compensated and left a blank gap below the Save button.
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 2),

                // ═══ AMOUNT HERO CARD ═══
                _sectionCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label(context, 'Amount'),
                      const SizedBox(height: 2),
                      _amountHero(context),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ═══ SCAN + VOICE ACTION ROW ═══
                // Two prominent side-by-side buttons — beautiful placement
                // where the user can easily see and tap them. Replaces the
                // AppBar icons which were hard to find.
                if (!_isEdit)
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          icon: Icons.document_scanner_rounded,
                          label: 'Scan Receipt',
                          color: AppColors.mint,
                          onTap: () async {
                            Haptics.light();
                            final Expense? result =
                                await Navigator.of(context).push<Expense>(
                              MaterialPageRoute(
                                builder: (_) => const ReceiptScannerScreen(),
                              ),
                            );
                            if (result == null) return;
                            if (!mounted) return;
                            setState(() {
                              _amountCtrl.text = result.amount ==
                                      result.amount.roundToDouble()
                                  ? result.amount.toStringAsFixed(0)
                                  : result.amount.toStringAsFixed(2);
                              _selectedCategoryId = result.categoryId;
                              _date = result.date;
                              _noteCtrl.text = result.note ?? '';
                              _dateChip = _chipForDate(result.date);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _actionButton(
                          icon: Icons.mic_rounded,
                          label: 'Voice Input',
                          color: AppColors.primaryPurple,
                          onTap: () async {
                            Haptics.light();
                            // Voice screen hands back a prefilled expense —
                            // same contract as the receipt scanner, so we
                            // never stack a second AddExpense on top.
                            final Expense? result =
                                await Navigator.of(context).push<Expense>(
                              MaterialPageRoute(
                                  builder: (_) => const VoiceEntryScreen()),
                            );
                            if (result == null) return;
                            if (!mounted) return;
                            setState(() {
                              _amountCtrl.text = result.amount ==
                                      result.amount.roundToDouble()
                                  ? result.amount.toStringAsFixed(0)
                                  : result.amount.toStringAsFixed(2);
                              _selectedCategoryId = result.categoryId;
                              _date = result.date;
                              _noteCtrl.text = result.note ?? '';
                              _titleCtrl.text = result.title;
                              _dateChip = _chipForDate(result.date);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                if (!_isEdit) const SizedBox(height: 8),

                // ═══ Quick Add (horizontal scroll) ═══
                // ShaderMask fades the trailing edge so the cut-off chip
                // reads as "scrollable" instead of "broken layout".
                if (!_isEdit) ...[
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black,
                        Colors.black,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.88, 1.0],
                    ).createShader(bounds),
                    blendMode: BlendMode.dstIn,
                    child: SizedBox(
                    // 44px keeps the quick-add chips above the minimum
                    // comfortable touch-target size.
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
                  ),
                  const SizedBox(height: 8),
                ],

                // ═══ CATEGORY + DATE CARD (grouped — both relate to
                // "what kind of expense" and "when") ═══
                _sectionCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label(context, 'Category'),
                      const SizedBox(height: 6),
                      _categoryGrid(),
                      const SizedBox(height: 12),
                      // Subtle divider between category and date sections
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColorsOf.divider(context),
                      ),
                      const SizedBox(height: 12),
                      _label(context, 'Date'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(child: _dateChipBtn(0, 'Today')),
                          const SizedBox(width: 8),
                          Expanded(child: _dateChipBtn(1, 'Yesterday')),
                          const SizedBox(width: 8),
                          Expanded(child: _dateChipBtn(2, 'Pick date')),
                        ],
                      ),
                      if (_dateChip == 2) ...[
                        const SizedBox(height: 8),
                        Text(
                          Formatters.dateTime(_date),
                          style: TextStyles.caption(context)
                              .copyWith(color: AppColorsOf.secondaryText(context)),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ═══ NOTE CARD (only Note — Title field removed per user request) ═══
                _sectionCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label(context, 'Note (optional)'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _noteCtrl,
                        maxLines: 2,
                        maxLength: 80,
                        style: TextStyles.body(context),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'What was this expense for?',
                          counterText: '',
                          prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ═══ Save button ═══
                // Disabled until BOTH amount > 0 AND a category is selected.
                // Hint text below explains what's missing when disabled.
                MorphingLoadingButton(
                  label: _isEdit ? 'Save Changes' : 'Save Expense',
                  icon: _isEdit ? Icons.save_rounded : Icons.check_circle_rounded,
                  loading: _saving,
                  onPressed: _canSave ? _save : null,
                ),
                if (!_canSave && !_saving)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      _hasAmount
                          ? 'Pick a category to enable Save'
                          : 'Enter an amount to enable Save',
                      textAlign: TextAlign.center,
                      style: TextStyles.caption(context)
                          .copyWith(color: AppColorsOf.tertiaryText(context)),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section card — subtle bg + border + 14px padding. Groups related form
  /// fields together so the form has clear visual hierarchy.
  Widget _sectionCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColorsOf.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColorsOf.border(context)),
        boxShadow: Theme.of(context).brightness == Brightness.light
            ? [
                const BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  /// Premium action button — used for Scan Receipt + Voice Input.
  /// Two side-by-side below the amount card. Beautiful placement where
  /// the user can easily see and tap them.
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            border: Border.all(color: color.withOpacity(0.25), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Amount hero — centered 28px display inside the section card, with a
  /// trailing clear button that appears once digits exist (one tap resets
  /// the field instead of backspacing every digit).
  Widget _amountHero(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _amountField(context)),
            // Clear affordance — fades in only when there is something to
            // clear, so the hero reads as a clean centered number otherwise.
            AnimatedOpacity(
              opacity: _amountCtrl.text.isNotEmpty ? 1.0 : 0.0,
              duration: AppMotion.base,
              child: AnimatedScale(
                scale: _amountCtrl.text.isNotEmpty ? 1.0 : 0.6,
                duration: AppMotion.base,
                curve: AppMotion.celebrate,
                child: IconButton(
                  onPressed: _amountCtrl.text.isEmpty
                      ? null
                      : () {
                          Haptics.light();
                          _amountCtrl.clear();
                          FocusScope.of(context).requestFocus();
                        },
                  icon: const Icon(Icons.cancel_rounded),
                  color: AppColorsOf.tertiaryText(context),
                  iconSize: 20,
                  tooltip: 'Clear amount',
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),
        if (_hasAmount)
          TweenAnimationBuilder<double>(
            key: ValueKey(_formattedAmount()),
            tween: Tween(begin: 0.92, end: 1.0),
            duration: AppMotion.base,
            curve: AppMotion.celebrate,
            builder: (context, v, child) {
              return Transform.scale(scale: v, child: child);
            },
            child: Text(
              _formattedAmount(),
              style: TextStyles.caption(context, weight: FontWeight.w700)
                  .copyWith(color: AppColorsOf.secondaryText(context), fontSize: 13),
            ),
          ),
      ],
    );
  }

  /// The numeric amount field, extracted so the clear button can sit beside
  /// it in a Row without breaking the centered hero layout.
  Widget _amountField(BuildContext context) {
    return TextField(
      controller: _amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // Freeze the amount while the save animation runs — editing
      // during those 350ms could invalidate what is being parsed.
      readOnly: _saving,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      textAlign: TextAlign.center,
      autofocus: widget.prefill == null && widget.expenseId == null,
      // "Next" slides the keyboard focus down to the Note field instead of
      // just closing — matches the top-to-bottom flow of the form.
      textInputAction: TextInputAction.next,
      onSubmitted: (_) => FocusScope.of(context).nextFocus(),
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColorsOf.mainText(context),
        height: 1.1,
        letterSpacing: -0.6,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        prefixText: '${Formatters.currencySymbol} ',
        prefixStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColorsOf.secondaryText(context),
          height: 1.1,
          letterSpacing: -0.6,
        ),
        hintText: '0',
        hintStyle: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          // 0.8 (was 0.5) — the hint was nearly invisible on white, so
          // the empty field read as broken (just a floating "Rs.").
          color: AppColorsOf.tertiaryText(context).withOpacity(0.8),
          height: 1.1,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 2),
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: sel ? AppColors.primaryIndigo : AppColorsOf.card(context),
            border: Border.all(
              color: sel ? AppColors.primaryIndigo : AppColorsOf.border(context),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.caption(context, weight: FontWeight.w600)
                    .copyWith(color: sel ? Colors.white : AppColorsOf.secondaryText(context))),
          ),
        ),
      ),
    );
  }

  // ═══ Category grid — shortened labels, clear selected state ═══
  Widget _categoryGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      // 8 categories: 4 columns gives a balanced 4+4 grid on every standard
      // phone (the 390px iPhone class has ~322px inner width here). Only very
      // narrow containers drop to 3 columns — labels shrink via FittedBox
      // so they never overflow either way.
      final cols = constraints.maxWidth < 320 ? 3 : 4;
      return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        // Extra vertical headroom so icon circle + label never clip.
        childAspectRatio: cols == 3 ? 0.95 : 0.88,
      ),
      itemCount: SampleData.categories.length,
      itemBuilder: (ctx, i) {
        final c = SampleData.categories[i];
        final sel = _selectedCategoryId == c.id;
        final shortName = _shortLabels[c.id] ?? c.name;
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
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(shortName,
                            style: TextStyles.caption(context, weight: FontWeight.w600),
                            textAlign: TextAlign.center,
                            maxLines: 1),
                      ),
                    ],
                  ),
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
    });
  }

  Widget _label(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: TextStyles.label(context)),
    );
  }
}
