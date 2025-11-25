import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    saveSettings();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
    saveSettings();
  }

  void setWorkoutReminders(bool enabled) {
    _workoutReminders = enabled;
    notifyListeners();
    saveSettings();
  }

  void setMealReminders(bool enabled) {
    _mealReminders = enabled;
    notifyListeners();
    saveSettings();
  }

  void setSocialNotifications(bool enabled) {
    _socialNotifications = enabled;
    notifyListeners();
    saveSettings();
  }

  void setLanguage(String language) {
    _language = language;
    notifyListeners();
    saveSettings();
  }

  void setUnits(String units) {
    _units = units;
    notifyListeners();
    saveSettings();
  }

  void setAutoBackup(bool enabled) {
    _autoBackup = enabled;
    notifyListeners();
    saveSettings();
  }

  void setBiometricAuth(bool enabled) {
    _biometricAuth = enabled;
    notifyListeners();
    saveSettings();
  }

  void setWorkoutReminderTime(TimeOfDay time) {
    _workoutReminderTime = time;
    notifyListeners();
    saveSettings();
  }

  void setMealReminderTime(TimeOfDay time) {
    _mealReminderTime = time;
    notifyListeners();
    saveSettings();
  }

  Future<void> loadSettings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('user_settings')
            .select()
            .eq('user_id', user.id)
            .single();

        _themeMode = _parseThemeMode(response['theme_mode']);
        _notificationsEnabled = response['notifications_enabled'] ?? true;
        _workoutReminders = response['workout_reminders'] ?? true;
        _mealReminders = response['meal_reminders'] ?? true;
        _socialNotifications = response['social_notifications'] ?? true;
        _language = response['language'] ?? 'English';
        _units = response['units'] ?? 'Metric';
        _autoBackup = response['auto_backup'] ?? true;
        _biometricAuth = response['biometric_auth'] ?? false;
        _workoutReminderTime = _parseTimeOfDay(response['workout_reminder_time'] ?? '09:00');
        _mealReminderTime = _parseTimeOfDay(response['meal_reminder_time'] ?? '12:00');
      } catch (e) {
        // Settings not found, keep defaults
        await _createDefaultSettings(user.id);
      }
    }
    notifyListeners();
  }

  Future<void> _createDefaultSettings(String userId) async {
    await Supabase.instance.client.from('user_settings').insert({
      'user_id': userId,
      'theme_mode': 'system',
      'notifications_enabled': true,
      'workout_reminders': true,
      'meal_reminders': true,
      'social_notifications': true,
      'language': 'English',
      'units': 'Metric',
      'auto_backup': true,
      'biometric_auth': false,
      'workout_reminder_time': '09:00',
      'meal_reminder_time': '12:00',
    });
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Future<void> saveSettings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('user_settings').upsert({
        'user_id': user.id,
        'theme_mode': _themeMode.name,
        'notifications_enabled': _notificationsEnabled,
        'workout_reminders': _workoutReminders,
        'meal_reminders': _mealReminders,
        'social_notifications': _socialNotifications,
        'language': _language,
        'units': _units,
        'auto_backup': _autoBackup,
        'biometric_auth': _biometricAuth,
        'workout_reminder_time': '${_workoutReminderTime.hour.toString().padLeft(2, '0')}:${_workoutReminderTime.minute.toString().padLeft(2, '0')}',
        'meal_reminder_time': '${_mealReminderTime.hour.toString().padLeft(2, '0')}:${_mealReminderTime.minute.toString().padLeft(2, '0')}',
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
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
