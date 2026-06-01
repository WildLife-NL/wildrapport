import 'package:flutter/foundation.dart';
import 'package:wildrapport/managers/waarneming_flow/animal_manager.dart';
import 'package:wildlifenl_assets/wildlifenl_assets.dart' hide getAnimalPhotoPath;

const _packageSilhouettes =
    'packages/wildlifenl_assets/assets/icons/animals';

/// Backend / package naming mismatches for map silhouettes.
String _normalizeSpeciesIconLookup(String raw) {
  final lower = raw.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  const aliases = <String, String>{
    'wilde kat': 'wild kat',
    'wildkat': 'wild kat',
    'shetland-pony': 'shetlandpony',
    'shetland pony': 'shetlandpony',
  };
  return aliases[lower] ?? lower;
}

/// Correct package silhouette paths where [getAnimalIconPath] points to missing files.
String? _explicitPackageSilhouettePath(String normalized) {
  if (normalized.contains('boommarter') || normalized.contains('boommarten')) {
    return '$_packageSilhouettes/boommarter.png';
  }
  if (normalized.contains('bever') || normalized.contains('beaver')) {
    return '$_packageSilhouettes/bever.png';
  }
  if (normalized.contains('shetland')) {
    return '$_packageSilhouettes/shetlandpony.png';
  }
  if (normalized.contains('exmoor')) {
    return '$_packageSilhouettes/exmoorpony.png';
  }
  if (normalized.contains('wild kat') || normalized.contains('wildkat')) {
    return '$_packageSilhouettes/wild_kat.png';
  }
  return null;
}

/// ===============================
/// MAP ICONS (silhouette icons)
/// ===============================
String? getSpeciesIconPath(String? speciesName) {
  if (speciesName == null || speciesName.trim().isEmpty) return null;

  final raw = speciesName.trim();
  final normalized = _normalizeSpeciesIconLookup(raw);

  final explicitSilhouette = _explicitPackageSilhouettePath(normalized);
  if (explicitSilhouette != null) {
    _logSpeciesIconResolution(speciesName, explicitSilhouette);
    return explicitSilhouette;
  }

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