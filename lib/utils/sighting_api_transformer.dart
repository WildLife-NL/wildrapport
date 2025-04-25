import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/models/beta_models/sighting_report_model.dart';
import 'package:wildrapport/models/beta_models/sighted_animal_model.dart';
import 'package:wildrapport/models/enums/location_source.dart';
import 'dart:convert';

class SightingApiTransformer {
  static Map<String, dynamic> transformForApi(AnimalSightingModel sighting) {
    debugPrint('=== Starting API Transform ===');
    debugPrint('Input Sighting: ${sighting.toJson()}');

    if (sighting.locations == null || sighting.locations!.isEmpty) {
      throw StateError('Location is required for API submission');
    }

    if (sighting.dateTime == null) {
      throw StateError('DateTime is required for API submission');
    }

    if (sighting.animals == null || sighting.animals!.isEmpty) {
      throw StateError('At least one animal is required for API submission');
    }

    // Find system and manual locations
    final systemLocation = sighting.locations!
        .firstWhere((loc) => loc.source == LocationSource.system,
            orElse: () => throw StateError('System location is required'));
    debugPrint('System Location: ${systemLocation.toJson()}');

    final manualLocation = sighting.locations!
        .firstWhere((loc) => loc.source == LocationSource.manual,
            orElse: () => throw StateError('Manual location is required'));
    debugPrint('Manual Location: ${manualLocation.toJson()}');

    // Transform animals to SightedAnimal format
    final List<SightedAnimal> sightedAnimals = sighting.animals!.map((animal) {
      final primaryCount = animal.genderViewCounts.first;
      final sightedAnimal = SightedAnimal(
        animalID: animal.animalId,
        animalName: animal.animalName,
        animalGender: primaryCount.gender.toString(),
        animalAge: primaryCount.viewCount.getAge().toString(),
        animalCondition: animal.condition?.toString() ?? 'unknown',
        intensity: null,
        urgency: null,
      );
      debugPrint('Transformed Animal: ${sightedAnimal.toJson()}');
      return sightedAnimal;
    }).toList();

    final sightingReport = SightingReport(
      sightingReportID: null,
      animals: sightedAnimals,
      systemDateTime: DateTime.now(),
    );
    debugPrint('Sighting Report: ${sightingReport.toJson()}');

    final apiPayload = {
      "description": sighting.description ?? '',
      "location": {
        "latitude": systemLocation.latitude,
        "longitude": systemLocation.longitude,
      },
      "moment": sighting.dateTime!.dateTime?.toUtc().toIso8601String(),
      "place": {
        "latitude": manualLocation.latitude,
        "longitude": manualLocation.longitude,
      },
      "reportOfSighting": sightingReport.toJson(),
      "suspectedSpeciesID": sighting.animalSelected?.animalId,
      "typeID": 1,
    };
    
    debugPrint('=== Final API Payload ===');
    debugPrint(const JsonEncoder.withIndent('  ').convert(apiPayload));
    debugPrint('========================');

    return apiPayload;
  }
}


