import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';

/// Species linked to a zone (from `zones/me/` → `species`).
class ZoneSpeciesRef {
  const ZoneSpeciesRef({required this.id, required this.commonName});

  final String id;
  final String commonName;
}

/// Zones plus species per zone id from a `zones/me/` response.
class ZonesWithSpecies {
  const ZonesWithSpecies({
    required this.zones,
    required this.speciesByZoneId,
  });

  final List<Zone> zones;
  final Map<String, List<ZoneSpeciesRef>> speciesByZoneId;
}

List<ZoneSpeciesRef> zoneSpeciesFromJson(Map<String, dynamic> json) {
  final raw = json['species'];
  if (raw is! List) return [];
  final species = <ZoneSpeciesRef>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final id = _firstNonEmptyString(map, const ['ID', 'id']) ?? '';
    final name =
        _firstNonEmptyString(map, const ['commonName', 'name']) ?? '';
    if (id.isEmpty && name.isEmpty) continue;
    species.add(ZoneSpeciesRef(id: id, commonName: name));
  }
  return species;
}

ZonesWithSpecies loadZonesWithSpeciesFromApi(
  List<dynamic> list,
  String? currentUserId,
) {
  final zones = <Zone>[];
  final speciesByZoneId = <String, List<ZoneSpeciesRef>>{};
  final userId = currentUserId?.trim();
  final filterByOwner = userId != null && userId.isNotEmpty;

  for (final item in list) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    if (filterByOwner) {
      final ownerId = zoneOwnerUserIdFromJson(map);
      if (ownerId != null &&
          ownerId.isNotEmpty &&
          ownerId != userId) {
        continue;
      }
    }
    final zone = zoneFromApiJson(map);
    if (zone == null) continue;
    zones.add(zone);
    speciesByZoneId[zone.id] = zoneSpeciesFromJson(map);
  }
  return ZonesWithSpecies(zones: zones, speciesByZoneId: speciesByZoneId);
}

/// Parses zone JSON from the Wildlife API without strict casts that fail on nulls.
Zone? zoneFromApiJson(Map<String, dynamic> json) {
  final id = _firstNonEmptyString(json, const ['ID', 'id']);
  if (id == null) return null;

  return Zone(
    id: id,
    created: _firstNonEmptyString(json, const ['created']) ?? '',
    deactivated: _optionalString(json['deactivated']),
    definition: _parseDefinition(json['definition']),
    description: _firstNonEmptyString(json, const ['description']) ?? '',
    name: _firstNonEmptyString(json, const ['name']) ?? 'Zone',
  );
}

List<Zone> zonesFromApiList(List<dynamic> list) =>
    zonesFromApiListForUser(list, null);

/// Only includes zones owned by [currentUserId] when the API provides an owner id.
List<Zone> zonesFromApiListForUser(
  List<dynamic> list,
  String? currentUserId,
) {
  final zones = <Zone>[];
  final userId = currentUserId?.trim();
  final filterByOwner = userId != null && userId.isNotEmpty;

  for (final item in list) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    if (filterByOwner) {
      final ownerId = zoneOwnerUserIdFromJson(map);
      if (ownerId != null &&
          ownerId.isNotEmpty &&
          ownerId != userId) {
        continue;
      }
    }
    final zone = zoneFromApiJson(map);
    if (zone != null) zones.add(zone);
  }
  return zones;
}

/// Reads owner/profile id from zone JSON when the API includes it.
String? zoneOwnerUserIdFromJson(Map<String, dynamic> json) {
  for (final key in const [
    'userID',
    'userId',
    'profileID',
    'profileId',
    'ownerID',
    'ownerId',
    'createdBy',
  ]) {
    final id = _optionalString(json[key]);
    if (id != null) return id;
  }
  for (final key in const ['profile', 'user', 'owner']) {
    final nested = json[key];
    if (nested is Map) {
      final map = Map<String, dynamic>.from(nested);
      final id = _firstNonEmptyString(map, const ['ID', 'id', 'userID']);
      if (id != null) return id;
    }
  }
  return null;
}

String? _firstNonEmptyString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

List<ZoneDefinitionPoint>? _parseDefinition(dynamic raw) {
  if (raw is! List) return null;
  final points = <ZoneDefinitionPoint>[];
  for (final item in raw) {
    if (item is! Map) continue;
    final map = Map<String, dynamic>.from(item);
    final lat = _asDouble(map['latitude']);
    final lon = _asDouble(map['longitude']);
    if (lat == null || lon == null) continue;
    points.add(ZoneDefinitionPoint(latitude: lat, longitude: lon));
  }
  return points.isEmpty ? null : points;
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().trim());
}
