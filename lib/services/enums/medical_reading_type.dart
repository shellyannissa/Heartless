import 'package:flutter/material.dart';

enum MedicalReadingType {
  heartRate,
  bloodPressure,
  weight,
  glucose,
  other,
}

extension MedicalReadingTypeExtension on MedicalReadingType {
  String get tag {
    switch (this) {
      case MedicalReadingType.heartRate:
        return 'Heart Rate';
      case MedicalReadingType.bloodPressure:
        return 'Blood Pressure';
      case MedicalReadingType.weight:
        return 'Weight';
      case MedicalReadingType.glucose:
        return 'Glucose';
      case MedicalReadingType.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case MedicalReadingType.heartRate:
        return 'assets/Icons/readingGenre/heartRate.png';
      case MedicalReadingType.bloodPressure:
        return 'assets/Icons/readingGenre/bloodPressure.png';
      case MedicalReadingType.weight:
        return 'assets/Icons/readingGenre/weight.png';
      case MedicalReadingType.glucose:
        return 'assets/Icons/readingGenre/diabetes.png';
      case MedicalReadingType.other:
        return 'assets/Icons/readingGenre/other.png';
    }
  }

  Color get color {
    switch (this) {
      case MedicalReadingType.heartRate:
        return Colors.pink.shade200;
      case MedicalReadingType.bloodPressure:
        return Colors.blue.shade200;
      case MedicalReadingType.weight:
        return Colors.green.shade200;
      case MedicalReadingType.glucose:
        return Colors.orange.shade200;
      case MedicalReadingType.other:
        return Colors.brown.shade200;
    }
  }
}
