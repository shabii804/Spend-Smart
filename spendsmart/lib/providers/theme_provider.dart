import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

enum ThemeModeChoice { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeModeChoice _mode = ThemeModeChoice.light;
  ThemeModeChoice get mode => _mode;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.keyThemeMode);
      if (raw == 'light') {
        _mode = ThemeModeChoice.light;
      } else if (raw == 'dark') {
        _mode = ThemeModeChoice.dark;
      } else {
        _mode = ThemeModeChoice.system;
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> setMode(ThemeModeChoice mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemeMode, mode.name);
  }

  /// Check if dark mode is active
  bool get isDarkMode => _mode == ThemeModeChoice.dark;

  /// Easy method to toggle between Dark and Light mode
  Future<void> toggleTheme() async {
    if (_mode == ThemeModeChoice.dark) {
      await setMode(ThemeModeChoice.light);
    } else {
      await setMode(ThemeModeChoice.dark);
    }
  }

  /// Easy methods to change theme directly
  Future<void> setLight() => setMode(ThemeModeChoice.light);
  Future<void> setDark() => setMode(ThemeModeChoice.dark);
  Future<void> setSystem() => setMode(ThemeModeChoice.system);
}
