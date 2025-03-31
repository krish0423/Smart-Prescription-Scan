import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/medication_reminder.dart';

class ReminderService {
  static const String _remindersKey = 'medication_reminders';
  final Uuid _uuid = const Uuid();

  Future<List<MedicationReminder>> getReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> remindersJson =
          prefs.getStringList(_remindersKey) ?? [];

      return remindersJson
          .map((item) => MedicationReminder.fromJson(jsonDecode(item)))
          .toList();
    } catch (e) {
      print('Error getting reminders: $e');
      return [];
    }
  }

  Future<void> saveReminder(MedicationReminder reminder) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> remindersJson =
          prefs.getStringList(_remindersKey) ?? [];

      // Check if reminder exists
      final existingIndex = remindersJson.indexWhere((item) {
        final decoded = jsonDecode(item);
        return decoded['id'] == reminder.id;
      });

      if (existingIndex >= 0) {
        // Update existing reminder
        remindersJson[existingIndex] = jsonEncode(reminder.toJson());
      } else {
        // Add new reminder
        remindersJson.add(jsonEncode(reminder.toJson()));
      }

      await prefs.setStringList(_remindersKey, remindersJson);

      // Schedule notification (in a real app, you would implement this)
      // await _scheduleNotification(reminder);
    } catch (e) {
      print('Error saving reminder: $e');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> remindersJson =
          prefs.getStringList(_remindersKey) ?? [];

      final updatedReminders =
          remindersJson.where((item) {
            final decoded = jsonDecode(item);
            return decoded['id'] != id;
          }).toList();

      await prefs.setStringList(_remindersKey, updatedReminders);

      // Cancel notification (in a real app, you would implement this)
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }

  Future<void> toggleReminderActive(String id, bool isActive) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> remindersJson =
          prefs.getStringList(_remindersKey) ?? [];

      final updatedReminders =
          remindersJson.map((item) {
            final decoded = jsonDecode(item);
            if (decoded['id'] == id) {
              decoded['isActive'] = isActive;
              return jsonEncode(decoded);
            }
            return item;
          }).toList();

      await prefs.setStringList(_remindersKey, updatedReminders);

      // Update notification (in a real app, you would implement this)
    } catch (e) {
      print('Error toggling reminder: $e');
    }
  }

  String generateId() {
    return _uuid.v4();
  }
}
