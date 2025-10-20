import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/managers/api_managers/interaction_query_manager.dart';

class MapProvider extends ChangeNotifier {
  // === Existing location state ===
  Position? selectedPosition;
  String selectedAddress = '';
  Position? currentPosition;
  String currentAddress = '';
  MapController? _mapController;
  bool _isLoading = false;
  final bool _isDisposed = false;

  bool get isLoading => _isLoading;
  bool get isInitialized => _mapController != null;
  MapController get mapController {
    if (_mapController == null) {
      debugPrint(
        '[MapProvider] Warning: Accessing uninitialized map controller, creating new instance',
      );
      _mapController = MapController();
    }
    return _mapController!;
  }

  // === NEW: interactions state (R8) ===
  final List<InteractionQueryResult> _interactions = [];
  bool _interactionsLoading = false;
  String? _interactionsError;

  List<InteractionQueryResult> get interactions => List.unmodifiable(_interactions);
  bool get interactionsLoading => _interactionsLoading;
  String? get interactionsError => _interactionsError;
  bool get hasInteractions => _interactions.isNotEmpty;

  // We inject the manager via a setter to avoid breaking existing DI.
  InteractionQueryManager? _interactionsManager;
  void setInteractionsManager(InteractionQueryManager manager) {
    _interactionsManager = manager;
  }

  // === Existing methods ===
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
    selectedPosition = null;
    selectedAddress = '';
    await Future.delayed(const Duration(milliseconds: 50));
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

    await Future.delayed(const Duration(milliseconds: 50));

    _isLoading = false;
    notifyListeners();
  }


  /// Load interactions (others' reports) for a given center + radius.
  Future<void> loadInteractions({
    required double lat,
    required double lon,
    required int radiusMeters,
    DateTime? after,
    DateTime? before,
  }) async {
    if (_interactionsManager == null) {
      debugPrint('[MapProvider] InteractionsManager not set. Call setInteractionsManager() first.');
      return;
    }

    // UI flags
    _interactionsLoading = true;
    _interactionsError = null;
    _interactions.clear();  
    notifyListeners();

    try {
      final clamped = radiusMeters.clamp(250, 20000);
      final results = await _interactionsManager!.loadNearby(
        lat: lat,
        lon: lon,
        radiusMeters: clamped,
        after: after,
        before: before,
      );

      _interactions
        ..clear()
        ..addAll(results);

      _interactionsLoading = false;
      _interactionsError = null;
      notifyListeners();
    } catch (e) {
      _interactionsLoading = false;
      _interactionsError = e.toString();
      notifyListeners();
    }
  }

  /// Clear currently loaded interactions
  void clearInteractions() {
    _interactions.clear();
    _interactionsError = null;
    _interactionsLoading = false;
    notifyListeners();
  }
}
