import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../data/sample_data.dart';

class UserProvider extends ChangeNotifier {
  UserProfile _user = SampleData.user;
  UserProfile get user => _user;

  void updateUser(UserProfile u) {
    _user = u;
    notifyListeners();
  }

  void toggleBiometrics(bool value) {
    _user = _user.copyWith(biometricsEnabled: value);
    notifyListeners();
  }

  void toggleAppLock(bool value) {
    _user = _user.copyWith(appLockEnabled: value);
    notifyListeners();
  }

  /// Logs the user out by resetting to the default blank session.
  void logout() {
    _user = const UserProfile(
      fullName: '',
      email: '',
    );
    notifyListeners();
  }
}
