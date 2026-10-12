import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';
import '../data/sample_data.dart';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _items = List.of(SampleData.notifications);

  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;

  void markAllRead() {
    _items = _items.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  void markRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i >= 0 && !_items[i].isRead) {
      _items[i] = _items[i].copyWith(isRead: true);
      notifyListeners();
    }
  }
}
