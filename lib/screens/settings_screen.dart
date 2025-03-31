import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    setState(() {
      _theme = theme;
    });
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
    // In a real app, you would store this securely
    // For demo purposes, we're just updating the .env value in memory
    dotenv.env['GEMINI_API_KEY'] = apiKey;

    // Show success message
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('API Key Updated'),
              content: const Text('Your Gemini API key has been updated.'),
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
        const SnackBar(
          content: Text('API Key saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAboutDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder:
            (context) => CupertinoAlertDialog(
              title: const Text('About Smart Prescription Scanner'),
              content: const Column(
                children: [
                  SizedBox(height: 16),
                  Text('Version 1.0.0'),
                  SizedBox(height: 8),
                  Text(
                    'This app helps you scan and analyze your prescriptions using AI.',
                  ),
                  SizedBox(height: 16),
                  Text('© 2023 Your Company'),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
      );
    } else {
      showAboutDialog(
        context: context,
        applicationName: 'Smart Prescription Scanner',
        applicationVersion: '1.0.0',
        applicationLegalese: '© 2023 Your Company',
        children: [
          const SizedBox(height: 16),
          const Text(
            'This app helps you scan and analyze your prescriptions using AI.',
          ),
        ],
      );
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri uri = Uri.parse('https://yourcompany.com/privacy-policy');

    try {
      if (!await launchUrl(uri)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      if (Platform.isIOS) {
        showCupertinoDialog(
          context: context,

          builder:
              (context) => CupertinoAlertDialog(
                title: const Text('Error'),
                content: const Text('Could not open privacy policy'),
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
          const SnackBar(content: Text('Could not open privacy policy')),
        );
      }
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

            // Appearance section
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

            // Notifications section
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

            // Storage section
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

            // API Key section
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
                  prefix: const Text(''),
                  child: CupertinoButton(
                    child: const Text('Save API Key'),
                    onPressed: () => _saveApiKey(_apiKeyController.text),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // About section
            _buildIOSSectionHeader('About'),
            CupertinoFormSection(
              children: [
                CupertinoFormRow(
                  prefix: const Text('App Version'),
                  child: const Text('1.0.0'),
                ),
                CupertinoFormRow(
                  prefix: const Text('About'),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View Information'),
                        Icon(CupertinoIcons.forward, size: 18),
                      ],
                    ),
                    onPressed: _showAboutDialog,
                  ),
                ),
                CupertinoFormRow(
                  prefix: const Text('Privacy Policy'),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('View Policy'),
                        Icon(CupertinoIcons.forward, size: 18),
                      ],
                    ),
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
          // Appearance section
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications section
          _buildSectionHeader('Notifications'),
          Card(
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),

          const SizedBox(height: 16),

          // Storage section
          _buildSectionHeader('Storage'),
          Card(
            child: SwitchListTile(
              title: const Text('Save Prescription Images'),
              subtitle: const Text('Keep copies of scanned prescriptions'),
              value: _saveImages,
              onChanged: _toggleSaveImages,
            ),
          ),

          const SizedBox(height: 16),

          // API Key section
          _buildSectionHeader('API Settings'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

          // About section
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('App Version'),
                  trailing: const Text('1.0.0'),
                ),
                const Divider(),
                ListTile(
                  title: const Text('About'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showAboutDialog,
                ),
                const Divider(),
                ListTile(
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _launchPrivacyPolicy,
                ),
              ],
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
