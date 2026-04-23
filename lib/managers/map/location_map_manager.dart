import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildlifenl_map_logic_components/wildlifenl_map_logic_components.dart';

class LocationMapManager extends NetherlandsMapManager {
  static const double _defaultLat = 52.088130;
  static const double _defaultLon = 5.170465;

  LocationMapManager()
      : super(
          defaultCenter: LatLng(
            _defaultLat,
            _defaultLon,
          ),
        );

  static const LatLng denBoschCenter = LatLng(
    _defaultLat,
    _defaultLon,
  );

  static const String satelliteTileUrl = MapStateInterface.satelliteTileUrl;

  @override
  Future<Position?> determinePosition() async {
    return super.determinePosition();
  }
}
