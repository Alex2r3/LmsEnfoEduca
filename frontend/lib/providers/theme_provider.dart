import 'package:flutter/material.dart';
import '../config/app_theme.dart';

enum CustomThemeMode { light, dark, aura }

class ThemeProvider extends ChangeNotifier {
  CustomThemeMode _currentMode = CustomThemeMode.light;

  CustomThemeMode get currentMode => _currentMode;

  ThemeData get currentTheme {
    switch (_currentMode) {
      case CustomThemeMode.light:
        return AppTheme.lightTheme;
      case CustomThemeMode.dark:
        return AppTheme.darkTheme;
      case CustomThemeMode.aura:
        return AppTheme.auraTheme;
    }
  }

  void setTheme(CustomThemeMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    if (_currentMode == CustomThemeMode.light) {
      _currentMode = CustomThemeMode.dark;
    } else if (_currentMode == CustomThemeMode.dark) {
      _currentMode = CustomThemeMode.aura;
    } else {
      _currentMode = CustomThemeMode.light;
    }
    notifyListeners();
  }
}
