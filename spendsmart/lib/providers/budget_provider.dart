import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget.dart';
import '../data/sample_data.dart';

class BudgetProvider extends ChangeNotifier {
  Budget _budget = SampleData.budget;

  Budget get budget => _budget;

  double get monthlyLimit => _budget.monthlyLimit;

  BudgetProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final limit = prefs.getDouble('budget_monthlyLimit');
      if (limit != null) {
        _budget = Budget(monthlyLimit: limit);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> updateBudget(double newLimit) async {
    _budget = Budget(monthlyLimit: newLimit);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('budget_monthlyLimit', newLimit);
    } catch (_) {}
  }
}
