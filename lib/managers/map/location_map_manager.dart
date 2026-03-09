import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/config/mock_location.dart';
import 'package:wildlifenl_map_logic_components/wildlifenl_map_logic_components.dart';

/// App-specifieke kaartmanager: gebruikt [NetherlandsMapManager] met mock-locatie
/// wanneer [MockLocationConfig.kForceMockLocation] aan staat.
class LocationMapManager extends NetherlandsMapManager {
  LocationMapManager()
      : super(
          defaultCenter: LatLng(
            MockLocationConfig.kMockLat,
            MockLocationConfig.kMockLon,
          ),
        );

  /// Default centrum (mock of NL); gebruikt in kaart-overview en elders.
  static const LatLng denBoschCenter = LatLng(
    MockLocationConfig.kMockLat,
    MockLocationConfig.kMockLon,
  );

  /// Satellietlaag-URL (van package); kaarttiles komen uit [WildLifeNLMap].
  static const String satelliteTileUrl = MapStateInterface.satelliteTileUrl;

  @override
  Future<Position?> determinePosition() async {
    if (MockLocationConfig.kForceMockLocation) {
      return Position(
        latitude: MockLocationConfig.kMockLat,
        longitude: MockLocationConfig.kMockLon,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }
    return super.determinePosition();
  }
}
