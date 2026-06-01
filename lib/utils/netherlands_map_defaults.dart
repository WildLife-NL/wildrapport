import 'package:latlong2/latlong.dart';
import 'package:wildrapport/config/mock_location.dart';

/// Shared map camera defaults for the Netherlands.
abstract final class NetherlandsMapDefaults {
  static const LatLng center = LatLng(52.1326, 5.2913);
  static const double overviewZoom = 7.0;
  static const double detailZoom = 15.0;

  /// Historic dev mock / package default near Den Bosch — not a real user fix.
  static const double legacyMockLat = 52.088130;
  static const double legacyMockLon = 5.170465;

  static bool isLegacyDevMockCoordinate(double lat, double lon) {
    if (MockLocationConfig.kForceMockLocation) return false;
    const epsilon = 0.0002;
    return (lat - legacyMockLat).abs() < epsilon &&
        (lon - legacyMockLon).abs() < epsilon;
  }
}
