import 'dart:io'
    if (dart.library.html) 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'providers/theme_provider.dart';
import 'screens/camera_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reminders_screen.dart';
import 'utils/ios_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Prescription Scanner',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeProvider.themeMode,
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
            ],
            home: Platform.isIOS ? const IOSHomeScreen() : const HomeScreen(),
          );
        },
      ),
    );
  }
}

mixin GlobalCupertinoLocalizations {}

// iOS-specific home screen with tab bar
class IOSHomeScreen extends StatefulWidget {
  const IOSHomeScreen({Key? key}) : super(key: key);

  @override
  State<IOSHomeScreen> createState() => _IOSHomeScreenState();
}

class _IOSHomeScreenState extends State<IOSHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    CameraScreen(),
    HistoryScreen(),
    RemindersScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.camera),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.clock),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bell),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return _screens[index];
          },
        );
      },
    );
  }
}

// Android home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    CameraScreen(),
    HistoryScreen(),
    RemindersScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
