import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

enum ThemeModeChoice { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeModeChoice _mode = ThemeModeChoice.system;
  ThemeModeChoice get mode => _mode;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.keyThemeMode);
    if (raw == 'light') _mode = ThemeModeChoice.light;
    else if (raw == 'dark') _mode = ThemeModeChoice.dark;
    else _mode = ThemeModeChoice.system;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setMode(ThemeModeChoice mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemeMode, mode.name);
  }
}
