import 'package:flutter/material.dart';

class CareerNavProvider with ChangeNotifier {
  String _activeTab = 'dashboard';

  String get activeTab => _activeTab;

  void setTab(String tabId) {
    if (_activeTab != tabId) {
      _activeTab = tabId;
      notifyListeners();
    }
  }
}
