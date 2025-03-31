import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/io_client.dart';

class GeminiService {
  final String _baseUrl =
      'https://api.generativelanguage.googleapis.com/v1/models/gemini-pro-vision:generateContent'; // Verify this endpoint with API documentation

  Future<Map<String, dynamic>> analyzePrescription(File imageFile) async {
    try {
      if (!dotenv.isInitialized) {
        await dotenv.load();
      }
    } catch (e) {
      print('Error initializing dotenv: ${e.toString()}');
      return {'error': 'Failed to initialize environment variables.'};
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      return {
        'error':
            'API key not found. Please add your Gemini API key in the settings.',
      };
    }

    // Read image as bytes and convert to base64
    final List<int> imageBytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(imageBytes);

    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'contents': [
        {
          'parts': [
            {
              'text': '''
                Analyze this prescription image and extract the following information in JSON format:
                - Doctor's name
                - Patient's name
                - Date
                - Diagnosis (if present)
                - Medications (including name, dosage, frequency, and duration if available)
                - Special instructions (if any)
                
                Return ONLY a valid JSON object with these fields. Do not include any explanations or additional text.
                ''',
            },
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 32,
        'topP': 1,
        'maxOutputTokens': 4096,
      },
    };

    // Log the request for debugging
    print('Request URL: $_baseUrl?key=$apiKey');
    print('Request Body: ${jsonEncode(requestBody)}');

    // Create an HTTP client that ignores SSL errors
    final httpClient =
        HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
    final ioClient = IOClient(httpClient);

    // Make the API request
    final response = await ioClient.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    // Log the response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Extract the text content from the response
        if (responseData.containsKey('candidates') &&
            responseData['candidates'].isNotEmpty) {
          final String textContent =
              responseData['candidates'][0]['content']['parts'][0]['text'];

          // Parse the JSON from the text content
          return jsonDecode(textContent);
        } else {
          return {
            'error': 'Unexpected response structure',
            'rawResponse': response.body,
          };
        }
      } catch (e) {
        print('Error parsing response: ${e.toString()}');
        return {
          'error': 'Failed to parse prescription data',
          'rawResponse': response.body,
        };
      }
    } else {
      // Handle non-200 responses
      return {
        'error': 'API request failed with status ${response.statusCode}',
        'rawResponse': response.body,
      };
    }
  }
}
