import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart' as app_models;
import '../data/sample_data.dart';

typedef AppCategory = app_models.Category;

/// Owns the expense list and all derived aggregations.
/// Charts, dashboard and analytics read directly from this provider.
class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider() : _expenses = List.of(SampleData.expenses);

  List<Expense> _expenses;
  List<Expense> get expenses => List.unmodifiable(_expenses);

  // ---------- Mutations ----------
  void addExpense(Expense e) {
    _expenses.insert(0, e);
    notifyListeners();
  }

  void updateExpense(Expense updated) {
    final i = _expenses.indexWhere((e) => e.id == updated.id);
    if (i >= 0) {
      _expenses[i] = updated;
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Expense? byId(String id) {
    for (final e in _expenses) {
      if (e.id == id) return e;
    }
    return null;
  }

  // ---------- Derived getters ----------

  /// Returns expenses for the currently displayed month (defaults to "this month").
  /// In this demo we anchor to the most recent expense's month so October 2026
  /// sample data always shows up even if today's wall-clock month is different.
  DateTime get _anchorMonth {
    if (_expenses.isEmpty) return DateTime.now();
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    return _expenses.first.date;
  }

  List<Expense> get _monthExpenses {
    final anchor = _anchorMonth;
    return _expenses.where((e) =>
        e.date.year == anchor.year && e.date.month == anchor.month).toList();
  }

  double get totalSpent =>
      _monthExpenses.fold(0.0, (s, e) => s + e.amount);

  double get remaining {
    // avoid circular dependency on BudgetProvider: read limit from SampleData
    final limit = SampleData.budget.monthlyLimit;
    return limit - totalSpent;
  }

  double get percentUsed {
    final limit = SampleData.budget.monthlyLimit;
    if (limit == 0) return 0;
    return (totalSpent / limit).clamp(0.0, 1.5);
  }

  /// Map of categoryId -> total for current month.
  Map<String, double> get categoryTotals {
    final m = <String, double>{};
    for (final e in _monthExpenses) {
      m[e.categoryId] = (m[e.categoryId] ?? 0) + e.amount;
    }
    return m;
  }

  /// Map of ISO date string -> total for current month.
  Map<String, double> get dailyTotals {
    final m = <String, double>{};
    for (final e in _monthExpenses) {
      final k = '${e.date.year}-${e.date.month}-${e.date.day}';
      m[k] = (m[k] ?? 0) + e.amount;
    }
    return m;
  }

  /// Map of ISO week (year-weekNumber) -> total for current month.
  Map<String, double> get weeklyTotals {
    final m = <String, double>{};
    for (final e in _monthExpenses) {
      final wk = _weekKey(e.date);
      m[wk] = (m[wk] ?? 0) + e.amount;
    }
    return m;
  }

  /// Map of month (year-month) -> total. Used by monthly trend chart.
  Map<String, double> get monthlyTotals {
    final m = <String, double>{};
    for (final e in _expenses) {
      final k = '${e.date.year}-${e.date.month}';
      m[k] = (m[k] ?? 0) + e.amount;
    }
    return m;
  }

  /// Average daily spend across the days that have transactions this month.
  double get averageDailySpend {
    final totals = dailyTotals;
    if (totals.isEmpty) return 0;
    return totalSpent / totals.length;
  }

  /// Day of month with the highest total spend this month.
  MapEntry<DateTime, double>? get highestSpendingDay {
    if (_monthExpenses.isEmpty) return null;
    final byDay = <DateTime, double>{};
    for (final e in _monthExpenses) {
      final k = DateTime(e.date.year, e.date.month, e.date.day);
      byDay[k] = (byDay[k] ?? 0) + e.amount;
    }
    final sorted = byDay.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first;
  }

  /// Returns the last [n] transactions sorted by date desc.
  List<Expense> recentTransactions(int n) {
    final sorted = List<Expense>.of(_expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(n).toList();
  }

  /// Last 7 days of spend (oldest → newest) for the dashboard line chart.
  List<MapEntry<String, double>> last7Days() {
    final anchor = _anchorMonth;
    final out = <MapEntry<String, double>>[];
    for (int i = 6; i >= 0; i--) {
      final d = anchor.subtract(Duration(days: i));
      final key = '${d.year}-${d.month}-${d.day}';
      out.add(MapEntry(_shortDay(d), dailyTotals[key] ?? 0));
    }
    return out;
  }

  /// Last 4 weeks of spend (oldest → newest) for the Analytics weekly view.
  /// Each week runs Mon–Sun; the most-recent week is the current week
  /// (even if incomplete). Labels are short date ranges like "Sep 29–Oct 5".
  List<MapEntry<String, double>> last4Weeks() {
    final out = <MapEntry<String, double>>[];
    final now = DateTime.now();
    // Find the Monday of the current week (DateTime.weekday returns 1=Mon..7=Sun).
    final daysFromMonday = now.weekday - 1;
    final thisMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysFromMonday));
    for (int i = 3; i >= 0; i--) {
      final weekStart = thisMonday.subtract(Duration(days: 7 * i));
      final weekEnd = weekStart.add(const Duration(days: 6));
      double sum = 0;
      for (int d = 0; d < 7; d++) {
        final day = weekStart.add(Duration(days: d));
        if (day.isAfter(now)) break; // don't count future days
        final key = '${day.year}-${day.month}-${day.day}';
        sum += dailyTotals[key] ?? 0;
      }
      // Label: "Sep 29–Oct 5" — compact date range.
      final label = '${_shortMonth(weekStart)} ${weekStart.day}'
          '–${_shortMonth(weekEnd)} ${weekEnd.day}';
      out.add(MapEntry(label, sum));
    }
    return out;
  }

  /// Total number of transactions for the current month. Used by the
  /// Profile screen's stats row.
  int get transactionCount => _monthExpenses.length;

  /// Per-category totals for a given list of categories (e.g. top 4).
  List<MapEntry<AppCategory, double>> topCategories(int n) {
    final totals = categoryTotals;
    final entries = SampleData.categories
        .map((c) => MapEntry(c, totals[c.id] ?? 0))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(n).toList();
  }

  // ---------- helpers ----------
  String _shortDay(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[d.weekday - 1];
  }

  /// Short month name (Jan, Feb, …, Dec) — used by last4Weeks() labels.
  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  String _shortMonth(DateTime d) => _monthNames[d.month - 1];

  String _weekKey(DateTime d) {
    // ISO week approximation (good enough for demo charts)
    final firstJan = DateTime(d.year, 1, 1);
    final dayOfYear = d.difference(firstJan).inDays + 1;
    final week = ((dayOfYear - 1) / 7).floor() + 1;
    return '${d.year}-W$week';
  }
}
