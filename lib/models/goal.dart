import 'package:flutter/material.dart';

/// Savings goal. icon is an IconData codepoint.
class Goal {
  final String id;
  final String name;
  final IconData icon;
  final double targetAmount;
  final double savedAmount;
  final double monthlySaving;
  final DateTime targetDate;

  const Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.savedAmount,
    required this.monthlySaving,
    required this.targetDate,
  });

  double get progressPercent =>
      targetAmount == 0 ? 0 : (savedAmount / targetAmount).clamp(0.0, 1.0);

  bool get isComplete => savedAmount >= targetAmount;

  double get remaining => (targetAmount - savedAmount).clamp(0.0, double.infinity);

  Goal copyWith({
    String? id,
    String? name,
    IconData? icon,
    double? targetAmount,
    double? savedAmount,
    double? monthlySaving,
    DateTime? targetDate,
  }) =>
      Goal(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        monthlySaving: monthlySaving ?? this.monthlySaving,
        targetDate: targetDate ?? this.targetDate,
      );
}
