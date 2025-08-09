import 'package:flutter/material.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _workoutReminders = true;
  bool _mealReminders = true;
  bool _socialNotifications = true;
  String _language = 'English';
  String _units = 'Metric';
  bool _autoBackup = true;
  bool _biometricAuth = false;
  TimeOfDay _workoutReminderTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _mealReminderTime = TimeOfDay(hour: 12, minute: 0);

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get workoutReminders => _workoutReminders;
  bool get mealReminders => _mealReminders;
  bool get socialNotifications => _socialNotifications;
  String get language => _language;
  String get units => _units;
  bool get autoBackup => _autoBackup;
  bool get biometricAuth => _biometricAuth;
  TimeOfDay get workoutReminderTime => _workoutReminderTime;
  TimeOfDay get mealReminderTime => _mealReminderTime;

  // Setters
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  void setWorkoutReminders(bool enabled) {
    _workoutReminders = enabled;
    notifyListeners();
  }

  void setMealReminders(bool enabled) {
    _mealReminders = enabled;
    notifyListeners();
  }

  void setSocialNotifications(bool enabled) {
    _socialNotifications = enabled;
    notifyListeners();
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
  }

  void setUnits(String units) {
    _units = units;
    notifyListeners();
  }

  void setAutoBackup(bool enabled) {
    _autoBackup = enabled;
    notifyListeners();
  }

  void setBiometricAuth(bool enabled) {
    _biometricAuth = enabled;
    notifyListeners();
  }

  void setWorkoutReminderTime(TimeOfDay time) {
    _workoutReminderTime = time;
    notifyListeners();
  }

  void setMealReminderTime(TimeOfDay time) {
    _mealReminderTime = time;
    notifyListeners();
  }

  Future<void> loadSettings() async {
    // Simulate loading from storage
    await Future.delayed(Duration(milliseconds: 500));
    // Load settings from SharedPreferences or secure storage
    notifyListeners();
  }

  Future<void> saveSettings() async {
    // Simulate saving to storage
    await Future.delayed(Duration(milliseconds: 500));
    // Save settings to SharedPreferences or secure storage
  }

  void resetToDefaults() {
    _themeMode = ThemeMode.system;
    _notificationsEnabled = true;
    _workoutReminders = true;
    _mealReminders = true;
    _socialNotifications = true;
    _language = 'English';
    _units = 'Metric';
    _autoBackup = true;
    _biometricAuth = false;
    _workoutReminderTime = TimeOfDay(hour: 9, minute: 0);
    _mealReminderTime = TimeOfDay(hour: 12, minute: 0);
    notifyListeners();
  }
}
