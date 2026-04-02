import 'package:wildlifenl_assets/wildlifenl_assets.dart';

/// Resolve species icon path with a few backend-name aliases.
/// This keeps UI robust when backend uses scientific/latin names.
String? getSpeciesIconPath(String? speciesName) {
  if (speciesName == null || speciesName.trim().isEmpty) return null;

  final raw = speciesName.trim();
  final normalized = raw.toLowerCase();

  final aliases = <String, List<String>>{
    'taurus': ['bos taurus', 'koe', 'rund', 'rundvee'],
    'bos taurus': ['taurus', 'koe', 'rund', 'rundvee'],
  };

  final candidates = <String>[raw];
  final extra = aliases[normalized];
  if (extra != null) candidates.addAll(extra);

  for (final candidate in candidates) {
    final path = getAnimalIconPath(candidate);
    if (path != null) return path;
  }
  return null;
}
