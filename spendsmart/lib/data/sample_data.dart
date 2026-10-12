import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/expense.dart';
import '../models/goal.dart';
import '../models/budget.dart';
import '../models/app_notification.dart';
import '../models/user_profile.dart';
import '../core/theme/app_colors.dart';

/// ALL DEMO DATA LIVES HERE. Single source of truth.
/// To customize: edit the constants below — every screen reads from these.
class SampleData {
  SampleData._();

  // ============================================================
  // USER (local, no auth)
  // ============================================================
  static const UserProfile user = UserProfile(
    fullName: 'Muhammad Shoaib',
    email: 'muhammad@gmail.com',
  );

  // ============================================================
  // BUDGET (monthly limit)
  // ============================================================
  static const Budget budget = Budget(monthlyLimit: 25000);

  // ============================================================
  // CATEGORIES (8 — IDs stable)
  // ============================================================
  static const List<Category> categories = [
    Category(id: 'food', name: 'Food & Dining', icon: Icons.restaurant_rounded, color: AppColors.catFood),
    Category(id: 'transport', name: 'Transport', icon: Icons.directions_bus_rounded, color: AppColors.catTransport),
    Category(id: 'groceries', name: 'Groceries', icon: Icons.shopping_cart_rounded, color: AppColors.catGroceries),
    Category(id: 'entertainment', name: 'Entertainment', icon: Icons.movie_rounded, color: AppColors.catEntertainment),
    Category(id: 'bills', name: 'Bills', icon: Icons.receipt_long_rounded, color: AppColors.catBills),
    Category(id: 'internet', name: 'Internet', icon: Icons.wifi_rounded, color: AppColors.catInternet),
    Category(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag_rounded, color: AppColors.catShopping),
    Category(id: 'others', name: 'Others', icon: Icons.category_rounded, color: AppColors.catOthers),
  ];

  static Category categoryById(String id) =>
      categories.firstWhere((c) => c.id == id, orElse: () => categories.last);

  // ============================================================
  // SAMPLE EXPENSES — October 2026
  // ============================================================
  static final List<Expense> expenses = [
    Expense(
      id: 'e1',
      title: 'Lunch at cafe',
      amount: 320,
      categoryId: 'food',
      date: DateTime(2026, 10, 10, 12, 45),
      note: 'Campus cafeteria — pasta and coffee',
    ),
    Expense(
      id: 'e2',
      title: 'Bus fare',
      amount: 150,
      categoryId: 'transport',
      date: DateTime(2026, 10, 10, 10, 30),
      note: 'Metro to university',
    ),
    Expense(
      id: 'e3',
      title: 'Movie night',
      amount: 600,
      categoryId: 'entertainment',
      date: DateTime(2026, 10, 9, 20, 15),
      note: 'Cinema — tickets + popcorn',
    ),
    Expense(
      id: 'e4',
      title: 'Weekly groceries',
      amount: 1250,
      categoryId: 'groceries',
      date: DateTime(2026, 10, 9, 17, 30),
      note: 'Rice, oil, vegetables, eggs',
    ),
    Expense(
      id: 'e5',
      title: 'Internet bill',
      amount: 800,
      categoryId: 'internet',
      date: DateTime(2026, 10, 8, 9, 10),
      note: 'Monthly broadband payment',
    ),
    Expense(
      id: 'e6',
      title: 'Electricity bill',
      amount: 3200,
      categoryId: 'bills',
      date: DateTime(2026, 10, 7, 11, 0),
      note: 'September electricity',
    ),
    Expense(
      id: 'e7',
      title: 'Stationery',
      amount: 450,
      categoryId: 'others',
      date: DateTime(2026, 10, 6, 14, 20),
      note: 'Notebooks, pens, files',
    ),
    Expense(
      id: 'e8',
      title: 'Dinner',
      amount: 980,
      categoryId: 'food',
      date: DateTime(2026, 10, 5, 21, 0),
      note: 'Family dinner at home delivery',
    ),
    Expense(
      id: 'e9',
      title: 'Taxi',
      amount: 540,
      categoryId: 'transport',
      date: DateTime(2026, 10, 4, 18, 40),
      note: 'Ride back from library',
    ),
    Expense(
      id: 'e10',
      title: 'Snacks',
      amount: 260,
      categoryId: 'food',
      date: DateTime(2026, 10, 3, 16, 15),
      note: 'Chips, juice, chocolate',
    ),
    Expense(
      id: 'e11',
      title: 'Shopping',
      amount: 2100,
      categoryId: 'shopping',
      date: DateTime(2026, 10, 2, 19, 0),
      note: 'Jacket + t-shirt',
    ),
    Expense(
      id: 'e12',
      title: 'Snacks',
      amount: 210,
      categoryId: 'food',
      date: DateTime(2026, 10, 1, 17, 0),
      note: 'Biscuits and tea',
    ),
  ];

  // ============================================================
  // SAVINGS GOALS (4)
  // ============================================================
  static final List<Goal> goals = [
    Goal(
      id: 'g1',
      name: 'Laptop Fund',
      icon: Icons.laptop_mac_rounded,
      targetAmount: 60000,
      savedAmount: 15000,
      monthlySaving: 5000,
      targetDate: DateTime(2027, 6, 30),
    ),
    Goal(
      id: 'g2',
      name: 'Travel Fund',
      icon: Icons.flight_takeoff_rounded,
      targetAmount: 60000,
      savedAmount: 8000,
      monthlySaving: 4000,
      targetDate: DateTime(2027, 12, 15),
    ),
    Goal(
      id: 'g3',
      name: 'Emergency Fund',
      icon: Icons.health_and_safety_rounded,
      targetAmount: 30000,
      savedAmount: 5000,
      monthlySaving: 2500,
      targetDate: DateTime(2027, 3, 31),
    ),
    Goal(
      id: 'g4',
      name: 'New Phone',
      icon: Icons.smartphone_rounded,
      targetAmount: 80000,
      savedAmount: 12000,
      monthlySaving: 6000,
      targetDate: DateTime(2027, 8, 20),
    ),
  ];

  // ============================================================
  // NOTIFICATIONS (sample)
  // ============================================================
  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      type: NotificationType.alert,
      title: 'Budget Alert',
      body: "You've used 42% of your monthly budget. Pacing looks healthy.",
      timeAgo: '1h ago',
      icon: Icons.warning_amber_rounded,
      color: AppColors.warning,
    ),
    AppNotification(
      id: 'n2',
      type: NotificationType.reminder,
      title: 'Add Transaction',
      body: 'Did you spend on groceries today? Log it now to keep your records accurate.',
      timeAgo: '3h ago',
      icon: Icons.notifications_active_rounded,
      color: AppColors.blue,
    ),
    AppNotification(
      id: 'n3',
      type: NotificationType.achievement,
      title: 'Goal Milestone!',
      body: 'Laptop Fund reached 25% of the target. Keep going!',
      timeAgo: '1d ago',
      icon: Icons.emoji_events_rounded,
      color: AppColors.mint,
    ),
    AppNotification(
      id: 'n4',
      type: NotificationType.suggestion,
      title: 'Smart Suggestion',
      body: 'Food & Dining is your top category this month. Cooking 2 extra meals at home could save Rs. 1,500.',
      timeAgo: '2d ago',
      icon: Icons.lightbulb_rounded,
      color: AppColors.primaryIndigo,
    ),
  ];
}
