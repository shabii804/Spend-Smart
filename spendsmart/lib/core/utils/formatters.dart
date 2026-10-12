import 'package:intl/intl.dart';

/// Currency + date formatters.
class Formatters {
  Formatters._();

  /// Active currency symbol. PKR by default.
  /// Mutated by [CurrencyProvider] (defined in providers/currency_provider.dart).
  /// Kept here as a static field so widgets can call without context if needed.
  static String _currencySymbol = 'Rs.';
  static String _currencyLocale = 'en_PK';

  static void setCurrency(String symbol, String locale) {
    _currencySymbol = symbol;
    _currencyLocale = locale;
  }

  static String get currencySymbol => _currencySymbol;

  /// Formats an amount as "Rs. 12,500" with grouping.
  static String money(double amount) {
    final fmt = NumberFormat.currency(
      locale: _currencyLocale,
      symbol: '$_currencySymbol ',
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    );
    return fmt.format(amount).trim();
  }

  /// Money without the symbol — just grouped digits.
  static String moneyPlain(double amount) {
    final fmt = NumberFormat.currency(
      locale: _currencyLocale,
      symbol: '',
      decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
    );
    return fmt.format(amount).trim();
  }

  /// Compact money for tight chart labels: 12.5k, 1.2M.
  static String moneyCompact(double amount) {
    final fmt = NumberFormat.compact(locale: 'en_US');
    return '$_currencySymbol ${fmt.format(amount)}';
  }

  /// "10 Oct, 12:45 PM"
  static String dateTime(DateTime d) {
    final fmt = DateFormat('d MMM, hh:mm a');
    return fmt.format(d);
  }

  /// "10 Oct, 2026"
  static String date(DateTime d) => DateFormat('d MMM, yyyy').format(d);

  /// "10 Oct"
  static String dateShort(DateTime d) => DateFormat('d MMM').format(d);

  /// "October 2026"
  static String monthYear(DateTime d) => DateFormat('MMMM yyyy').format(d);

  /// "Mon"
  static String weekday(DateTime d) => DateFormat('EEE').format(d);

  /// "12:45 PM"
  static String time(DateTime d) => DateFormat('hh:mm a').format(d);

  /// "2026-10-10" (ISO-ish, used for storage keys)
  static String isoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// "1 Oct – 10 Oct" given two dates.
  static String dateRange(DateTime from, DateTime to) =>
      '${dateShort(from)} – ${dateShort(to)}';

  /// Relative time ago: "2h ago", "Just now", "5m ago".
  static String timeAgo(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final diff = n.difference(d);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return dateShort(d);
  }
}
