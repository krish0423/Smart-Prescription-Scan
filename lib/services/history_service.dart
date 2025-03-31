import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prescription.dart';

class HistoryService {
  static const String _historyKey = 'prescription_history';

  Future<List<Map<String, dynamic>>> getPrescriptionHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];

      final List<Map<String, dynamic>> history = [];

      for (final item in historyJson) {
        final Map<String, dynamic> data = jsonDecode(item);

        // Check if the image file still exists
        if (data.containsKey('imagePath')) {
          final File imageFile = File(data['imagePath']);
          if (!await imageFile.exists()) {
            data['imagePath'] = null;
          }
        }

        history.add(data);
      }

      return history;
    } catch (e) {
      print('Error getting prescription history: $e');
      return [];
    }
  }

  Future<void> savePrescription(
    Map<String, dynamic> prescriptionData,
    String imagePath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];

      // Save a copy of the image to app documents directory
      final String savedImagePath = await _saveImageCopy(imagePath);

      // Add timestamp and image path
      final Map<String, dynamic> historyItem = {
        ...prescriptionData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,

        'imagePath': savedImagePath,
      };

      historyJson.add(jsonEncode(historyItem));

      // Limit history to last 20 items
      if (historyJson.length > 20) {
        // Get the oldest item
        final oldestItem = jsonDecode(historyJson.first);

        // Delete its image if it exists
        if (oldestItem.containsKey('imagePath') &&
            oldestItem['imagePath'] != null) {
          final File oldImage = File(oldestItem['imagePath']);
          if (await oldImage.exists()) {
            await oldImage.delete();
          }
        }

        // Remove the oldest item
        historyJson.removeAt(0);
      }

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      print('Error saving prescription: $e');
    }
  }

  Future<void> deletePrescription(int timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];

      // Find the item with the matching timestamp
      int indexToRemove = -1;
      String? imagePathToDelete;

      for (int i = 0; i < historyJson.length; i++) {
        final item = jsonDecode(historyJson[i]);
        if (item['timestamp'] == timestamp) {
          indexToRemove = i;
          imagePathToDelete = item['imagePath'];
          break;
        }
      }

      if (indexToRemove >= 0) {
        // Delete the image if it exists
        if (imagePathToDelete != null) {
          final File imageFile = File(imagePathToDelete);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }

        // Remove the item from history
        historyJson.removeAt(indexToRemove);
        await prefs.setStringList(_historyKey, historyJson);
      }
    } catch (e) {
      print('Error deleting prescription: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> historyJson = prefs.getStringList(_historyKey) ?? [];

      // Delete all saved images
      for (final item in historyJson) {
        final data = jsonDecode(item);
        if (data.containsKey('imagePath') && data['imagePath'] != null) {
          final File imageFile = File(data['imagePath']);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        }
      }

      // Clear history
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  Future<String> _saveImageCopy(String originalPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool saveImages = prefs.getBool('save_images') ?? true;

      if (!saveImages) {
        return originalPath; // Don't save a copy if the setting is disabled
      }

      final File originalFile = File(originalPath);
      if (!await originalFile.exists()) {
        return originalPath;
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String prescriptionsDir = path.join(appDir.path, 'prescriptions');

      // Create the directory if it doesn't exist
      final Directory directory = Directory(prescriptionsDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Generate a unique filename
      final String filename =
          'prescription_${DateTime.now().millisecondsSinceEpoch}${path.extension(originalPath)}';
      final String newPath = path.join(prescriptionsDir, filename);

      // Copy the file
      await originalFile.copy(newPath);

      return newPath;
    } catch (e) {
      print('Error saving image copy: $e');
      return originalPath;
    }
  }
}
