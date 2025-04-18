import 'dart:io';
import 'dart:convert'; // Added for jsonDecode
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiService {
  late final Gemini _gemini;

  GeminiService() {
    if (!dotenv.isInitialized) {
      dotenv.load();
    }
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    _gemini = Gemini.init(
        apiKey: apiKey!); // Updated initialization for latest version
  }

  Future<Map<String, dynamic>> analyzePrescription(File imageFile) async {
    try {
      final prompt =
          '''Analyze the given prescription image and extract the following information in JSON format:
{
  "doctorName": "(Doctor's name if available, otherwise null)",
  "patientName": "(Patient's name if available, otherwise null)",
  "date": "(Prescription date if available, otherwise null)",
  "diagnosis": "(Diagnosis details if mentioned, otherwise null)",
  "medications": [
    {
      "name": "(Medicine name if available, otherwise null)",
      "dosage": "(Dosage details if available, otherwise null)",
      "frequency": "(How often the medicine should be taken, otherwise null)",
      "duration": "(Duration of medication if available, otherwise null)"
    }
  ],
  "specialInstructions": "(Special notes or instructions if mentioned, otherwise null)"
}
Ensure the output is a valid JSON object and does not contain any additional text or explanations.''';

      final response = await _gemini.textAndImage(
        text: prompt,
        images: [imageFile.readAsBytesSync()],
      );

      if (response?.output != null) {
        try {
          // Clean the response to extract just the JSON part
          String cleanedResponse = response!.output!;

          // Remove markdown code block indicators if present
          if (cleanedResponse.contains("")) {
            cleanedResponse =
                cleanedResponse.replaceAll("json", "").replaceAll("", "");
          } else if (cleanedResponse.contains("")) {
            cleanedResponse = cleanedResponse.replaceAll("```", "");
          }

          // Trim whitespace
          cleanedResponse = cleanedResponse.trim();

          debugPrint("Cleaned response: $cleanedResponse");

          // Parse the JSON
          return jsonDecode(cleanedResponse);
        } catch (e) {
          debugPrint('Error parsing JSON response: $e');
          return {
            'error': 'Failed to parse prescription data',
            'rawResponse': response?.output,
          };
        }
      } else {
        return {
          'error': 'No response from Gemini API',
          'rawResponse': response?.toString() ?? 'Null response',
        };
      }
    } catch (e) {
      debugPrint('Error analyzing prescription: $e');
      return {'error': 'Error analyzing prescription: ${e.toString()}'};
    }
  }
}
