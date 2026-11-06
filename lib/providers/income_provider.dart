import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_data.dart';
import '../models/income_entry.dart';

/// Tracks both income kinds:
/// 1. Job income — a fixed monthly salary (single value).
/// 2. Other earnings — one-off/random income entries (freelance, gifts...).
///
/// Everything is persisted to SharedPreferences so the module survives
/// app restarts, like the rest of the app's providers.
class IncomeProvider extends ChangeNotifier {
  static const _kJobIncome = 'income_job_monthly';
  static const _kEarnings = 'income_other_entries';

  double _jobIncome = SampleData.user.monthlyIncome;
  List<IncomeEntry> _earnings = [
    IncomeEntry(
      id: 'inc-sample-1',
      source: 'Freelance project',
      amount: 15000,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    IncomeEntry(
      id: 'inc-sample-2',
      source: 'Birthday gift',
      amount: 5000,
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
    IncomeEntry(
      id: 'inc-sample-3',
      source: 'Cashback reward',
      amount: 1200,
      date: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  IncomeProvider() {
    _loadFromPrefs();
  }

  double get jobIncome => _jobIncome;

  /// One-off earnings, newest first.
  List<IncomeEntry> get earnings {
    final sorted = List<IncomeEntry>.of(_earnings)
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  /// Sum of one-off earnings received in [month] (defaults to this month).
  double otherEarningsIn([DateTime? month]) {
    final m = month ?? DateTime.now();
    return _earnings
        .where((e) => e.date.year == m.year && e.date.month == m.month)
        .fold(0.0, (s, e) => s + e.amount);
  }

  /// Total income for a month = job salary + one-off earnings of that month.
  double totalIn([DateTime? month]) => _jobIncome + otherEarningsIn(month);

  double get totalOtherEarnings =>
      _earnings.fold(0.0, (s, e) => s + e.amount);

  void setJobIncome(double value) {
    if (_jobIncome == value) return;
    _jobIncome = value;
    _saveToPrefs();
    notifyListeners();
  }

  void addEarning(String source, double amount, [DateTime? date]) {
    _earnings.insert(0, IncomeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      source: source.trim().isEmpty ? 'Other earning' : source.trim(),
      amount: amount,
      date: date ?? DateTime.now(),
    ));
    _saveToPrefs();
    notifyListeners();
  }

  void deleteEarning(String id) {
    _earnings.removeWhere((e) => e.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final job = prefs.getDouble(_kJobIncome);
      if (job != null) _jobIncome = job;
      final raw = prefs.getString(_kEarnings);
      if (raw != null) {
        final list = (jsonDecode(raw) as List)
            .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) _earnings = list;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kJobIncome, _jobIncome);
      await prefs.setString(
          _kEarnings, jsonEncode(_earnings.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}
