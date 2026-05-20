import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/detection_pin.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';

class Vicinity {
  final List<AnimalPin> animals;
  final List<DetectionPin> detections;
  final List<InteractionQueryResult> interactions;

  Vicinity({
    required this.animals,
    required this.detections,
    required this.interactions,
  });

  factory Vicinity.fromJson(Map<String, dynamic> json) {
    final animalsList = json['animals'] as List? ?? [];
    final detectionsList = json['detections'] as List? ?? [];
    final interactionsList = json['interactions'] as List? ?? [];

    final animals = <AnimalPin>[];
    final detections = <DetectionPin>[];
    final interactions = <InteractionQueryResult>[];

    // Parse animals with error handling
    for (final item in animalsList) {
      if (item is Map) {
        try {
          animals.add(
            AnimalPin.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item),
            ),
          );
        } catch (e) {
          debugPrint('[Vicinity] Failed to parse animal: $e');
          debugPrint('[Vicinity] Animal JSON: $item');
        }
      }
    }

    for (final item in detectionsList) {
      if (item is Map) {
        try {
          detections.add(
            DetectionPin.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item),
            ),
          );
        } catch (e) {
          debugPrint('[Vicinity] Failed to parse detection: $e');
          debugPrint('[Vicinity] Detection JSON: $item');
        }
      }
    }

    for (final item in interactionsList) {
      if (item is Map) {
        try {
          interactions.add(
            InteractionQueryResult.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item),
            ),
          );
        } catch (e) {
          debugPrint('[Vicinity] Failed to parse interaction: $e');
          debugPrint('[Vicinity] Interaction JSON: $item');
        }
      }
    }

    debugPrint(
      '[Vicinity] Successfully parsed: ${animals.length} animals, ${detections.length} detections, ${interactions.length} interactions',
    );

    return Vicinity(
      animals: animals,
      detections: detections,
      interactions: interactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animals': animals.length,
      'detections': detections.length,
      'interactions': interactions.length,
    };
  }
}
