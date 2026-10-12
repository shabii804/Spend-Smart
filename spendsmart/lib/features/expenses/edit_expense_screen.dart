import 'package:flutter/material.dart';
import 'add_expense_screen.dart';

/// Thin wrapper that opens Add Expense in edit mode.
/// Real logic lives in [AddExpenseScreen].
class EditExpenseScreen extends StatelessWidget {
  final String expenseId;
  const EditExpenseScreen({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return AddExpenseScreen(expenseId: expenseId);
  }
}
