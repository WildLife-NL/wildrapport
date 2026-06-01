import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/utils/device_location_resolver.dart';
import 'package:wildrapport/utils/netherlands_map_defaults.dart';
import 'package:wildlifenl_map_logic_components/wildlifenl_map_logic_components.dart';

class LocationMapManager extends NetherlandsMapManager {
  LocationMapManager()
      : super(defaultCenter: NetherlandsMapDefaults.center);

  /// @deprecated Use [NetherlandsMapDefaults.center].
  static const LatLng denBoschCenter = NetherlandsMapDefaults.center;

  static const String satelliteTileUrl = MapStateInterface.satelliteTileUrl;

  @override
  Future<Position?> determinePosition() {
    return DeviceLocationResolver.tryResolve(
      requestPermissionIfDenied: false,
      rejectLegacyMockCoordinates: true,
    );
  }
}
