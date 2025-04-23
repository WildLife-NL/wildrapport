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
  Position? selectedPosition;
  String currentAddress = "Loading...";
  String selectedAddress = "";
  
  MapController get mapController {
    _mapController ??= MapController();
    return _mapController!;
  }

  bool get isInitialized => _isInitialized;

  Position? get displayPosition => selectedPosition ?? currentPosition;
  String get displayAddress => selectedPosition != null ? selectedAddress : currentAddress;

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

  void setSelectedLocation(Position position, String address) {
    selectedPosition = position;
    selectedAddress = address;
    notifyListeners();
  }

  void clearSelectedLocation() {
    selectedPosition = null;
    selectedAddress = "";
    notifyListeners();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
