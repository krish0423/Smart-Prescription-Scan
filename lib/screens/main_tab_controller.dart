import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'scan_prescription_screen.dart';
import 'scan_results_screen.dart';
import 'prescription_detail_screen.dart';

class MainTabController extends StatefulWidget {
  // Change the type to match what you're passing
  final Function toggleTheme;

  const MainTabController({Key? key, required this.toggleTheme})
    : super(key: key);

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  @override
  Widget build(BuildContext context) {
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
                          ModalRoute.of(context)!.settings.arguments as String,
                    ),
              },
            );
          case 1:
            return CupertinoTabView(
              builder: (context) => const ScanPrescriptionScreen(),
              routes: {'/scan_results': (context) => const ScanResultsScreen()},
            );
          case 2:
            return CupertinoTabView(
              builder: (context) => const SettingsScreen(),
            );
          default:
            return CupertinoTabView(builder: (context) => const HomeScreen());
        }
      },
    );
  }
}
