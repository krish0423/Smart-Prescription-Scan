class Prescription {
  final String doctorName;
  final String patientName;
  final String date;
  final String? diagnosis;
  final List<Medication> medications;

  final String? specialInstructions;

  Prescription({
    required this.doctorName,
    required this.patientName,
    required this.date,
    this.diagnosis,
    required this.medications,

    this.specialInstructions,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      doctorName: json['doctorName'] ?? 'Unknown Doctor',
      patientName: json['patientName'] ?? 'Unknown Patient',
      date: json['date'] ?? 'Unknown Date',
      diagnosis: json['diagnosis'],

      medications:
          (json['medications'] as List?)
              ?.map((med) => Medication.fromJson(med))
              .toList() ??
          [],
      specialInstructions: json['specialInstructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorName': doctorName,
      'patientName': patientName,
      'date': date,
      'diagnosis': diagnosis,
      'medications': medications.map((med) => med.toJson()).toList(),
      'specialInstructions': specialInstructions,
    };
  }
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String? duration;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] ?? 'Unknown Medication',
      dosage: json['dosage'] ?? 'Unknown Dosage',
      frequency: json['frequency'] ?? 'Unknown Frequency',
      duration: json['duration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }
}
