import 'package:flutter/foundation.dart';

class AppLanguage {
  final String id;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = options[0]; // Default English

  AppLanguage get currentLanguage => _currentLanguage;

  static const List<AppLanguage> options = [
    AppLanguage(id: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    AppLanguage(id: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰'),
    AppLanguage(id: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    AppLanguage(id: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
  ];

  void setLanguage(String id) {
    final lang = options.firstWhere((l) => l.id == id, orElse: () => options[0]);
    if (_currentLanguage.id != lang.id) {
      _currentLanguage = lang;
      notifyListeners();
    }
  }
}
