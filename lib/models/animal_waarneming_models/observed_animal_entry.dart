import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_age_extensions.dart';
import 'package:wildrapport/models/enums/animal_gender_extensions.dart';
import 'package:wildrapport/models/enums/animal_condition_extensions.dart';

class ObservedAnimalEntry {
  final AnimalAge age;
  final AnimalGender gender;
  final AnimalCondition condition;
  final int count;

  ObservedAnimalEntry({
    required this.age,
    required this.gender,
    required this.condition,
    required this.count,
  });

  /// Build one backend animal object for this entry.
  /// This returns the shape the backend expects for a *single* animal.
  /// If `count` > 1, you'll duplicate this map `count` times when building the payload.
  Map<String, dynamic> toBackendMapSingle() {
    return {
      'sex': gender.apiValue,          // "male" | "female" | "other"
      'lifeStage': age.apiValue,       // "infant" | "adolescent" | "adult" | "unknown"
      'condition': condition.apiValue, // "healthy" | "impaired" | "dead" | "other"
    };
  }
}
