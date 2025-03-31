import 'package:flutter/material.dart';

class MedicationReminder {
  final String id;
  final String medicationName;
  final String dosage;
  final TimeOfDay time;
  final List<bool> daysOfWeek; // Sunday to Saturday
  final bool isActive;

  MedicationReminder({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.time,
    required this.daysOfWeek,
    this.isActive = true,
  });

  factory MedicationReminder.fromJson(Map<String, dynamic> json) {
    return MedicationReminder(
      id: json['id'],
      medicationName: json['medicationName'],
      dosage: json['dosage'],
      time: TimeOfDay(hour: json['hour'], minute: json['minute']),
      daysOfWeek: List<bool>.from(json['daysOfWeek']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationName': medicationName,
      'dosage': dosage,
      'hour': time.hour,
      'minute': time.minute,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
    };
  }
}
