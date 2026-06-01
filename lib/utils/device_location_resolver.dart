import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/config/mock_location.dart';
import 'package:wildrapport/utils/netherlands_map_defaults.dart';

/// Resolves the device GPS position without falling back to dev mock coordinates.
abstract final class DeviceLocationResolver {
  static Future<Position?> tryResolve({
    bool requestPermissionIfDenied = false,
    bool rejectLegacyMockCoordinates = true,
  }) async {
    if (MockLocationConfig.kForceMockLocation) {
      return _mockPosition();
    }

    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (!requestPermissionIfDenied) return null;
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    Position? position;
    try {
      position = await Geolocator.getLastKnownPosition();
      if (position != null && _reject(position, rejectLegacyMockCoordinates)) {
        position = null;
      }
    } catch (_) {}

    if (position != null) return position;

    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        return null;
      }
    }

    if (position != null && _reject(position, rejectLegacyMockCoordinates)) {
      return null;
    }
    return position;
  }

  static bool _reject(Position position, bool rejectLegacyMockCoordinates) {
    if (!rejectLegacyMockCoordinates) return false;
    return NetherlandsMapDefaults.isLegacyDevMockCoordinate(
      position.latitude,
      position.longitude,
    );
  }

  static Position _mockPosition() {
    return Position(
      latitude: MockLocationConfig.kMockLat,
      longitude: MockLocationConfig.kMockLon,
      timestamp: DateTime.now(),
      accuracy: 3,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }
}
