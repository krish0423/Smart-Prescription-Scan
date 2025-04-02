import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform, File;
import 'package:google_ml_kit/google_ml_kit.dart';

class ScanResultsScreen extends StatefulWidget {
  final File? scannedImage;

  const ScanResultsScreen({Key? key, this.scannedImage}) : super(key: key);

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen> {
  bool _isLoading = true;
  String _extractedText = '';
  Map<String, String> _extractedData = {};

  @override
  void initState() {
    super.initState();
    if (widget.scannedImage != null) {
      _processImage(widget.scannedImage!);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processImage(File image) async {
    try {
      // Create an InputImage from the file
      final inputImage = InputImage.fromFile(image);

      // Get an instance of the text recognizer
      final textRecognizer = GoogleMlKit.vision.textRecognizer();

      // Process the image and extract text
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      // Get the full text
      String fullText = recognizedText.text;

      // Parse the extracted text to identify prescription elements
      Map<String, String> parsedData = _parsePrescriptionText(fullText);

      // Release resources
      await textRecognizer.close();

      if (mounted) {
        setState(() {
          _extractedText = fullText;
          _extractedData = parsedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _extractedText = 'Error extracting text: $e';
          _isLoading = false;
        });
      }
    }
  }

  Map<String, String> _parsePrescriptionText(String text) {
    // This is a simple parser that looks for common patterns in prescriptions
    // In a real app, you would use more sophisticated NLP techniques
    Map<String, String> result = {};

    // Look for patient name
    RegExp patientRegex = RegExp(
      r'(?:Patient|Name)[:\s]+([A-Za-z\s]+)',
      caseSensitive: false,
    );
    Match? patientMatch = patientRegex.firstMatch(text);
    if (patientMatch != null && patientMatch.groupCount >= 1) {
      result['Patient Name'] = patientMatch.group(1)!.trim();
    }

    // Look for medication
    RegExp medicationRegex = RegExp(
      r'(?:Rx|Medication|Drug)[:\s]+([A-Za-z0-9\s]+)',
      caseSensitive: false,
    );
    Match? medicationMatch = medicationRegex.firstMatch(text);
    if (medicationMatch != null && medicationMatch.groupCount >= 1) {
      result['Medication'] = medicationMatch.group(1)!.trim();
    }

    // Look for dosage
    RegExp dosageRegex = RegExp(
      r'(?:Dosage|Dose)[:\s]+([A-Za-z0-9\s]+(?:mg|g|ml|mcg))',
      caseSensitive: false,
    );
    Match? dosageMatch = dosageRegex.firstMatch(text);
    if (dosageMatch != null && dosageMatch.groupCount >= 1) {
      result['Dosage'] = dosageMatch.group(1)!.trim();
    }

    // Look for frequency
    RegExp frequencyRegex = RegExp(
      r'(?:Frequency|Take)[:\s]+([A-Za-z0-9\s]+(?:daily|weekly|monthly|hours|days))',
      caseSensitive: false,
    );
    Match? frequencyMatch = frequencyRegex.firstMatch(text);
    if (frequencyMatch != null && frequencyMatch.groupCount >= 1) {
      result['Frequency'] = frequencyMatch.group(1)!.trim();
    }

    // Look for doctor
    RegExp doctorRegex = RegExp(
      r'(?:Doctor|Dr|Physician)[:\s\.]+([A-Za-z\s\.]+)',
      caseSensitive: false,
    );
    Match? doctorMatch = doctorRegex.firstMatch(text);
    if (doctorMatch != null && doctorMatch.groupCount >= 1) {
      result['Doctor'] = doctorMatch.group(1)!.trim();
    }

    // Look for date
    RegExp dateRegex = RegExp(
      r'(?:Date)[:\s]+(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})',
      caseSensitive: false,
    );
    Match? dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null && dateMatch.groupCount >= 1) {
      result['Date'] = dateMatch.group(1)!.trim();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Scan Results'),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingView() : _buildResultsView(context),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Results')),
        body: _isLoading ? _buildLoadingView() : _buildResultsView(context),
      );
    }
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (Platform.isIOS)
            const CupertinoActivityIndicator(radius: 20)
          else
            const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            'Analyzing prescription...',
            style: TextStyle(
              fontSize: 16,
              color:
                  Platform.isIOS
                      ? CupertinoColors.systemGrey
                      : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.scannedImage != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                widget.scannedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
          ],

          Text(
            'Extracted Information',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Platform.isIOS ? CupertinoColors.black : Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Display extracted data if available
          if (_extractedData.isNotEmpty) ...[
            ..._extractedData.entries.map(
              (entry) => _buildDataRow(entry.key, entry.value),
            ),
          ] else ...[
            // Display raw extracted text if structured data couldn't be parsed
            const Text(
              'Raw Extracted Text:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _extractedText.isEmpty
                  ? 'No text detected in the image.'
                  : _extractedText,
              style: const TextStyle(fontSize: 16),
            ),
          ],

          const SizedBox(height: 30),

          // Action buttons
          Center(
            child:
                Platform.isIOS
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Rescan'),
                        ),
                        CupertinoButton.filled(
                          onPressed:
                              _extractedData.containsKey('Medication')
                                  ? () {
                                    // Save to prescription history
                                    Navigator.pushNamed(
                                      context,
                                      '/prescription_detail',
                                      arguments:
                                          _extractedData['Medication'] ??
                                          'Medication',
                                    );
                                  }
                                  : null,
                          child: const Text('Save Prescription'),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Rescan'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed:
                              _extractedData.containsKey('Medication')
                                  ? () {
                                    // Save to prescription history
                                    Navigator.pushNamed(
                                      context,
                                      '/prescription_detail',
                                      arguments:
                                          _extractedData['Medication'] ??
                                          'Medication',
                                    );
                                  }
                                  : null,
                          child: const Text('Save Prescription'),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color:
                    Platform.isIOS
                        ? CupertinoColors.systemGrey
                        : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Platform.isIOS ? CupertinoColors.black : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
