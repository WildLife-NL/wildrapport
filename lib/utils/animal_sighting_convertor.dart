
import 'package:wildrapport/models/animal_sighting_model.dart';

class AnimalSightingConvertor {
  /// Converts an AnimalSightingModel to the format required by the API
  static Map<String, dynamic> toApiFormat(AnimalSightingModel report) {
    final List<Map<String, dynamic>> allInvolvedAnimals = [];
    
    for (final animal in report.animals ?? []) {
      allInvolvedAnimals.addAll(transformInvolvedAnimals(animal));
    }

    if (report.locations == null || report.locations!.isEmpty) {
      throw StateError('Location is required for API submission');
    }

    final systemLocation = report.locations!
        .firstWhere((loc) => loc.source.toString().split('.').last == 'system');
    final userLocation = report.locations!
        .firstWhere((loc) => loc.source.toString().split('.').last == 'manual');

    return {
      "description": report.description,
      "location": {
        "latitude": systemLocation.latitude,
        "longitude": systemLocation.longitude,
      },
      "moment": report.dateTime?.dateTime?.toIso8601String(),
      "place": {
        "latitude": userLocation.latitude,
        "longitude": userLocation.longitude,
      },
      "reportOfSighting": {
        "sightingReportID": null,
        "involvedAnimals": allInvolvedAnimals
      },
      "suspectedSpeciesID": report.animalSelected?.animalId,
      "typeID": 1
    };
  }

  static List<Map<String, dynamic>> transformInvolvedAnimals(dynamic animal) {
    final List<Map<String, dynamic>> involvedAnimals = [];

    final condition = animal.condition.toString().split('.').last;
    final mappedCondition = mapCondition(condition);
    final animalId = animal.animalId;
    final animalName = animal.animalName;

    for (final genderView in animal.genderViewCounts) {
      final genderString = genderView.gender.toString().split('.').last;
      final gender = mapGender(genderString);
      final viewCount = genderView.viewCount;

      // Handle pasGeboren
      if (viewCount.pasGeborenAmount > 0) {
        for (int i = 0; i < viewCount.pasGeborenAmount; i++) {
          involvedAnimals.add({
            "animalID": animalId,
            "animalName": animalName,
            "animalGender": gender,
            "animalAge": mapAge('pasGeborenAmount'),
            "animalCondition": mappedCondition,
            "intensity": null,
            "urgency": null
          });
        }
      }

      // Handle onvolwassen
      if (viewCount.onvolwassenAmount > 0) {
        for (int i = 0; i < viewCount.onvolwassenAmount; i++) {
          involvedAnimals.add({
            "animalID": animalId,
            "animalName": animalName,
            "animalGender": gender,
            "animalAge": mapAge('onvolwassenAmount'),
            "animalCondition": mappedCondition,
            "intensity": null,
            "urgency": null
          });
        }
      }

      // Handle volwassen
      if (viewCount.volwassenAmount > 0) {
        for (int i = 0; i < viewCount.volwassenAmount; i++) {
          involvedAnimals.add({
            "animalID": animalId,
            "animalName": animalName,
            "animalGender": gender,
            "animalAge": mapAge('volwassenAmount'),
            "animalCondition": mappedCondition,
            "intensity": null,
            "urgency": null
          });
        }
      }

      // Handle unknown
      if (viewCount.unknownAmount > 0) {
        for (int i = 0; i < viewCount.unknownAmount; i++) {
          involvedAnimals.add({
            "animalID": animalId,
            "animalName": animalName,
            "animalGender": gender,
            "animalAge": mapAge('unknownAmount'),
            "animalCondition": mappedCondition,
            "intensity": null,
            "urgency": null
          });
        }
      }
    }

    return involvedAnimals;
  }

  static String mapGender(String genderEnum) {
    switch (genderEnum) {
      case 'vrouwelijk':
        return 'Vrouwelijk';
      case 'mannelijk':
        return 'Mannelijk';
      case 'onbekend':
      default:
        return 'Onbekend';
    }
  }

  static String mapAge(String ageKey) {
    switch (ageKey) {
      case 'pasGeborenAmount':
        return 'Pasgeboren';
      case 'onvolwassenAmount':
        return 'Onvolwassen';
      case 'volwassenAmount':
        return 'Volwassen';
      case 'unknownAmount':
      default:
        return 'Onbekend';
    }
  }

  static String mapCondition(String conditionEnum) {
    switch (conditionEnum) {
      case 'gezond':
        return 'Gezond';
      case 'gewond':
        return 'Gewond';
      case 'dood':
        return 'Dood';
      default:
        return 'Onbekend';
    }
  }
}








