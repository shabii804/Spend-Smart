import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../data/sample_data.dart';

class UserProvider extends ChangeNotifier {
  UserProfile _user = SampleData.user;
  UserProfile get user => _user;

  UserProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_fullName');
      if (name != null) {
        _user = UserProfile(
          fullName: name,
          email: prefs.getString('user_email') ?? SampleData.user.email,
          phone: prefs.getString('user_phone') ?? SampleData.user.phone,
          memberTier: prefs.getString('user_memberTier') ?? SampleData.user.memberTier,
          joinDate: prefs.getString('user_joinDate') ?? SampleData.user.joinDate,
          monthlyIncome: prefs.getDouble('user_monthlyIncome') ?? SampleData.user.monthlyIncome,
          occupation: prefs.getString('user_occupation') ?? SampleData.user.occupation,
          streakDays: prefs.getInt('user_streakDays') ?? SampleData.user.streakDays,
          healthScore: prefs.getInt('user_healthScore') ?? SampleData.user.healthScore,
          biometricsEnabled: prefs.getBool('user_biometricsEnabled') ?? false,
          appLockEnabled: prefs.getBool('user_appLockEnabled') ?? false,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_fullName', _user.fullName);
      await prefs.setString('user_email', _user.email);
      await prefs.setString('user_phone', _user.phone);
      await prefs.setString('user_memberTier', _user.memberTier);
      await prefs.setString('user_joinDate', _user.joinDate);
      await prefs.setDouble('user_monthlyIncome', _user.monthlyIncome);
      await prefs.setString('user_occupation', _user.occupation);
      await prefs.setInt('user_streakDays', _user.streakDays);
      await prefs.setInt('user_healthScore', _user.healthScore);
      await prefs.setBool('user_biometricsEnabled', _user.biometricsEnabled);
      await prefs.setBool('user_appLockEnabled', _user.appLockEnabled);
    } catch (_) {}
  }

  void updateUser(UserProfile u) {
    _user = u;
    _saveToPrefs();
    notifyListeners();
  }

  void toggleBiometrics(bool value) {
    _user = _user.copyWith(biometricsEnabled: value);
    _saveToPrefs();
    notifyListeners();
  }

  void toggleAppLock(bool value) {
    _user = _user.copyWith(appLockEnabled: value);
    _saveToPrefs();
    notifyListeners();
  }

  /// Logs the user out by resetting to the default blank session.
  void logout() {
    _user = const UserProfile(
      fullName: '',
      email: '',
      biometricsEnabled: false,
      appLockEnabled: false,
    );
    _saveToPrefs();
    notifyListeners();
  }
}
