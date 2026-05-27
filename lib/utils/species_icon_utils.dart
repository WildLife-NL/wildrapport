import 'package:flutter/foundation.dart';
import 'package:wildrapport/managers/waarneming_flow/animal_manager.dart';
import 'package:wildlifenl_assets/wildlifenl_assets.dart' hide getAnimalPhotoPath;

/// ===============================
/// MAP ICONS (silhouette icons)
/// ===============================
String? getSpeciesIconPath(String? speciesName) {
  if (speciesName == null || speciesName.trim().isEmpty) return null;

  final raw = speciesName.trim();
  final normalized = raw.toLowerCase();

  // Handle bovine/Tauros naming variants
  if (normalized.contains('tauros') ||
      normalized.contains('taurus') ||
      normalized.contains('bos taurus') ||
      normalized.contains('rund') ||
      normalized.contains('koe')) {
    final taurusPath = getAnimalIconPath('taurus');

    if (taurusPath != null) {
      _logSpeciesIconResolution(speciesName, taurusPath);
      return taurusPath;
    }

    final taurosPath = getAnimalIconPath('tauros');

    if (taurosPath != null) {
      _logSpeciesIconResolution(speciesName, taurosPath);
      return taurosPath;
    }
  }

  // wildlifenl_assets: getAnimalIconPath('boommarten') wijst naar een onbestaand
  // bestand; het silhouet heet boommarter.png.
  if (normalized.contains('boommarter')) {
    const packageIcon =
        'packages/wildlifenl_assets/assets/icons/animals/boommarter.png';
    _logSpeciesIconResolution(speciesName, packageIcon);
    return packageIcon;
  }

  final aliases = <String, List<String>>{
    'taurus': ['tauros', 'bos taurus', 'koe', 'rund', 'rundvee'],
    'tauros': ['taurus', 'bos taurus', 'koe', 'rund', 'rundvee'],
    'bos taurus': ['tauros', 'taurus', 'koe', 'rund', 'rundvee'],
    'steenmarter': ['steenmarter', 'steenmarten'],
    'steenmarten': ['steenmarter', 'steenmarten'],
  };

  final candidates = <String>[raw];

  final extra = aliases[normalized];

  if (extra != null) {
    candidates.addAll(extra);
  }

  for (final candidate in candidates) {
    final path = getAnimalIconPath(candidate);

    if (path != null) {
      _logSpeciesIconResolution(speciesName, path);
      return path;
    }
  }

  // Fallback: lokale kleuren-dierafbeelding (o.a. boommarter) i.p.v. poot-icoon
  final localPath = getAnimalPhotoPath(speciesName);
  if (localPath != null) {
    _logSpeciesIconResolution(speciesName, localPath);
    return localPath;
  }

  _logSpeciesIconResolution(speciesName, null);

  return null;
}

/// ===============================
/// CARD IMAGES (full color images)
/// ===============================
String? getSpeciesCardImagePath(String? speciesName) {
  if (speciesName == null || speciesName.trim().isEmpty) {
    return null;
  }
  final path = getAnimalPhotoPath(speciesName);
  _logSpeciesIconResolution(speciesName, path);
  return path;
}

void _logSpeciesIconResolution(
  String originalName,
  String? resolvedPath,
) {
  if (!kDebugMode) return;

  debugPrint(
    '[SpeciesIcon] "$originalName" -> ${resolvedPath ?? 'null'}',
  );
}