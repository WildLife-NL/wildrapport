import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/models/enums/location_type.dart';

class MapProvider extends ChangeNotifier {
  Position? selectedPosition;
  String selectedAddress = '';
  Position? currentPosition;
  String currentAddress = '';
  MapController? _mapController;
  bool _isLoading = false;
  bool _isDisposed = false;
  
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
    if (_mapController != null && _mapController != controller) {
      _mapController?.dispose();
    }
    _mapController = controller;
    notifyListeners();
  }

  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    // Notify on next frame
    Future.microtask(() {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  Future<void> updatePosition(Position position, String address) async {
    if (_isDisposed) return;
    
    currentPosition = position;
    currentAddress = address;
    
    // Only update selected position if it's not explicitly set to unknown
    if (selectedAddress != LocationType.unknown.displayText) {
      selectedPosition = position;
      selectedAddress = address;
    }
    
    // Batch state updates
    Future.microtask(() {
      if (!_isDisposed) {
        setLoading(false);
        notifyListeners();
      }
    });
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

  Future<void> resetToCurrentLocation(Position position, String address) async {
    setLoading(true);
    // Clear selected location first
    selectedPosition = null;
    selectedAddress = '';
    // Small delay to ensure UI updates
    await Future.delayed(const Duration(milliseconds: 50));
    // Set new position
    selectedPosition = position;
    selectedAddress = address;
    currentPosition = position;
    currentAddress = address;
    setLoading(false);
    notifyListeners();
  }

  Future<void> resetState() async {
    setLoading(true);
    selectedPosition = null;
    selectedAddress = '';
    currentPosition = null;
    currentAddress = '';
    notifyListeners();
    setLoading(false);
  }

  Future<void> resetMapState() async {
    debugPrint('[MapProvider] Resetting map state');
    _isLoading = true;
    notifyListeners();
    
    // Reset any state but keep the controller
    selectedPosition = null;
    selectedAddress = '';
    currentPosition = null;
    currentAddress = '';
    
    // Small delay to ensure UI updates
    await Future.delayed(const Duration(milliseconds: 50));
    
    _isLoading = false;
    notifyListeners();
  }
}

















