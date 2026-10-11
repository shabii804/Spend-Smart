import 'package:flutter/material.dart';

/// Notification types.
enum NotificationType { alert, reminder, achievement, suggestion }

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String timeAgo;
  final IconData icon;
  final Color color;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        timeAgo: timeAgo,
        icon: icon,
        color: color,
        isRead: isRead ?? this.isRead,
      );
}
