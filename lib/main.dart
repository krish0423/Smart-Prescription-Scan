import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'screens/home_screen.dart';
import 'screens/scan_prescription_screen.dart';
import 'screens/scan_results_screen.dart';
import 'screens/prescription_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return MaterialApp(
        title: 'Smart Prescription Scanner',
        theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        // Add Material localizations
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.camera),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: 'Settings',
              ),
            ],
          ),
          tabBuilder: (context, index) {
            switch (index) {
              case 0:
                return CupertinoTabView(
                  builder: (context) => const HomeScreen(),
                  routes: {
                    '/prescription_detail':
                        (context) => PrescriptionDetailScreen(
                          medicationName:
                              ModalRoute.of(context)!.settings.arguments
                                  as String,
                        ),
                    '/scan':
                        (context) =>
                            const ScanPrescriptionScreen(), // Add this route
                  },
                );
              case 1:
                return CupertinoTabView(
                  builder: (context) => const ScanPrescriptionScreen(),
                  routes: {
                    '/scan_results': (context) => const ScanResultsScreen(),
                    '/prescription_detail':
                        (context) => PrescriptionDetailScreen(
                          medicationName:
                              ModalRoute.of(context)!.settings.arguments
                                  as String,
                        ),
                  },
                );
              case 2:
                return CupertinoTabView(
                  builder:
                      (context) => SettingsScreen(toggleTheme: toggleTheme),
                );
              default:
                return CupertinoTabView(
                  builder: (context) => const HomeScreen(),
                );
            }
          },
        ),
      );
    } else {
      return MaterialApp(
        title: 'Smart Prescription Scanner',
        theme: _isDarkMode ? ThemeData.dark() : AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
        routes: {
          '/scan': (context) => const ScanPrescriptionScreen(),
          '/scan_results': (context) => const ScanResultsScreen(),
          '/prescription_detail':
              (context) => PrescriptionDetailScreen(
                medicationName:
                    ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/settings': (context) => SettingsScreen(toggleTheme: toggleTheme),
        },
      );
    }
  }
}

class MainTabController extends StatefulWidget {
  final Function toggleTheme; // Changed from Function(bool)

  const MainTabController({Key? key, required this.toggleTheme})
    : super(key: key);

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _tabs = [
      const HomeScreen(),
      const ScanPrescriptionScreen(),
      SettingsScreen(toggleTheme: widget.toggleTheme),
    ];

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.camera),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            return _tabs[index];
          },
        );
      },
    );
  }
}

class MainNavigationController extends StatefulWidget {
  final Function(bool) toggleTheme;

  const MainNavigationController({Key? key, required this.toggleTheme})
    : super(key: key);

  @override
  State<MainNavigationController> createState() =>
      _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const ScanPrescriptionScreen(),
    SettingsScreen(toggleTheme: widget.toggleTheme),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
