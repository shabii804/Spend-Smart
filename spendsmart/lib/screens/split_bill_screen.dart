import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/motion/haptics.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
import '../core/theme/text_styles.dart';
import '../core/utils/formatters.dart';
import '../core/widgets/animated_money.dart';
import '../core/widgets/glass_card.dart';
import '../core/widgets/modern_icon_badge.dart';
import '../core/widgets/primary_button.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';

/// Next-level Split Bill & Tip Calculator ("SplitSmart").
/// Allows users to split dining, rental, or trip bills easily among friends,
/// adjust tip percentages, copy the summary, or log their share as an expense.
class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final _amountCtrl = TextEditingController(text: '3000');
  int _peopleCount = 3;
  double _tipPercent = 10.0;
  static const _tipPresets = [0.0, 5.0, 10.0, 15.0, 20.0];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double get _billAmount => double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
  double get _tipAmount => (_billAmount * _tipPercent) / 100.0;
  double get _totalWithTip => _billAmount + _tipAmount;
  double get _perPersonAmount =>
      _peopleCount > 0 ? _totalWithTip / _peopleCount : _totalWithTip;

  void _addPreset(double amount) {
    Haptics.selection();
    final current = _billAmount;
    _amountCtrl.text = (current + amount).toInt().toString();
    setState(() {});
  }

  void _shareSummary() {
    Haptics.selection();
    final summary =
        '🧾 SplitSmart Summary\n'
        '• Total Bill: ${Formatters.money(_billAmount)}\n'
        '• Tip (${_tipPercent.toInt()}%): ${Formatters.money(_tipAmount)}\n'
        '• Total: ${Formatters.money(_totalWithTip)}\n'
        '• Split between: $_peopleCount people\n'
        '👉 Amount Per Person: ${Formatters.money(_perPersonAmount)}';

    Clipboard.setData(ClipboardData(text: summary));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.mint, size: 18),
            SizedBox(width: 8),
            Text('Bill summary copied to clipboard!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _logAsExpense() {
    Haptics.selection();
    final myShare = _perPersonAmount;
    final prefill = Expense(
      id: 'split_${DateTime.now().millisecondsSinceEpoch}',
      title: 'My Share: Dining Split',
      amount: myShare,
      categoryId: 'food',
      date: DateTime.now(),
      note: 'Split bill among $_peopleCount people (${Formatters.money(_totalWithTip)} total)',
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddExpenseScreen(prefill: prefill)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SplitSmart Bill'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Bill Summary',
            onPressed: _shareSummary,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ═══ HERO SPLIT RESULT CARD ═══
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppGradients.heroCard(context),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryIndigo.withOpacity(0.35),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EACH PERSON PAYS',
                        style: TextStyles.label(context).copyWith(
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$_peopleCount people',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AnimatedMoney(
                    amount: _perPersonAmount,
                    style: TextStyles.moneyHero(context, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withOpacity(0.2), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _heroStatItem('Total Bill', Formatters.money(_billAmount)),
                      Container(width: 1, height: 24, color: Colors.white.withOpacity(0.2)),
                      _heroStatItem('Tip (${_tipPercent.toInt()}%)', Formatters.money(_tipAmount)),
                      Container(width: 1, height: 24, color: Colors.white.withOpacity(0.2)),
                      _heroStatItem('Grand Total', Formatters.money(_totalWithTip)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ═══ BILL AMOUNT INPUT ═══
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ModernIconBadge(
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.primaryIndigo,
                        size: 34,
                        iconSize: 18,
                      ),
                      const SizedBox(width: 10),
                      Text('Total Bill Amount', style: TextStyles.h3(context)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyles.moneyDisplay(context),
                    textAlign: TextAlign.center,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixText: '${Formatters.currencySymbol} ',
                      prefixStyle: TextStyles.money(context, size: 24),
                      hintText: '0',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColorsOf.border(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryIndigo, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quick add presets
                  Row(
                    children: [500.0, 1000.0, 2000.0, 5000.0].map((amt) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _addPreset(amt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryIndigo.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.primaryIndigo.withOpacity(0.2),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+${Formatters.moneyPlain(amt)}',
                                style: TextStyles.caption(context, weight: FontWeight.w700).copyWith(
                                  color: AppColors.primaryIndigo,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═══ PEOPLE STEPPER ═══
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const ModernIconBadge(
                    icon: Icons.people_alt_rounded,
                    color: AppColors.blue,
                    size: 38,
                    iconSize: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Number of People', style: TextStyles.body(context, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Split equally among $_peopleCount', style: TextStyles.caption(context)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _stepperButton(
                        icon: Icons.remove_rounded,
                        onPressed: _peopleCount > 1
                            ? () {
                                Haptics.selection();
                                setState(() => _peopleCount--);
                              }
                            : null,
                      ),
                      Container(
                        constraints: const BoxConstraints(minWidth: 38),
                        alignment: Alignment.center,
                        child: Text(
                          '$_peopleCount',
                          style: TextStyles.h2(context),
                        ),
                      ),
                      _stepperButton(
                        icon: Icons.add_rounded,
                        onPressed: _peopleCount < 30
                            ? () {
                                Haptics.selection();
                                setState(() => _peopleCount++);
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ═══ TIP SELECTOR ═══
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ModernIconBadge(
                        icon: Icons.volunteer_activism_rounded,
                        color: AppColors.mint,
                        size: 38,
                        iconSize: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tip Percentage', style: TextStyles.body(context, weight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              '${Formatters.money(_tipAmount)} added as tip',
                              style: TextStyles.caption(context).copyWith(color: AppColors.mint),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: _tipPresets.map((tip) {
                      final isSelected = _tipPercent == tip;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () {
                              Haptics.selection();
                              setState(() => _tipPercent = tip);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryIndigo
                                    : AppColorsOf.background(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primaryIndigo
                                      : AppColorsOf.border(context),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${tip.toInt()}%',
                                style: TextStyles.body(context, weight: FontWeight.w700).copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColorsOf.secondaryText(context),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ═══ ACTION BUTTONS ═══
            PrimaryButton(
              label: 'Share Bill Summary',
              icon: Icons.share_rounded,
              onPressed: _shareSummary,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: AppColors.primaryIndigo.withOpacity(0.5)),
              ),
              icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
              label: Text(
                'Log My Share (${Formatters.money(_perPersonAmount)})',
                style: TextStyles.body(context, weight: FontWeight.w700).copyWith(
                  color: AppColors.primaryIndigo,
                ),
              ),
              onPressed: _logAsExpense,
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _stepperButton({required IconData icon, required VoidCallback? onPressed}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: onPressed != null
                ? AppColors.primaryIndigo.withOpacity(0.12)
                : AppColorsOf.border(context).withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: onPressed != null
                ? AppColors.primaryIndigo
                : AppColorsOf.tertiaryText(context),
            size: 20,
          ),
        ),
      ),
    );
  }
}
