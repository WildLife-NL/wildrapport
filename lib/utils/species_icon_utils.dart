import 'package:flutter/foundation.dart';
import 'package:wildlifenl_assets/wildlifenl_assets.dart';

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

  final aliases = <String, List<String>>{
    'taurus': ['tauros', 'bos taurus', 'koe', 'rund', 'rundvee'],
    'tauros': ['taurus', 'bos taurus', 'koe', 'rund', 'rundvee'],
    'bos taurus': ['tauros', 'taurus', 'koe', 'rund', 'rundvee'],
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

  final normalized = speciesName
      .trim()
      .toLowerCase()
      .replaceAll(' ', '_');

  final path = 'assets/images/color-animals/$normalized.png';

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