import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../data/sample_data.dart';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = List.of(SampleData.goals);

  List<Goal> get goals => List.unmodifiable(_goals);

  Goal? byId(String id) {
    for (final g in _goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  void addGoal(Goal g) {
    _goals.insert(0, g);
    notifyListeners();
  }

  /// Adds money to a goal. Returns the new savedAmount.
  double addToGoal(String id, double amount) {
    final i = _goals.indexWhere((g) => g.id == id);
    if (i < 0) return 0;
    final updated = _goals[i].copyWith(
      savedAmount: _goals[i].savedAmount + amount,
    );
    _goals[i] = updated;
    notifyListeners();
    return updated.savedAmount;
  }

  double get totalSaved =>
      _goals.fold(0.0, (s, g) => s + g.savedAmount);
  double get totalTarget =>
      _goals.fold(0.0, (s, g) => s + g.targetAmount);
}
