import 'package:wildrapport/managers/waarneming_flow/animal_manager.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/enums/report_type.dart';
import 'package:wildrapport/utils/interaction_type_display.dart';

bool hasSchademeldingIndicators(AnimalSightingModel sighting) {
  if (sighting.cropType != null && sighting.cropType!.trim().isNotEmpty) {
    return true;
  }
  if (sighting.expectedLoss != null &&
      sighting.expectedLoss!.trim().isNotEmpty) {
    return true;
  }
  if (sighting.preventiveMeasures != null) return true;
  if (sighting.preventiveMeasuresDescription != null &&
      sighting.preventiveMeasuresDescription!.trim().isNotEmpty) {
    return true;
  }
  return false;
}

bool hasCollisionIndicators(AnimalSightingModel sighting) {
  if (sighting.accidentSeverity != null &&
      sighting.accidentSeverity!.trim().isNotEmpty) {
    return true;
  }
  if (sighting.animalConditionDieraanrijding != null &&
      sighting.animalConditionDieraanrijding!.trim().isNotEmpty) {
    return true;
  }
  return false;
}

String reportTypeKeyFromAppReportType(ReportType? reportType) {
  switch (reportType) {
    case ReportType.gewasschade:
      return 'gewasschade';
    case ReportType.verkeersongeval:
      return 'verkeersongeval';
    case ReportType.waarneming:
    case null:
      return 'waarneming';
  }
}

/// Resolves type for display/storage. Structural fields win over a wrong `reportType`.
String effectiveReportTypeKey(AnimalSightingModel sighting) {
  if (hasSchademeldingIndicators(sighting)) return 'gewasschade';
  if (hasCollisionIndicators(sighting)) return 'verkeersongeval';

  final fromField = normalizeReportTypeKey(sighting.reportType);
  if (fromField == 'gewasschade') return 'gewasschade';
  if (fromField == 'verkeersongeval') return 'verkeersongeval';

  return 'waarneming';
}

/// Use when persisting a sighting right after submit (app flow type as fallback).
String resolveReportTypeForSave(
  AnimalSightingModel sighting, {
  ReportType? appReportType,
}) {
  final resolved = effectiveReportTypeKey(sighting);
  if (resolved != 'waarneming') return resolved;

  if (appReportType != null && appReportType != ReportType.waarneming) {
    return reportTypeKeyFromAppReportType(appReportType);
  }

  return 'waarneming';
}

String sightingTypeDisplayLabel(AnimalSightingModel sighting) {
  return reportTypeDisplayLabel(effectiveReportTypeKey(sighting));
}

/// Primary animal for list/detail (schademelding uses [animalSelected], waarneming often [animals]).
AnimalModel? primaryDisplayAnimal(AnimalSightingModel sighting) {
  if (sighting.animals != null && sighting.animals!.isNotEmpty) {
    return sighting.animals!.first;
  }
  return sighting.animalSelected;
}

String primaryDisplayAnimalName(AnimalSightingModel sighting) {
  final animal = primaryDisplayAnimal(sighting);
  final name = animal?.animalName.trim();
  if (name != null && name.isNotEmpty) return name;

  if (effectiveReportTypeKey(sighting) == 'gewasschade') {
    final crop = sighting.cropType?.trim();
    if (crop != null && crop.isNotEmpty) return crop;
    return 'Schade — dier onbekend';
  }

  return 'Dier';
}

String? primaryDisplayAnimalImagePath(AnimalSightingModel sighting) {
  final animal = primaryDisplayAnimal(sighting);
  final path = animal?.animalImagePath?.trim();
  if (path != null && path.isNotEmpty) return path;
  return getAnimalPhotoPath(animal?.animalName);
}

int primaryDisplayAnimalCount(AnimalSightingModel sighting) {
  if (sighting.animals != null && sighting.animals!.isNotEmpty) {
    return sighting.animals!.length;
  }
  if (sighting.animalCount != null && sighting.animalCount! > 0) {
    return sighting.animalCount!;
  }
  if (sighting.animalSelected != null) return 1;
  return 0;
}

/// Fills missing [reportType] / image paths when loading from local storage.
AnimalSightingModel normalizeStoredSighting(AnimalSightingModel sighting) {
  final reportType = effectiveReportTypeKey(sighting);
  final animal = primaryDisplayAnimal(sighting);

  AnimalModel? animalSelected = sighting.animalSelected;
  if (animal != null) {
    final imagePath =
        primaryDisplayAnimalImagePath(sighting) ?? animal.animalImagePath;
    final patched = animal.copyWith(animalImagePath: imagePath);
    if (animalSelected == null) {
      animalSelected = patched;
    } else if (animalSelected.animalId == patched.animalId) {
      animalSelected = patched;
    }
  }

  return sighting.copyWith(
    reportType: reportType,
    animalSelected: animalSelected,
  );
}
