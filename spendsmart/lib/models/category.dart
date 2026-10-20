import 'package:flutter/material.dart';

/// Expense categories. IDs are stable so expenses can reference them.
class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
