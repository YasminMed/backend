import 'package:flutter/material.dart';

enum AppPath { study, career }

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  AppPath _currentPath = AppPath.study;
  bool _notificationsEnabled = true;

  bool get isDarkMode => _isDarkMode;
  AppPath get currentPath => _currentPath;
  bool get notificationsEnabled => _notificationsEnabled;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPath(AppPath path) {
    if (_currentPath != path) {
      _currentPath = path;
      notifyListeners();
    }
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }
}
