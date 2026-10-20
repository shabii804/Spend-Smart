import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/formatters.dart';

/// User-selectable currency. PKR by default.
class CurrencyProvider extends ChangeNotifier {
  CurrencyProvider() {
    _load();
  }

  String _symbol = 'Rs.';
  String _locale = 'en_PK';
  String _id = 'PKR';

  String get id => _id;
  String get symbol => _symbol;

  static const List<({String id, String name, String symbol, String locale})> options = [
    (id: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs.', locale: 'en_PK'),
    (id: 'USD', name: 'US Dollar', symbol: '\$', locale: 'en_US'),
    (id: 'EUR', name: 'Euro', symbol: '€', locale: 'en_IE'),
    (id: 'GBP', name: 'British Pound', symbol: '£', locale: 'en_GB'),
  ];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(AppConstants.keyCurrency) ?? 'PKR';
    _apply(id);
    notifyListeners();
  }

  Future<void> setCurrency(String id) async {
    _apply(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyCurrency, id);
  }

  void _apply(String id) {
    final o = options.firstWhere((x) => x.id == id, orElse: () => options.first);
    _id = o.id;
    _symbol = o.symbol;
    _locale = o.locale;
    Formatters.setCurrency(_symbol, _locale);
  }
}
