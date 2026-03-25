import 'dart:math' as math;
import 'package:wildrapport/interfaces/data_apis/interaction_query_api_interface.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';

class InteractionQueryManager {
  final InteractionQueryApiInterface api;

  InteractionQueryManager(this.api);

  Future<List<InteractionQueryResult>> loadNearby({
    required double lat,
    required double lon,
    int radiusMeters = 1500,
    DateTime? after,
    DateTime? before,
  }) async {
    final clampedRadius = radiusMeters.clamp(250, 20000);

    final nowUtc = DateTime.now().toUtc();
    final normalizedAfter =
        (after ?? nowUtc.subtract(const Duration(days: 365))).toUtc();
    final normalizedBefore = (before ?? nowUtc).toUtc();

    return api.queryInteractions(
      areaLatitude: lat,
      areaLongitude: lon,
      areaRadiusMeters: clampedRadius,
      momentAfter: normalizedAfter,
      momentBefore: normalizedBefore,
    );
  }

  int radiusFromZoom({
    required double zoom,
    required double lat,
    double widthPx = 400,
  }) {
    // Web Mercator meters-per-pixel at given latitude/zoom.
    final metersPerPixel =
        156543.03392 * math.cos(lat * math.pi / 180.0) / math.pow(2.0, zoom);
    final halfWidthMeters = (widthPx / 2.0) * metersPerPixel;
    final radius = halfWidthMeters.round();
    return radius.clamp(250, 20000);
  }
}
