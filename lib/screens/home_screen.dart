import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('My Prescriptions'),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.doc_text,
                  size: 100,
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(height: 20),
                const Text(
                  'No prescriptions yet',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  onPressed: () {
                    // Navigate to scan tab
                    final CupertinoTabController controller =
                        CupertinoTabController(initialIndex: 1);
                    controller.index = 1;
                  },
                  child: const Text('Scan a Prescription'),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('My Prescriptions')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.description, size: 100, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'No prescriptions yet',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/scan');
                },
                child: const Text('Scan a Prescription'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
