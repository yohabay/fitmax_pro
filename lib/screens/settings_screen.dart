import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      subtitle: Text(_getThemeModeText(settingsProvider.themeMode)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeDialog(context, settingsProvider),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: Text(settingsProvider.language),
                      value: false,
                      onChanged: (value) => _showLanguageDialog(context, settingsProvider),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Notifications Section
              _buildSectionHeader('Notifications'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications),
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive push notifications'),
                      value: settingsProvider.notificationsEnabled,
                      onChanged: settingsProvider.setNotificationsEnabled,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.fitness_center),
                      title: const Text('Workout Reminders'),
                      subtitle: Text('Daily at ${settingsProvider.workoutReminderTime.format(context)}'),
                      value: settingsProvider.workoutReminders,
                      onChanged: settingsProvider.setWorkoutReminders,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.restaurant),
                      title: const Text('Meal Reminders'),
                      subtitle: Text('Daily at ${settingsProvider.mealReminderTime.format(context)}'),
                      value: settingsProvider.mealReminders,
                      onChanged: settingsProvider.setMealReminders,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.people),
                      title: const Text('Social Notifications'),
                      subtitle: const Text('Friend activities and challenges'),
                      value: settingsProvider.socialNotifications,
                      onChanged: settingsProvider.setSocialNotifications,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Units & Measurements Section
              _buildSectionHeader('Units & Measurements'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.straighten),
                      title: const Text('Units'),
                      subtitle: Text(settingsProvider.units),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showUnitsDialog(context, settingsProvider),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Privacy & Security Section
              _buildSectionHeader('Privacy & Security'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('Biometric Authentication'),
                      subtitle: const Text('Use fingerprint or face ID'),
                      value: settingsProvider.biometricAuth,
                      onChanged: settingsProvider.setBiometricAuth,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.backup),
                      title: const Text('Auto Backup'),
                      subtitle: const Text('Automatically backup your data'),
                      value: settingsProvider.autoBackup,
                      onChanged: settingsProvider.setAutoBackup,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Support Section
              _buildSectionHeader('Support'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & FAQ'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _navigateToHelp(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.feedback),
                      title: const Text('Send Feedback'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showFeedbackDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.star_rate),
                      title: const Text('Rate App'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _rateApp(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // About Section
              _buildSectionHeader('About'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('App Version'),
                      subtitle: const Text('1.0.0'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showTermsOfService(context),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showPrivacyPolicy(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Reset Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showResetDialog(context, settingsProvider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Reset All Settings'),
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: provider.language,
              onChanged: (value) {
                if (value != null) {
                  provider.setLanguage(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Units'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Metric (kg, cm)'),
              value: 'Metric',
              groupValue: provider.units,
              onChanged: (value) {
                if (value != null) {
                  provider.setUnits(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Imperial (lbs, ft)'),
              value: 'Imperial',
              groupValue: provider.units,
              onChanged: (value) {
                if (value != null) {
                  provider.setUnits(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement password change logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _navigateToHelp(BuildContext context) {
    // Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help screen coming soon')),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('We\'d love to hear from you!'),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback sent successfully')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _rateApp(BuildContext context) {
    // Implement app rating functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirecting to app store...')),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FitMax Pro',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.fitness_center, size: 48),
      children: const [
        Text('Your ultimate fitness companion with AI-powered workouts, nutrition tracking, and social features.'),
      ],
    );
  }

  void _showTermsOfService(BuildContext context) {
    // Navigate to terms of service
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service coming soon')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Navigate to privacy policy
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy coming soon')),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
