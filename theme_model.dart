import 'package:flutter/material.dart';

class ThemeModel extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeData get themeData {
    if (_isDarkMode) {
      return ThemeData.dark();
    } else {
      return ThemeData.light();
    }
  }

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
