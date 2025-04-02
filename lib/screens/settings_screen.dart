import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../widgets/ios_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final Function? toggleTheme;

  const SettingsScreen({Key? key, this.toggleTheme}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  String _reminderTime = '8:00 PM';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
        child: SafeArea(
          child: ListView(
            children: [
              _buildSectionHeader('App Preferences'),

              // Dark Mode
              CupertinoListTile(
                title: const Text('Dark Mode'),
                trailing: CupertinoSwitch(
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                      if (widget.toggleTheme != null) {
                        widget.toggleTheme!();
                      }
                    });
                  },
                ),
              ),

              // Language
              _buildSettingItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: _language,
                onTap: () {
                  _showLanguageSelector();
                },
              ),

              _buildSectionHeader('Notifications'),

              // Medication Reminders
              CupertinoListTile(
                title: const Text('Medication Reminders'),
                subtitle: const Text(
                  'Get notified when it\'s time to take your medication',
                ),
                trailing: CupertinoSwitch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),

              // Default Reminder Time
              if (_notificationsEnabled)
                _buildSettingItem(
                  icon: Icons.access_time,
                  title: 'Default Reminder Time',
                  subtitle: _reminderTime,
                  onTap: () {
                    _showTimeSelector();
                  },
                ),

              // Refill Reminders
              if (_notificationsEnabled)
                _buildSettingItem(
                  icon: Icons.medication,
                  title: 'Refill Reminders',
                  subtitle:
                      'Get notified when you need to refill your prescription',
                  trailing:
                      Platform.isIOS
                          ? IOSSwitch(
                            value: true,
                            onChanged: (value) {
                              // Toggle refill reminders
                            },
                          )
                          : Switch(
                            value: true,
                            onChanged: (value) {
                              // Toggle refill reminders
                            },
                          ),
                ),

              _buildSectionHeader('Security'),

              // Biometric Authentication
              CupertinoListTile(
                title: const Text('Biometric Authentication'),
                subtitle: const Text(
                  'Use fingerprint or face ID to secure your prescriptions',
                ),
                trailing: CupertinoSwitch(
                  value: _biometricEnabled,
                  onChanged: (value) {
                    setState(() {
                      _biometricEnabled = value;
                    });
                  },
                ),
              ),

              _buildSectionHeader('About'),

              // Privacy Policy
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {
                  // Open privacy policy
                },
              ),

              // Terms of Service
              _buildSettingItem(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () {
                  // Open terms of service
                },
              ),

              // App Version
              _buildSettingItem(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: null,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          children: [
            _buildSectionHeader('App Preferences'),

            // Dark Mode
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: _darkModeEnabled,
              onChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                  if (widget.toggleTheme != null) {
                    widget.toggleTheme!();
                  }
                });
              },
            ),

            // Language
            _buildSettingItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: _language,
              onTap: () {
                _showLanguageSelector();
              },
            ),

            _buildSectionHeader('Notifications'),

            // Medication Reminders
            _buildSettingItem(
              icon: Icons.notifications,
              title: 'Medication Reminders',
              subtitle: 'Get notified when it\'s time to take your medication',
              trailing:
                  Platform.isIOS
                      ? IOSSwitch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      )
                      : Switch(
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
            ),

            // Default Reminder Time
            if (_notificationsEnabled)
              _buildSettingItem(
                icon: Icons.access_time,
                title: 'Default Reminder Time',
                subtitle: _reminderTime,
                onTap: () {
                  _showTimeSelector();
                },
              ),

            // Refill Reminders
            if (_notificationsEnabled)
              _buildSettingItem(
                icon: Icons.medication,
                title: 'Refill Reminders',
                subtitle:
                    'Get notified when you need to refill your prescription',
                trailing:
                    Platform.isIOS
                        ? IOSSwitch(
                          value: true,
                          onChanged: (value) {
                            // Toggle refill reminders
                          },
                        )
                        : Switch(
                          value: true,
                          onChanged: (value) {
                            // Toggle refill reminders
                          },
                        ),
              ),

            _buildSectionHeader('Security'),

            // Biometric Authentication
            _buildSettingItem(
              icon: Icons.fingerprint,
              title: 'Biometric Authentication',
              subtitle:
                  'Use fingerprint or face ID to secure your prescriptions',
              trailing:
                  Platform.isIOS
                      ? IOSSwitch(
                        value: _biometricEnabled,
                        onChanged: (value) {
                          setState(() {
                            _biometricEnabled = value;
                          });
                        },
                      )
                      : Switch(
                        value: _biometricEnabled,
                        onChanged: (value) {
                          setState(() {
                            _biometricEnabled = value;
                          });
                        },
                      ),
            ),

            _buildSectionHeader('About'),

            // Privacy Policy
            _buildSettingItem(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                // Open privacy policy
              },
            ),

            // Terms of Service
            _buildSettingItem(
              icon: Icons.description,
              title: 'Terms of Service',
              onTap: () {
                // Open terms of service
              },
            ),

            // App Version
            _buildSettingItem(
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.0.0',
              onTap: null,
            ),

            const SizedBox(height: 24),
          ],
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  void _showLanguageSelector() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese'];

    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text('Select Language'),
            actions:
                languages.map((language) {
                  return CupertinoActionSheetAction(
                    onPressed: () {
                      setState(() {
                        _language = language;
                      });
                      Navigator.of(context).pop();
                    },
                    child: Text(language),
                    isDefaultAction: language == _language,
                  );
                }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
              isDestructiveAction: true,
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select Language'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    languages.map((language) {
                      return ListTile(
                        title: Text(language),
                        trailing:
                            language == _language
                                ? const Icon(Icons.check)
                                : null,
                        onTap: () {
                          setState(() {
                            _language = language;
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showTimeSelector() {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return Container(
            height: 280,
            color: CupertinoColors.systemBackground,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      CupertinoButton(
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(2023, 1, 1, 20, 0), // 8:00 PM
                    onDateTimeChanged: (DateTime newTime) {
                      final hour =
                          newTime.hour > 12 ? newTime.hour - 12 : newTime.hour;
                      final period = newTime.hour >= 12 ? 'PM' : 'AM';
                      setState(() {
                        _reminderTime =
                            '${hour == 0 ? 12 : hour}:${newTime.minute.toString().padLeft(2, '0')} $period';
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 20, minute: 0), // 8:00 PM
      ).then((TimeOfDay? time) {
        if (time != null) {
          setState(() {
            final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
            final period = time.period == DayPeriod.am ? 'AM' : 'PM';
            _reminderTime =
                '$hour:${time.minute.toString().padLeft(2, '0')} $period';
          });
        }
      });
    }
  }
}
