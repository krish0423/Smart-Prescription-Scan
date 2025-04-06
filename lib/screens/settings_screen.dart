import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class SettingsScreen extends StatefulWidget {
  final Function toggleTheme;

  const SettingsScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _reminderTime = '08:00 AM';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                title: 'Dark Mode',
                subtitle: 'Use dark theme throughout the app',
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  widget.toggleTheme();
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                title: 'Enable Notifications',
                subtitle: 'Receive medication reminders',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Sound',
                subtitle: 'Play sound with notifications',
                value: _soundEnabled,
                enabled: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                title: 'Vibration',
                subtitle: 'Vibrate with notifications',
                value: _vibrationEnabled,
                enabled: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _vibrationEnabled = value;
                  });
                },
              ),
              _buildTappableTile(
                title: 'Default Reminder Time',
                subtitle: _reminderTime,
                onTap: () {
                  _showTimePickerDialog();
                },
              ),
            ],
          ),
          _buildSection(
            title: 'General',
            children: [
              _buildTappableTile(
                title: 'Language',
                subtitle: _language,
                onTap: () {
                  _showLanguageDialog();
                },
              ),
              _buildTappableTile(
                title: 'Clear Medication History',
                subtitle: 'Delete all scanned prescriptions',
                onTap: () {
                  _showClearHistoryDialog();
                },
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              _buildTappableTile(
                title: 'Version',
                subtitle: '1.0.0',
                onTap: null,
              ),
              _buildTappableTile(
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // Open privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy Policy will open in browser'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildTappableTile(
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                onTap: () {
                  // Open terms of service
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Terms of Service will open in browser'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildTappableTile(
                title: 'Contact Support',
                subtitle: 'Get help with the app',
                onTap: () {
                  // Contact support
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Support email will open'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color:
              enabled
                  ? null
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color:
              enabled
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
        ),
      ),
      trailing:
          Platform.isIOS
              ? CupertinoSwitch(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeColor: Theme.of(context).colorScheme.primary,
              )
              : Switch(value: value, onChanged: enabled ? onChanged : null),
      enabled: enabled,
      onTap:
          enabled
              ? () {
                onChanged(!value);
              }
              : null,
    );
  }

  Widget _buildTappableTile({
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      trailing:
          onTap != null
              ? Icon(
                Platform.isIOS
                    ? CupertinoIcons.chevron_right
                    : Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              )
              : null,
      onTap: onTap,
    );
  }

  void _showTimePickerDialog() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodBorderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final hour =
          selectedTime.hourOfPeriod == 0 ? 12 : selectedTime.hourOfPeriod;
      final period = selectedTime.period == DayPeriod.am ? 'AM' : 'PM';

      setState(() {
        _reminderTime =
            '$hour:${selectedTime.minute.toString().padLeft(2, '0')} $period';
      });
    }
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder:
            (context) => CupertinoActionSheet(
              title: const Text('Select Language'),
              actions:
                  languages
                      .map(
                        (language) => CupertinoActionSheetAction(
                          onPressed: () {
                            setState(() {
                              _language = language;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(language),
                          isDefaultAction: language == _language,
                        ),
                      )
                      .toList(),
              cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
                isDestructiveAction: true,
              ),
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Select Language'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      languages
                          .map(
                            (language) => RadioListTile<String>(
                              title: Text(language),
                              value: language,
                              groupValue: _language,
                              onChanged: (value) {
                                setState(() {
                                  _language = value!;
                                });
                                Navigator.pop(context);
                              },
                            ),
                          )
                          .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );
    }
  }

  void _showClearHistoryDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('Clear Medication History'),
              content: const Text(
                'Are you sure you want to delete all your medication history? This action cannot be undone.',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    // Clear history logic would go here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Medication history cleared'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  isDestructiveAction: true,
                  child: const Text('Clear'),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Clear Medication History'),
              content: const Text(
                'Are you sure you want to delete all your medication history? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Clear history logic would go here
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Medication history cleared'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
      );
    }
  }
}
