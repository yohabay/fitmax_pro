import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  bool _shouldShowManualEntry = false;

  int get currentIndex => _currentIndex;
  bool get shouldShowManualEntry => _shouldShowManualEntry;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void showManualEntry() {
    _shouldShowManualEntry = true;
    notifyListeners();
  }

  void resetManualEntry() {
    _shouldShowManualEntry = false;
    notifyListeners();
  }
}