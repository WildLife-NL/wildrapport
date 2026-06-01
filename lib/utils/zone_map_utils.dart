import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/models/beta_models/polygon_area_model.dart';
import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';

List<LatLng> zoneDefinitionToPoints(Zone zone) {
  final def = zone.definition;
  if (def == null || def.isEmpty) return [];
  return def.map((p) => LatLng(p.latitude, p.longitude)).toList();
}

LatLng? centroidOfPoints(List<LatLng> points) {
  if (points.isEmpty) return null;
  var lat = 0.0;
  var lon = 0.0;
  for (final p in points) {
    lat += p.latitude;
    lon += p.longitude;
  }
  return LatLng(lat / points.length, lon / points.length);
}

fm.LatLngBounds? boundsForPoints(Iterable<LatLng> points) {
  final list = points.toList();
  if (list.isEmpty) return null;
  var minLat = list.first.latitude;
  var maxLat = list.first.latitude;
  var minLon = list.first.longitude;
  var maxLon = list.first.longitude;
  for (final p in list) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLon) minLon = p.longitude;
    if (p.longitude > maxLon) maxLon = p.longitude;
  }
  return fm.LatLngBounds(LatLng(minLat, minLon), LatLng(maxLat, maxLon));
}

bool isActiveZone(Zone zone) => zone.deactivated == null;

bool zoneHasDrawablePolygon(Zone zone) {
  if (!isActiveZone(zone)) return false;
  final def = zone.definition;
  return def != null && def.length >= 3;
}

double zoneAreaSquareMeters(Zone zone) {
  final points = zoneDefinitionToPoints(zone);
  if (points.length < 3) return 0;
  return PolygonArea(points: points).calculateAreaInSquareMeters();
}

String formatZoneArea(Zone zone) {
  final m2 = zoneAreaSquareMeters(zone);
  if (m2 <= 0) return '—';
  if (m2 < 10_000) return '${m2.round()} m²';
  return '${(m2 / 10_000).toStringAsFixed(1)} ha';
}

String formatSpeciesCount(int count) {
  if (count <= 0) return 'Geen dieren';
  if (count == 1) return '1 dier';
  return '$count dieren';
}
