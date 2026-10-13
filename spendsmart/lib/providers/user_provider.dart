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

  /// Logs the user out by resetting to the default sample user.
  /// Used by the Profile screen's Log Out button so the next time the app
  /// launches (or the user navigates back), the session is in a clean state.
  /// The Profile screen calls this BEFORE navigating to LoginScreen so the
  /// user data is cleared from the provider tree.
  void logout() {
    _user = UserProfile(
      fullName: '',
      email: '',
    );
    notifyListeners();
  }
}
