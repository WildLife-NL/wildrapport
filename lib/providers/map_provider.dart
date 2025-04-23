import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';

class MapProvider with ChangeNotifier {
  MapController? _mapController;
  bool _isInitialized = false;
  Position? currentPosition;
  String currentAddress = "Loading...";
  
  MapController get mapController {
    _mapController ??= MapController();
    return _mapController!;
  }

  bool get isInitialized => _isInitialized;

  void initialize() {
    if (!_isInitialized) {
      _mapController = MapController();
      _isInitialized = true;
      notifyListeners();
    }
  }

  void updatePosition(Position position, String address) {
    currentPosition = position;
    currentAddress = address;
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}