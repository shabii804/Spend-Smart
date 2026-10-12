import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Premium money display widget.
/// Handles: Rs. prefix, +/- sign, tabular figures (aligned digits),
/// compact K/M format for charts, color by sign (red for negative, mint for positive).
///
/// Usage:
///   MoneyText(amount: 10860)             → "Rs. 10,860"
///   MoneyText(amount: -320, signed: true) → "-Rs. 320" (red)
///   MoneyText(amount: 15000, compact: true) → "Rs. 15K"
///   MoneyText(amount: 25000, size: 40)    → "Rs. 25,000" (display size)
class MoneyText extends StatelessWidget {
  final double amount;
  final double size;
  final FontWeight weight;
  final Color? color;
  final bool signed; // show +/- sign
  final bool compact; // K/M format (for charts, tight spaces)
  final bool showSignColor; // red for negative, mint for positive
  final TextOverflow overflow;
  final int? maxLines;

  const MoneyText({
    super.key,
    required this.amount,
    this.size = 14,
    this.weight = FontWeight.w600,
    this.color,
    this.signed = false,
    this.compact = false,
    this.showSignColor = false,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final text = _format();
    final textColor = _color(context);

    return Text(
      text,
      style: TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: size,
        fontWeight: weight,
        color: textColor,
        height: 1.2,
        letterSpacing: -0.3,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      overflow: overflow,
      maxLines: maxLines,
    );
  }

  String _format() {
    if (compact) return Formatters.moneyCompact(amount);

    final prefix = Formatters.currencySymbol;
    if (signed) {
      final sign = amount >= 0 ? '+' : '-';
      return '$sign$prefix ${Formatters.moneyPlain(amount.abs())}';
    }
    return Formatters.money(amount);
  }

  Color _color(BuildContext context) {
    if (color != null) return color!;
    if (showSignColor) {
      if (amount < 0) return AppColors.danger;
      if (amount > 0) return AppColors.success;
    }
    return AppColorsOf.mainText(context);
  }
}
