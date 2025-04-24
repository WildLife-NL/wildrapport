import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';

class MapProvider with ChangeNotifier {
  Position? selectedPosition;
  String selectedAddress = '';
  Position? currentPosition;
  String currentAddress = '';
  late final MapController _mapController;
  bool isInitialized = false;
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;

  MapController get mapController => _mapController;

  void initialize() {
    if (!isInitialized) {
      _mapController = MapController();
      isInitialized = true;
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> updatePosition(Position position, String address) async {
    currentPosition = position;
    currentAddress = address;
    
    // If no location is selected, use current position as selected
    if (selectedPosition == null) {
      selectedPosition = position;
      selectedAddress = address;
    }
    
    setLoading(false);
    notifyListeners();
  }

  void setSelectedLocation(Position position, String address) {
    selectedPosition = position;
    selectedAddress = address;
    notifyListeners();
  }

  Future<void> clearSelectedLocation() async {
    setLoading(true);
    selectedPosition = null;
    selectedAddress = '';
    notifyListeners();
  }
}


