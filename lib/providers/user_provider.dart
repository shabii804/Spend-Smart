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
}
