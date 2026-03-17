import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/config/mock_location.dart';
import 'package:wildlifenl_map_logic_components/wildlifenl_map_logic_components.dart';

class LocationMapManager extends NetherlandsMapManager {
  LocationMapManager()
      : super(
          defaultCenter: LatLng(
            MockLocationConfig.kMockLat,
            MockLocationConfig.kMockLon,
          ),
        );

  static const LatLng denBoschCenter = LatLng(
    MockLocationConfig.kMockLat,
    MockLocationConfig.kMockLon,
  );

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
