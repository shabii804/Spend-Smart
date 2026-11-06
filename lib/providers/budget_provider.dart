import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../data/sample_data.dart';

class BudgetProvider extends ChangeNotifier {
  Budget _budget = SampleData.budget;

  Budget get budget => _budget;

  double get monthlyLimit => _budget.monthlyLimit;

  void updateBudget(double newLimit) {
    _budget = Budget(monthlyLimit: newLimit);
    notifyListeners();
  }
}
