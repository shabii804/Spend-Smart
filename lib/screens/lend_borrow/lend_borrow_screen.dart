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
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/success_overlay.dart';
import '../../models/ledger_entry.dart';
import '../../providers/lend_borrow_provider.dart';

/// Lend & Borrow — a friend-money ledger.
/// Track money you GAVE to friends (they owe you) and money you TOOK
/// (you owe them), settle debts when paid back, and see your net position.
class LendBorrowScreen extends StatefulWidget {
  const LendBorrowScreen({super.key});

  @override
  State<LendBorrowScreen> createState() => _LendBorrowScreenState();
}

class _LendBorrowScreenState extends State<LendBorrowScreen> {
  bool _outstandingTab = true;

  @override
  Widget build(BuildContext context) {
    final ledger = context.watch<LendBorrowProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lend & Borrow'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _summary(ledger),
            ),
            const SizedBox(height: 14),
            _segmented(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: _outstandingTab
                    ? _list(ledger.outstanding, settled: false)
                    : _list(ledger.settledEntries, settled: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Summary — gave / took / net
  // ─────────────────────────────────────────────────────────────
  Widget _summary(LendBorrowProvider ledger) {
    return Row(
      children: [
        _statCard(
          label: 'You Gave',
          value: Formatters.money(ledger.totalGiven),
          color: AppColors.catFood,
          icon: Icons.north_east_rounded,
        ),
        const SizedBox(width: 10),
        _statCard(
          label: 'You Took',
          value: Formatters.money(ledger.totalTaken),
          color: AppColors.primaryIndigo,
          icon: Icons.south_west_rounded,
        ),
        const SizedBox(width: 10),
        _statCard(
          label: 'Net',
          value: Formatters.money(ledger.net),
          color: ledger.net >= 0 ? AppColors.mint : AppColors.danger,
          icon: Icons.balance_rounded,
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(height: 6),
            Text(label, style: TextStyles.caption(context)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyles.money(context, size: 14, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Segmented — Outstanding / Settled
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
              icon: Icons.hourglass_top_rounded,
              label: 'Outstanding',
              selected: _outstandingTab,
              onTap: () {
                Haptics.selection();
                setState(() => _outstandingTab = true);
              },
            ),
            _segment(
              icon: Icons.task_alt_rounded,
              label: 'Settled',
              selected: !_outstandingTab,
              onTap: () {
                Haptics.selection();
                setState(() => _outstandingTab = false);
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
  // Lists
  // ─────────────────────────────────────────────────────────────
  Widget _list(List<LedgerEntry> items, {required bool settled}) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
                settled
                    ? Icons.task_alt_rounded
                    : Icons.volunteer_activism_rounded,
                size: 44,
                color: AppColorsOf.tertiaryText(context),),
            const SizedBox(height: 10),
            Text(
              settled
                  ? 'Nothing settled yet — settle a debt from the Outstanding tab'
                  : 'All clear! No pending money with friends',
              style: TextStyles.caption(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return Column(children: items.map((e) => _tile(e, settled)).toList());
  }

  Widget _tile(LedgerEntry e, bool settled) {
    final given = e.direction == LedgerDirection.given;
    final color = given ? AppColors.catFood : AppColors.primaryIndigo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.16),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    e.person.isNotEmpty ? e.person[0].toUpperCase() : '?',
                    style: TextStyles.body(context,
                        weight: FontWeight.w800, color: color,),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        given ? '${e.person} owes you' : 'You owe ${e.person}',
                        style: TextStyles.body(context,
                            weight: FontWeight.w600,),),
                      const SizedBox(height: 2),
                      Text(
                        e.note.isEmpty
                            ? DateFormat('d MMM yyyy').format(e.date)
                            : '${e.note} · ${DateFormat('d MMM yyyy').format(e.date)}',
                        style: TextStyles.caption(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${given ? '+' : '-'}${Formatters.money(e.amount)}',
                  style: TextStyles.money(context,
                      size: 15,
                      color: e.settled
                          ? AppColorsOf.tertiaryText(context)
                          : color,),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (settled) ...[
                  Icon(Icons.check_circle_rounded,
                      size: 15, color: AppColors.mint,),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Settled ${e.settledDate == null ? '' : DateFormat('d MMM').format(e.settledDate!)}',
                      style: TextStyles.caption(context, color: AppColors.mint),
                    ),
                  ),
                  _actionChip(
                    icon: Icons.undo_rounded,
                    label: 'Undo',
                    onTap: () {
                      Haptics.selection();
                      context.read<LendBorrowProvider>().unSettle(e.id);
                    },
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      given
                          ? 'Waiting for ${e.person} to pay back'
                          : 'Pay ${e.person} back when you can',
                      style: TextStyles.caption(context),
                    ),
                  ),
                  _actionChip(
                    icon: Icons.check_rounded,
                    label: 'Settle',
                    onTap: () async {
                      Haptics.selection();
                      context.read<LendBorrowProvider>().settle(e.id);
                      await SuccessOverlay.show(
                        context,
                        label: given
                            ? 'Marked as paid back!'
                            : 'Debt cleared!',
                        icon: Icons.handshake_rounded,
                      );
                    },
                  ),
                ],
                const SizedBox(width: 6),
                _actionChip(
                  icon: Icons.delete_outline_rounded,
                  label: '',
                  onTap: () {
                    Haptics.selection();
                    context.read<LendBorrowProvider>().delete(e.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColorsOf.card(context),
          border: Border.all(color: AppColorsOf.border(context)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColorsOf.secondaryText(context)),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyles.caption(context, weight: FontWeight.w700),),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Add-entry bottom sheet
  // ─────────────────────────────────────────────────────────────
  void _showAddSheet(BuildContext context) {
    Haptics.selection();
    final formKey = GlobalKey<FormState>();
    final personCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var given = true; // true = I gave, false = I took

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: GlassCard(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add Ledger Entry', style: TextStyles.h3(sheetCtx)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _directionChip(
                          sheetCtx,
                          icon: Icons.north_east_rounded,
                          label: 'I Gave',
                          selected: given,
                          color: AppColors.catFood,
                          onTap: () => setSheetState(() => given = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _directionChip(
                          sheetCtx,
                          icon: Icons.south_west_rounded,
                          label: 'I Took',
                          selected: !given,
                          color: AppColors.primaryIndigo,
                          onTap: () => setSheetState(() => given = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: personCtrl,
                    validator: Validators.required,
                    textInputAction: TextInputAction.next,
                    style: TextStyles.body(sheetCtx, weight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: "Friend's name",
                      prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountCtrl,
                    validator: Validators.amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),),
                    ],
                    textInputAction: TextInputAction.next,
                    style: TextStyles.money(sheetCtx, size: 20),
                    decoration: InputDecoration(
                      prefixText: '${Formatters.currencySymbol} ',
                      prefixStyle: TextStyles.money(sheetCtx,
                          size: 20,
                          color: AppColorsOf.secondaryText(sheetCtx),),
                      hintText: 'Amount',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteCtrl,
                    textInputAction: TextInputAction.done,
                    style: TextStyles.body(sheetCtx, weight: FontWeight.w600),
                    decoration: const InputDecoration(
                      hintText: 'Note (optional) — e.g. Lunch, Uber',
                      prefixIcon: Icon(Icons.edit_note_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Save Entry',
                    icon: Icons.check_circle_rounded,
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      final amount =
                          double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                      context.read<LendBorrowProvider>().addEntry(
                            person: personCtrl.text,
                            amount: amount,
                            direction: given
                                ? LedgerDirection.given
                                : LedgerDirection.taken,
                            note: noteCtrl.text,
                          );
                      Navigator.of(sheetCtx).pop();
                      SuccessOverlay.show(
                        context,
                        label: given
                            ? 'Recorded — they owe you!'
                            : 'Recorded — you owe them!',
                        icon: Icons.handshake_rounded,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _directionChip(
    BuildContext ctx, {
    required IconData icon,
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : Colors.transparent,
          border: Border.all(
            color: selected ? color : AppColorsOf.border(ctx),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 17,
                color: selected ? color : AppColorsOf.secondaryText(ctx),),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyles.caption(ctx, weight: FontWeight.w700).copyWith(
                color: selected ? color : AppColorsOf.secondaryText(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
