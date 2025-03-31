import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/prescription.dart';

// If you want to implement sharing, also add:
// import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> prescriptionData;
  final File imageFile;

  const ResultScreen({
    Key? key,
    required this.prescriptionData,
    required this.imageFile,
  }) : super(key: key);

  Future<void> _sharePrescription(
    BuildContext context,
    Prescription prescription,
  ) async {
    try {
      // Create a text summary of the prescription
      final StringBuffer summary = StringBuffer();
      summary.writeln('PRESCRIPTION DETAILS');
      summary.writeln('Doctor: ${prescription.doctorName}');
      summary.writeln('Patient: ${prescription.patientName}');
      summary.writeln('Date: ${prescription.date}');

      if (prescription.diagnosis != null) {
        summary.writeln('Diagnosis: ${prescription.diagnosis}');
      }

      summary.writeln('\nMEDICATIONS:');
      for (final med in prescription.medications) {
        summary.writeln('- ${med.name}');
        summary.writeln('  Dosage: ${med.dosage}');
        summary.writeln('  Frequency: ${med.frequency}');
        if (med.duration != null) {
          summary.writeln('  Duration: ${med.duration}');
        }
        summary.writeln('');
      }

      if (prescription.specialInstructions != null) {
        summary.writeln('SPECIAL INSTRUCTIONS:');
        summary.writeln(prescription.specialInstructions);
      }

      // Create a temporary file with the summary
      final tempDir = await getTemporaryDirectory();
      final summaryFile = File('${tempDir.path}/prescription_summary.txt');
      await summaryFile.writeAsString(summary.toString());

      // If you have share_plus package:
      // await Share.shareFiles(
      //   [summaryFile.path, imageFile.path],
      //   text: 'Prescription for ${prescription.patientName}'
      // );

      // For now, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('To enable sharing, add the share_plus package'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if there was an error
    if (prescriptionData.containsKey('error')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analysis Failed')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Error: ${prescriptionData['error']}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              if (prescriptionData.containsKey('rawResponse'))
                Text('Raw Response: ${prescriptionData['rawResponse']}'),
              const SizedBox(height: 20),
              Image.file(imageFile),
            ],
          ),
        ),
      );
    }

    // Try to parse the prescription data
    Prescription prescription;
    try {
      prescription = Prescription.fromJson(prescriptionData);
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Parsing Error')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Error parsing data: $e',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text('Raw data: $prescriptionData'),
              const SizedBox(height: 20),
              Image.file(imageFile),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),

            onPressed: () => _sharePrescription(context, prescription),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor: ${prescription.doctorName}',

                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Patient: ${prescription.patientName}'),
                    Text('Date: ${prescription.date}'),
                    if (prescription.diagnosis != null)
                      Text('Diagnosis: ${prescription.diagnosis}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Medications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (prescription.medications.isEmpty)
              const Text('No medications found')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: prescription.medications.length,
                itemBuilder: (context, index) {
                  final med = prescription.medications[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(med.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dosage: ${med.dosage}'),
                          Text('Frequency: ${med.frequency}'),
                          if (med.duration != null)
                            Text('Duration: ${med.duration}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            if (prescription.specialInstructions != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Special Instructions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(prescription.specialInstructions!),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Original Prescription Image'),
              children: [Image.file(imageFile)],
            ),
          ],
        ),
      ),
    );
  }
}
