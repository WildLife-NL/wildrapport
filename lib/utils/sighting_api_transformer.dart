import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/enums/location_source.dart';
import 'package:wildlifenl_rapporten_components/wildlifenl_rapporten_components.dart';

class SightingApiTransformer {
  static Map<String, dynamic> transformForApi(AnimalSightingModel sighting) {
    debugPrint('=== Starting API Transform ===');
    debugPrint('Input Sighting: ${sighting.toJson()}');

    // Validate required fields
    if (sighting.locations == null || sighting.locations!.isEmpty) {
      throw StateError('Location is required for API submission');
    }
    if (sighting.dateTime == null || sighting.dateTime!.dateTime == null) {
      throw StateError('DateTime is required for API submission');
    }
    if (sighting.animals == null || sighting.animals!.isEmpty) {
      throw StateError('At least one animal is required for API submission');
    }
    if (sighting.animalSelected?.animalId == null) {
      throw StateError('Species ID is required for API submission');
    }

    // Find system and manual locations
    // Prefer system location if available, fall back to manual if GPS wasn't acquired
    final systemLocation = sighting.locations!.firstWhere(
      (loc) => loc.source == LocationSource.system,
      orElse: () {
        // GPS wasn't acquired - try to use manual location as fallback
        final manual = sighting.locations!.firstWhere(
          (loc) => loc.source == LocationSource.manual,
          orElse: () => throw StateError('At least one location (system or manual) is required'),
        );
        debugPrint('⚠️ System location not available, using manual location as fallback');
        return manual;
      },
    );
    debugPrint('System Location: ${systemLocation.toJson()}');

    // Prefer manual location; if not provided, fall back to system
    final manualLocation = sighting.locations!.firstWhere(
      (loc) => loc.source == LocationSource.manual,
      orElse: () => systemLocation,
    );
    debugPrint('Manual Location: ${manualLocation.toJson()}');

    final involvedAnimals = <InvolvedAnimalDto>[];
    for (final animal in sighting.animals!) {
      final condition = animal.condition?.toString().split('.').last ?? 'other';
      final mappedCondition = _mapCondition(condition);

      for (final genderView in animal.genderViewCounts) {
        final genderString = genderView.gender.toString().split('.').last;
        final sex = _mapSex(genderString);

        void addEntries(int amount, String ageKey) {
          if (amount > 0) {
            final age = _mapAge(ageKey);
            final lifeStage = _mapLifeStage(age);
            for (int i = 0; i < amount; i++) {
              involvedAnimals.add(InvolvedAnimalDto(
                condition: mappedCondition,
                lifeStage: lifeStage,
                sex: sex,
              ));
            }
          }
        }

        addEntries(genderView.viewCount.pasGeborenAmount, 'pasGeborenAmount');
        addEntries(genderView.viewCount.onvolwassenAmount, 'onvolwassenAmount');
        addEntries(genderView.viewCount.volwassenAmount, 'volwassenAmount');
        addEntries(genderView.viewCount.unknownAmount, 'unknownAmount');
      }
    }

    if (involvedAnimals.isEmpty) {
      involvedAnimals.add(const InvolvedAnimalDto(
        condition: 'unknown',
        lifeStage: 'unknown',
        sex: 'unknown',
      ));
    }

    final apiPayload = RapportenApiBodyBuilder.buildSightingBody(
      description: sighting.description ?? '',
      locationLatitude: systemLocation.latitude ?? 0.0,
      locationLongitude: systemLocation.longitude ?? 0.0,
      placeLatitude: manualLocation.latitude ?? 0.0,
      placeLongitude: manualLocation.longitude ?? 0.0,
      moment: sighting.dateTime!.dateTime!,
      speciesID: sighting.animalSelected!.animalId ?? '',
      involvedAnimals: involvedAnimals,
    );

    debugPrint('=== Final API Payload ===');
    debugPrint(const JsonEncoder.withIndent('  ').convert(apiPayload));
    debugPrint('========================');

    return apiPayload;
  }

  static String _mapSex(String genderEnum) {
    switch (genderEnum.toLowerCase()) {
      case 'vrouwelijk':
        return 'female';
      case 'mannelijk':
        return 'male';
      case 'onbekend':
      default:
        return 'unknown';
    }
  }

  static String _mapAge(String ageKey) {
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

  static String _mapCondition(String condition) {
    switch (condition.toLowerCase()) {
      case 'gezond':
        return 'healthy';
      case 'ziek':
        return 'impaired';
      case 'dood':
        return 'dead';
      case 'onbekend':
        return 'unknown';
      default:
        return 'unknown';
    }
  }

  static String _mapLifeStage(String age) {
    switch (age.toLowerCase()) {
      case 'pasgeboren':
        return 'infant';
      case 'onvolwassen':
        return 'adolescent';
      case 'volwassen':
        return 'adult';
      default:
        return 'unknown';
    }
  }
}
