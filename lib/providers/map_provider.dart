import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';

class MapProvider extends ChangeNotifier {
  Position? selectedPosition;
  String selectedAddress = '';
  Position? currentPosition;
  String currentAddress = '';
  late final MapController _mapController;
  bool isInitialized = false;

  MapController get mapController => _mapController;

  void initialize() {
    if (!isInitialized) {
      _mapController = MapController();
      isInitialized = true;
      notifyListeners();
    }
  }

  void updatePosition(Position position, String address) {
    currentPosition = position;
    currentAddress = address;
    
    // If no location is selected, use current position as selected
    if (selectedPosition == null) {
      selectedPosition = position;
      selectedAddress = address;
    }
    
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
}

