import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/models/enums/location_type.dart';

class MapProvider with ChangeNotifier {
  Position? selectedPosition;
  String selectedAddress = '';
  Position? currentPosition;
  String currentAddress = '';
  MapController? _mapController;
  bool _isLoading = false;
  
  bool get isLoading => _isLoading;
  bool get isInitialized => _mapController != null;
  MapController get mapController {
    if (_mapController == null) {
      debugPrint('[MapProvider] Warning: Accessing uninitialized map controller, creating new instance');
      _mapController = MapController();
    }
    return _mapController!;
  }

  Future<void> initialize() async {
    if (_mapController != null) {
      debugPrint('[MapProvider] Map controller already initialized, skipping');
      return;
    }

    try {
      debugPrint('[MapProvider] Starting map controller initialization');
      _isLoading = true;
      notifyListeners();

      _mapController = MapController();
      await Future.delayed(const Duration(milliseconds: 100));

      debugPrint('[MapProvider] Map controller initialized successfully');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[MapProvider] Error initializing map controller: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to initialize map controller: $e');
    }
  }

  void setMapController(MapController controller) {
    debugPrint('[MapProvider] Setting new map controller');
    _mapController?.dispose();
    _mapController = controller;
    notifyListeners();
  }

  void dispose() {
    debugPrint('[MapProvider] Disposing map controller');
    _mapController?.dispose();
    _mapController = null;
    super.dispose();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> updatePosition(Position position, String address) async {
    currentPosition = position;
    currentAddress = address;
    
    // Only update selected position if it's not explicitly set to unknown
    if (selectedAddress != LocationType.unknown.displayText) {
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
    selectedAddress = LocationType.unknown.displayText;
    // Don't clear current position/address
    notifyListeners();
    setLoading(false);
  }
}










