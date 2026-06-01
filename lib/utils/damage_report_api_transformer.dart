import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wildrapport/models/beta_models/belonging_damage_report_model.dart';
import 'package:wildrapport/utils/interaction_payload_utils.dart';

class BelongingDamageApiTransformer {
  static Map<String, dynamic> transformForApi(BelongingDamageReport report) {
    debugPrint('=== Starting DamageReport API Transform ===');
    debugPrint(
      'Input Report: ${jsonEncode({
        "possesion": {"id": report.possesion.possesionID, "name": report.possesion.possesionName, "category": report.possesion.category},
        "impactedAreaType": report.impactedAreaType,
        "impactedArea": report.impactedArea,
        "currentImpactDamages": report.currentImpactDamages,
        "estimatedTotalDamages": report.estimatedTotalDamages,
        "suspectedSpeciesID": report.suspectedSpeciesID,
        "userSelectedLocation": report.userSelectedLocation?.toJson(),
        "systemLocation": report.systemLocation?.toJson(),
        "userSelectedDateTime": report.userSelectedDateTime?.toIso8601String(),
        "systemDateTime": report.systemDateTime.toIso8601String(),
      })}',
    );

    // --- validation before sending ---
    if (report.systemLocation == null && report.userSelectedLocation == null) {
      throw StateError('At least one location (system or user-selected) is required for damage report');
    }
    
    if (report.userSelectedLocation == null) {
      throw StateError('User-selected location is required for damage report');
    }
    if (report.impactedAreaType.isEmpty) {
      throw StateError('impactType is required');
    }
    if (report.impactedArea == 0) {
      throw StateError('impactValue must be > 0');
    }

    final belongingName = report.possesion.possesionName ?? '';

    if (belongingName.trim().isEmpty) {
      throw StateError('belonging name is required');
    }

    // --- final payload exactly how /interaction expects it for R5 ---
    final payload = <String, dynamic>{
      "location": {
        "latitude": report.systemLocation!.latitude,
        "longitude": report.systemLocation!.longtitude,
      },
      "moment": report.systemDateTime.toUtc().toIso8601String(),
      "place": {
        "latitude": report.userSelectedLocation!.latitude,
        "longitude": report.userSelectedLocation!.longtitude,
      },
      "reportOfDamage": buildReportOfDamageJson(
        belonging: belongingName,
        estimatedLoss: report.estimatedTotalDamages.toString(),
        preventiveMeasures: report.preventiveMeasures,
        preventiveMeasuresDescription: report.preventiveMeasuresDescription,
        estimatedDamage: report.currentImpactDamages.round(),
        impactType: report.impactedAreaType,
        impactValue: report.impactedArea.round(),
      ),
      "speciesID": report.suspectedSpeciesID,
      "typeID": 2,
    };
    applyInteractionNotes(payload, report.description);

    debugPrint('=== Final DamageReport API Payload ===');
    debugPrint(const JsonEncoder.withIndent('  ').convert(payload));
    debugPrint('======================================');

    return payload;
  }
}
