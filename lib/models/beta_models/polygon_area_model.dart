import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

const Distance _distance = Distance();

class PolygonArea {
  final List<LatLng> points;
  final String areaType; // 'polygon', 'gps_recording', or 'radius'

  PolygonArea({
    required this.points,
    this.areaType = 'polygon',
  });

  /// Maakt een cirkel-polygoon rond [center] met [radiusMeters] (bijv. 100, 250, 500, 1000).
  static PolygonArea fromCircle(LatLng center, double radiusMeters) {
    const int segments = 32;
    const double metersPerDegreeLat = 111320.0;
    final double metersPerDegreeLon =
        111320.0 * math.cos(center.latitude * math.pi / 180);
    final List<LatLng> pts = [];
    for (int i = 0; i < segments; i++) {
      final angle = 2 * math.pi * i / segments;
      final dy = (radiusMeters / metersPerDegreeLat) * math.cos(angle);
      final dx = (radiusMeters / metersPerDegreeLon) * math.sin(angle);
      pts.add(LatLng(center.latitude + dy, center.longitude + dx));
    }
    return PolygonArea(points: pts, areaType: 'radius');
  }

  /// Berekent oppervlakte in m². Voor cirkels (areaType 'radius') wordt πr² gebruikt.
  double calculateAreaInSquareMeters() {
    if (points.length < 3) return 0.0;

    if (areaType == 'radius') {
      final center = getCenterPoint();
      final radiusMeters = _distance.distance(center, points[0]);
      return math.pi * radiusMeters * radiusMeters;
    }

    double area = 0.0;
    for (int i = 0; i < points.length; i++) {
      final LatLng p1 = points[i];
      final LatLng p2 = points[(i + 1) % points.length];
      area += (p2.longitude - p1.longitude) * (p2.latitude + p1.latitude);
    }
    area = (area.abs() / 2);
    const double metersPerDegree = 111320.0;
    return area * metersPerDegree * metersPerDegree;
  }

  /// Calculate area in hectares
  double getAreaInHectares() {
    return calculateAreaInSquareMeters() / 10000;
  }

  /// Get center point of polygon
  LatLng getCenterPoint() {
    if (points.isEmpty) {
      return const LatLng(0, 0);
    }
    
    double sumLat = 0;
    double sumLng = 0;
    
    for (final point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    
    return LatLng(
      sumLat / points.length,
      sumLng / points.length,
    );
  }

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => {
      'latitude': p.latitude,
      'longitude': p.longitude,
    }).toList(),
    'areaType': areaType,
    'areaSquareMeters': calculateAreaInSquareMeters(),
    'areaHectares': getAreaInHectares(),
  };

  factory PolygonArea.fromJson(Map<String, dynamic> json) => PolygonArea(
    points: (json['points'] as List)
        .map((p) => LatLng(p['latitude'] as double, p['longitude'] as double))
        .toList(),
    areaType: json['areaType'] ?? 'polygon',
  );
}
