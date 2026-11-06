import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ledger_entry.dart';

/// Friend-money ledger: tracks money you GAVE to friends (they owe you)
/// and money you TOOK from friends (you owe them). Entries can be settled
/// once the debt is paid back; settled entries stay in the history.
/// Persisted to SharedPreferences.
class LendBorrowProvider extends ChangeNotifier {
  static const _kEntries = 'lend_borrow_entries';

  List<LedgerEntry> _entries = [
    LedgerEntry(
      id: 'lb-sample-1',
      person: 'Ahmed',
      amount: 2500,
      note: 'Lunch & movie',
      date: DateTime.now().subtract(const Duration(days: 2)),
      direction: LedgerDirection.given,
    ),
    LedgerEntry(
      id: 'lb-sample-2',
      person: 'Sara',
      amount: 1000,
      note: 'Concert ticket',
      date: DateTime.now().subtract(const Duration(days: 5)),
      direction: LedgerDirection.taken,
    ),
    LedgerEntry(
      id: 'lb-sample-3',
      person: 'Bilal',
      amount: 500,
      note: 'Uber ride',
      date: DateTime.now().subtract(const Duration(days: 8)),
      direction: LedgerDirection.given,
      settled: true,
      settledDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  LendBorrowProvider() {
    _loadFromPrefs();
  }

  /// All entries, newest first.
  List<LedgerEntry> get entries {
    final sorted = List<LedgerEntry>.of(_entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  List<LedgerEntry> get outstanding => entries
      .where((e) => !e.settled)
      .toList();

  List<LedgerEntry> get settledEntries => entries
      .where((e) => e.settled)
      .toList();

  /// Total outstanding money friends owe me (I gave, not yet settled).
  double get totalGiven =>
      _entries.where((e) => !e.settled && e.direction == LedgerDirection.given).fold(0.0, (s, e) => s + e.amount);

  /// Total outstanding money I owe friends (I took, not yet settled).
  double get totalTaken =>
      _entries.where((e) => !e.settled && e.direction == LedgerDirection.taken).fold(0.0, (s, e) => s + e.amount);

  /// Net position. Positive → friends owe me more than I owe.
  double get net => totalGiven - totalTaken;

  /// Outstanding balance per person. Positive → they owe me; negative → I owe them.
  Map<String, double> get balancesByPerson {
    final map = <String, double>{};
    for (final e in _entries.where((e) => !e.settled)) {
      final delta = e.direction == LedgerDirection.given ? e.amount : -e.amount;
      map[e.person] = (map[e.person] ?? 0) + delta;
    }
    return map;
  }

  void add(LedgerEntry entry) {
    _entries.insert(0, entry);
    _saveToPrefs();
    notifyListeners();
  }

  void addEntry({
    required String person,
    required double amount,
    required LedgerDirection direction,
    String note = '',
    DateTime? date,
  }) {
    add(LedgerEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      person: person.trim(),
      amount: amount,
      note: note.trim(),
      date: date ?? DateTime.now(),
      direction: direction,
    ));
  }

  /// Marks a debt as paid back. Keeps the record for history.
  void settle(String id) {
    final i = _entries.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _entries[i] = _entries[i].copyWith(settled: true, settledDate: DateTime.now());
    _saveToPrefs();
    notifyListeners();
  }

  /// Re-opens a settled entry (undo).
  void unSettle(String id) {
    final i = _entries.indexWhere((e) => e.id == id);
    if (i < 0) return;
    _entries[i] = _entries[i].copyWith(settled: false, settledDate: null);
    _saveToPrefs();
    notifyListeners();
  }

  void delete(String id) {
    _entries.removeWhere((e) => e.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kEntries);
      if (raw != null) {
        final list = (jsonDecode(raw) as List)
            .map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) _entries = list;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _kEntries, jsonEncode(_entries.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }
}
