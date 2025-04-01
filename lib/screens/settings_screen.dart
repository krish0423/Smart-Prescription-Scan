import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  String _theme = 'system';
  bool _saveImages = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = prefs.getString('theme') ?? 'system';
      _saveImages = prefs.getBool('save_images') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _apiKeyController.text = dotenv.env['GEMINI_API_KEY'] ?? '';
    });
  }

  Future<void> _saveTheme(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', theme);

      if (!mounted) return;

      setState(() {
        _theme = theme;
      });

      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      switch (theme) {
        case 'light':
          themeProvider.setThemeMode(ThemeMode.light);
          break;
        case 'dark':
          themeProvider.setThemeMode(ThemeMode.dark);
          break;
        default:
          themeProvider.setThemeMode(ThemeMode.system);
      }
    } catch (e) {
      _showMessage('Failed to save theme preference', isError: true);
    }
  }

  Future<void> _toggleSaveImages(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('save_images', value);
    setState(() {
      _saveImages = value;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _saveApiKey(String apiKey) async {
    if (apiKey.trim().isEmpty) {
      _showMessage('API Key cannot be empty', isError: true);
      return;
    }

    try {
      dotenv.env['GEMINI_API_KEY'] = apiKey;
      _showMessage('API Key saved successfully');
    } catch (e) {
      _showMessage('Failed to save API Key', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: Text(isError ? 'Error' : 'Success'),
              content: Text(message),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri uri = Uri.parse('https://yourcompany.com/privacy-policy');
    if (!await launchUrl(uri)) {
      _showMessage('Could not open privacy policy', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _buildIOSLayout() : _buildAndroidLayout();
  }

  Widget _buildIOSLayout() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildIOSSectionHeader('Appearance'),
            CupertinoFormSection(
              children: [
                CupertinoFormRow(
                  prefix: const Text('Theme'),
                  child: CupertinoSegmentedControl<String>(
                    children: const {
                      'system': Text('System'),
                      'light': Text('Light'),
                      'dark': Text('Dark'),
                    },
                    groupValue: _theme,
                    onValueChanged: _saveTheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIOSSectionHeader('Notifications'),
            CupertinoFormSection(
              children: [
                CupertinoFormRow(
                  prefix: const Text('Enable Notifications'),
                  child: CupertinoSwitch(
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIOSSectionHeader('Storage'),
            CupertinoFormSection(
              children: [
                CupertinoFormRow(
                  prefix: const Text('Save Prescription Images'),
                  child: CupertinoSwitch(
                    value: _saveImages,
                    onChanged: _toggleSaveImages,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIOSSectionHeader('API Settings'),
            CupertinoFormSection(
              children: [
                CupertinoTextFormFieldRow(
                  controller: _apiKeyController,
                  prefix: const Text('Gemini API Key'),
                  placeholder: 'Enter your API key',
                  obscureText: true,
                ),
                CupertinoFormRow(
                  child: CupertinoButton(
                    child: const Text('Save API Key'),
                    onPressed: () => _saveApiKey(_apiKeyController.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIOSSectionHeader('About'),
            CupertinoFormSection(
              children: [
                CupertinoFormRow(
                  prefix: const Text('Privacy Policy'),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('View Policy'),
                    onPressed: _launchPrivacyPolicy,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIOSSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: CupertinoColors.systemBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAndroidLayout() {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance'),
          Card(
            child: ListTile(
              title: const Text('Theme'),
              trailing: DropdownButton<String>(
                value: _theme,
                onChanged: (value) {
                  if (value != null) _saveTheme(value);
                },
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Notifications'),
          Card(
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('Storage'),
          Card(
            child: SwitchListTile(
              title: const Text('Save Prescription Images'),
              value: _saveImages,
              onChanged: _toggleSaveImages,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('API Settings'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Gemini API Key',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _saveApiKey(_apiKeyController.text),
                    child: const Text('Save API Key'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader('About'),
          Card(
            child: ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _launchPrivacyPolicy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
