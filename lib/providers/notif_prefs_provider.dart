import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Notification preference toggles (3 switches in Settings).
class NotifPrefsProvider extends ChangeNotifier {
  NotifPrefsProvider() {
    _load();
  }

  bool _budgetAlerts = true;
  bool _lowBalance = true;
  bool _goalUpdates = true;

  bool get budgetAlerts => _budgetAlerts;
  bool get lowBalance => _lowBalance;
  bool get goalUpdates => _goalUpdates;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _budgetAlerts = prefs.getBool(AppConstants.keyNotifBudget) ?? true;
    _lowBalance = prefs.getBool(AppConstants.keyNotifLowBalance) ?? true;
    _goalUpdates = prefs.getBool(AppConstants.keyNotifGoals) ?? true;
    notifyListeners();
  }

  Future<void> setBudgetAlerts(bool v) async {
    _budgetAlerts = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotifBudget, v);
  }

  Future<void> setLowBalance(bool v) async {
    _lowBalance = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotifLowBalance, v);
  }

  Future<void> setGoalUpdates(bool v) async {
    _goalUpdates = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotifGoals, v);
  }
}
