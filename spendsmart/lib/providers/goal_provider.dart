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

  /// Deletes a goal by id. Used by the swipe-to-delete feature on the
  /// Savings Goals screen. The deletion is permanent — saved money is
  /// treated as "spent" outside the app's tracking — so the UI confirms
  /// via a dialog before calling this method.
  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  /// Updates a goal's full state — used by the edit-goal flow.
  void updateGoal(Goal updated) {
    final i = _goals.indexWhere((g) => g.id == updated.id);
    if (i >= 0) {
      _goals[i] = updated;
      notifyListeners();
    }
  }

  double get totalSaved =>
      _goals.fold(0.0, (s, g) => s + g.savedAmount);
  double get totalTarget =>
      _goals.fold(0.0, (s, g) => s + g.targetAmount);

  /// Overall progress across all goals (total saved / total target).
  /// 0 if no goals exist. Used by the overview hero card on the goals page.
  double get overallProgress =>
      totalTarget == 0 ? 0 : (totalSaved / totalTarget).clamp(0.0, 1.0);
}
