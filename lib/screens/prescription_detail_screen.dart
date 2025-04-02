import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

class PrescriptionDetailScreen extends StatelessWidget {
  final String medicationName;

  const PrescriptionDetailScreen({Key? key, required this.medicationName})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text(medicationName)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medication Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildDetailRow('Name', medicationName),
                _buildDetailRow('Dosage', '10mg'),
                _buildDetailRow('Frequency', 'Twice daily'),
                _buildDetailRow('Duration', '7 days'),
                _buildDetailRow('Prescribed by', 'Dr. Smith'),
                _buildDetailRow('Date', '2023-05-15'),
                const SizedBox(height: 30),
                Center(
                  child: CupertinoButton.filled(
                    onPressed: () {
                      // Add to medication reminder
                    },
                    child: const Text('Add to Reminders'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text(medicationName)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medication Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Name', medicationName),
              _buildDetailRow('Dosage', '10mg'),
              _buildDetailRow('Frequency', 'Twice daily'),
              _buildDetailRow('Duration', '7 days'),
              _buildDetailRow('Prescribed by', 'Dr. Smith'),
              _buildDetailRow('Date', '2023-05-15'),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add to medication reminder
                  },
                  child: const Text('Add to Reminders'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
