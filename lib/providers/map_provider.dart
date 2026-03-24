import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

// R8
import 'package:wildrapport/models/api_models/interaction_query_result.dart';

// R7
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/detection_pin.dart';

import 'package:wildrapport/interfaces/data_apis/tracking_api_interface.dart'
    show TrackingApiInterface, TrackingNotice;
import 'package:wildrapport/managers/api_managers/tracking_cache_manager.dart';
import 'package:wildrapport/interfaces/data_apis/vicinity_api_interface.dart';
import 'package:wildrapport/utils/notification_service.dart';
import 'dart:async';
import 'package:wildrapport/managers/map/location_map_manager.dart';

class MapProvider extends ChangeNotifier {
  TrackingApiInterface? _trackingApi;
  TrackingCacheManager? _trackingCacheManager;
  // ===== Location state =====
  Position? selectedPosition;
  String selectedAddress = '';
  Position? currentPosition;
  String currentAddress = '';
  MapController? _mapController;
  bool _isLoading = false;
  final bool _isDisposed = false;

  Timer? _trackingTimer;
  bool _isTracking = false;
  Duration _trackingInterval = const Duration(minutes: 2);

  bool get isTracking => _isTracking;
  Duration get trackingInterval => _trackingInterval;

  bool get isLoading => _isLoading;
  bool get isInitialized => _mapController != null;

  TrackingNotice? _lastTrackingNotice;
  TrackingNotice? get lastTrackingNotice => _lastTrackingNotice;
  Position? _lastSentTrackingPosition;
  static const double _minTrackingMovementMeters = 1.0;

  MapController get mapController {
    if (_mapController == null) {
      debugPrint(
        '[MapProvider] Warning: accessing uninitialized map controller, creating new instance',
      );
      _mapController = MapController();
    }
    return _mapController!;
  }

  void setTrackingApi(TrackingApiInterface api) {
    _trackingApi = api;
  }

  void setTrackingCacheManager(TrackingCacheManager manager) {
    _trackingCacheManager = manager;
  }

  Future<TrackingNotice?> sendTrackingPingFromPosition(Position pos) async {
    if (_lastSentTrackingPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastSentTrackingPosition!.latitude,
        _lastSentTrackingPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );
      if (distance < _minTrackingMovementMeters) {
        debugPrint(
          '[MapProvider] ⏭️ Tracking ping skipped (same location, ${distance.toStringAsFixed(2)}m)',
        );
        return null;
      }
    }

    // Prefer using the cache manager if available
    if (_trackingCacheManager != null) {
      debugPrint(
        '[MapProvider] 📍 Sending tracking ping via cache manager: ${pos.latitude}, ${pos.longitude}',
      );

      try {
        final notice = await _trackingCacheManager!.sendOrCacheReading(
          lat: pos.latitude,
          lon: pos.longitude,
          timestampUtc: DateTime.now().toUtc(),
        );

        if (notice != null) {
          _lastTrackingNotice = notice;
          debugPrint(
            '[MapProvider] 🔔 Got tracking notice, calling notifyListeners()',
          );
          // Also show an OS-level notification on supported platforms
          final title =
              notice.severity == 1
                  ? 'Waarschuwing'
                  : (notice.severity == 2 ? 'Melding' : 'Informatie');
          NotificationService.instance.show(title: title, body: notice.text);
          notifyListeners(); // if any UI wants to react to changes
          debugPrint(
            '[MapProvider] ✓ tracking-reading OK; notice="${notice.text}"'
            ' sev=${notice.severity ?? '-'}',
          );
        } else {
          debugPrint(
            '[MapProvider] ✓ tracking-reading cached or sent; no notice from backend',
          );
        }
        _lastSentTrackingPosition = pos;
        return notice;
      } catch (e) {
        debugPrint('[MapProvider] ❌ tracking-reading failed: $e');
        return null;
      }
    }

    // Fallback to direct API call if cache manager not available
    if (_trackingApi == null) {
      debugPrint(
        '[MapProvider] ⚠️ TrackingApi not set - cannot send tracking ping',
      );
      return null;
    }

    debugPrint(
      '[MapProvider] 📍 Sending tracking ping for position: ${pos.latitude}, ${pos.longitude}',
    );

    try {
      final notice = await _trackingApi!.addTrackingReading(
        lat: pos.latitude,
        lon: pos.longitude,
        timestampUtc: DateTime.now().toUtc(),
      );

      if (notice != null) {
        _lastTrackingNotice = notice;
        debugPrint(
          '[MapProvider] 🔔 Got tracking notice, calling notifyListeners()',
        );
        // Also show an OS-level notification on supported platforms
        final title =
            notice.severity == 1
                ? 'Waarschuwing'
                : (notice.severity == 2 ? 'Melding' : 'Informatie');
        NotificationService.instance.show(title: title, body: notice.text);
        notifyListeners(); // if any UI wants to react to changes
        debugPrint(
          '[MapProvider] ✓ tracking-reading OK; notice="${notice.text}"'
          ' sev=${notice.severity ?? '-'}',
        );
      } else {
        debugPrint(
          '[MapProvider] ✓ tracking-reading OK; no notice from backend',
        );
      }
      _lastSentTrackingPosition = pos;
      return notice;
    } catch (e) {
      debugPrint('[MapProvider] ❌ tracking-reading failed: $e');
      return null;
    }
  }

  void emitMockTrackingNotice(String text, {int? severity}) {
    _lastTrackingNotice = TrackingNotice(text, severity: severity);
    final title =
        severity == 1 ? 'Waarschuwing' : (severity == 2 ? 'Melding' : 'Informatie');
    NotificationService.instance.show(title: title, body: text);
    notifyListeners();
  }

  // ===== R7: Animals & Detections =====
  final List<AnimalPin> _animalPins = [];
  final List<DetectionPin> _detectionPins = [];

  bool _animalPinsLoading = false;
  bool _detectionPinsLoading = false;

  String? _animalPinsError;
  String? _detectionPinsError;

  VicinityApiInterface? _vicinityApi;

  void setVicinityApi(VicinityApiInterface api) {
    _vicinityApi = api;
  }

  List<AnimalPin> get animalPins => List.unmodifiable(_animalPins);
  List<DetectionPin> get detectionPins => List.unmodifiable(_detectionPins);

  bool get animalPinsLoading => _animalPinsLoading;
  bool get detectionPinsLoading => _detectionPinsLoading;

  String? get animalPinsError => _animalPinsError;
  String? get detectionPinsError => _detectionPinsError;

  // ===== R8: Interactions =====
  final List<InteractionQueryResult> _interactions = [];
  bool _interactionsLoading = false;
  String? _interactionsError;
  Set<String> _prevInteractionIds = {};
  Set<String> _prevAnimalIds = {};
  Set<String> _prevDetectionIds = {};
  bool _vicinityNotificationsEnabled = true;

  List<InteractionQueryResult> get interactions =>
      List.unmodifiable(_interactions);
  bool get interactionsLoading => _interactionsLoading;
  String? get interactionsError => _interactionsError;
  bool get hasInteractions => _interactions.isNotEmpty;

  int get totalPins =>
      _animalPins.length + _detectionPins.length + _interactions.length;

  void setVicinityNotificationsEnabled(bool enabled) {
    _vicinityNotificationsEnabled = enabled;
  }

  // ===== Lifecycle / base map helpers =====
  Future<void> initialize() async {
    if (_mapController != null) {
      debugPrint('[MapProvider] Map controller already initialized, skipping');
      return;
    }
    _mapController = MapController();
    notifyListeners();
  }

  void setMapController(MapController controller) {
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
      if (!_isDisposed) notifyListeners();
    });
  }

  Future<void> updatePosition(Position position, String address) async {
    if (_isDisposed) return;
    currentPosition = position;
    currentAddress = address;

    if (selectedAddress.isNotEmpty) {
      selectedPosition = position;
      selectedAddress = address;
    }

    setLoading(false);
    if (!_isDisposed) notifyListeners();
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
    _isLoading = true;
    notifyListeners();

    selectedPosition = null;
    selectedAddress = '';
    currentPosition = null;
    currentAddress = '';

    // clear pins & errors
    _animalPins.clear();
    _detectionPins.clear();
    _interactions.clear();
    _animalPinsError = null;
    _detectionPinsError = null;
    _interactionsError = null;
    _animalPinsLoading = false;
    _detectionPinsLoading = false;
    _interactionsLoading = false;

    await Future.delayed(const Duration(milliseconds: 50));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAllPinsFromVicinity() async {
    if (_vicinityApi == null) {
      debugPrint(
        '[MapProvider] ⚠️ VicinityApi not set - falling back to individual calls',
      );
      return;
    }

    debugPrint('[MapProvider] 📍 Loading all pins from vicinity endpoint');

    try {
      _animalPinsLoading = true;
      _detectionPinsLoading = true;
      _interactionsLoading = true;
      _animalPinsError = null;
      _detectionPinsError = null;
      _interactionsError = null;
      notifyListeners();

      final vicinity = await _vicinityApi!.getMyVicinity();

      _animalPins
        ..clear()
        ..addAll(vicinity.animals);
      _detectionPins
        ..clear()
        ..addAll(vicinity.detections);
      _interactions
        ..clear()
        ..addAll(vicinity.interactions);

      _animalPinsLoading = false;
      _detectionPinsLoading = false;
      _interactionsLoading = false;

      debugPrint(
        '[MapProvider] ✓ Vicinity loaded: '
        '${_animalPins.length} animals, '
        '${_detectionPins.length} detections, '
        '${_interactions.length} interactions',
      );

      notifyListeners();

      // Notify on newly seen animals to surface phone notifications
      try {
        final currentAnimalIds = _animalPins.map((a) => a.id).toSet();
        final newAnimalIds = currentAnimalIds.difference(_prevAnimalIds);
        if (_vicinityNotificationsEnabled && newAnimalIds.isNotEmpty) {
          final count = newAnimalIds.length;
          final sample = _animalPins.firstWhere(
            (a) => newAnimalIds.contains(a.id),
            orElse: () => _animalPins.isNotEmpty
                ? _animalPins.first
                : AnimalPin(
                    id: 'sample',
                    lat: 0,
                    lon: 0,
                    seenAt: DateTime.now().toUtc(),
                  ),
          );
          final species = sample.speciesName ?? 'Dier';
          final title = count == 1
              ? 'Nieuw dier in de buurt'
              : '$count nieuwe dieren in de buurt';
          final body = count == 1 ? species : 'Bijv. $species en meer';
          NotificationService.instance.show(title: title, body: body);
        }
        _prevAnimalIds = currentAnimalIds;
      } catch (e) {
        debugPrint('[MapProvider] Animal notification skipped: $e');
      }

      // Notify on newly seen detections to surface phone notifications
      try {
        final currentDetIds = _detectionPins.map((d) => d.id).toSet();
        final newDetIds = currentDetIds.difference(_prevDetectionIds);
        if (_vicinityNotificationsEnabled && newDetIds.isNotEmpty) {
          final count = newDetIds.length;
          final sample = _detectionPins.firstWhere(
            (d) => newDetIds.contains(d.id),
            orElse: () => _detectionPins.isNotEmpty
                ? _detectionPins.first
                : DetectionPin(
                    id: 'sample',
                    lat: 0,
                    lon: 0,
                    detectedAt: DateTime.now().toUtc(),
                  ),
          );
          final label = sample.label ?? sample.deviceType ?? 'Detectie';
          final title = count == 1
              ? 'Nieuwe detectie in de buurt'
              : '$count nieuwe detecties in de buurt';
          final body = count == 1 ? label : 'Bijv. $label en meer';
          NotificationService.instance.show(title: title, body: body);
        }
        _prevDetectionIds = currentDetIds;
      } catch (e) {
        debugPrint('[MapProvider] Detection notification skipped: $e');
      }

      // Notify on newly seen interactions to surface phone notifications
      try {
        final currentIds = _interactions.map((i) => i.id).toSet();
        final newIds = currentIds.difference(_prevInteractionIds);
        if (_vicinityNotificationsEnabled && newIds.isNotEmpty) {
          final count = newIds.length;
          // Build a concise message
          final sample = _interactions.firstWhere(
            (i) => newIds.contains(i.id),
            orElse: () => _interactions.isNotEmpty
                ? _interactions.first
                : InteractionQueryResult(
                    id: 'sample',
                    lat: 0,
                    lon: 0,
                    moment: DateTime.now().toUtc(),
                  ),
          );
          final species = sample.speciesName ?? 'Dier';
          final title = count == 1
              ? 'Nieuwe interactie in de buurt'
              : '$count nieuwe interacties in de buurt';
          final body = count == 1
              ? 'Interactie gezien: $species'
              : 'Bijv. $species en meer';
          NotificationService.instance.show(title: title, body: body);
        }
        _prevInteractionIds = currentIds;
      } catch (e) {
        debugPrint('[MapProvider] Interaction notification skipped: $e');
      }
    } catch (e) {
      debugPrint('[MapProvider] ❌ Vicinity load failed: $e');
      _animalPinsError = e.toString();
      _detectionPinsError = e.toString();
      _interactionsError = e.toString();
      _animalPinsLoading = false;
      _detectionPinsLoading = false;
      _interactionsLoading = false;
      notifyListeners();
    }
  }

  void setMockVicinity({
    List<AnimalPin> animals = const [],
    List<DetectionPin> detections = const [],
    List<InteractionQueryResult> interactions = const [],
  }) {
    _animalPins
      ..clear()
      ..addAll(animals);
    _detectionPins
      ..clear()
      ..addAll(detections);
    _interactions
      ..clear()
      ..addAll(interactions);

    _animalPinsError = null;
    _detectionPinsError = null;
    _interactionsError = null;
    _animalPinsLoading = false;
    _detectionPinsLoading = false;
    _interactionsLoading = false;

    notifyListeners();
  }

  Future<void> _sendTrackingNow() async {
    try {
      // Prefer currentPosition; otherwise get a fresh GPS fix
      Position pos;
      if (currentPosition != null) {
        pos = currentPosition!;
      } else {
        pos = (await LocationMapManager().determinePosition()) ??
            await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.medium,
                timeLimit: Duration(seconds: 7),
              ),
            );
      }
      await sendTrackingPingFromPosition(pos);
    } catch (e) {
      debugPrint('[MapProvider] tracking ping skipped: $e');
    }
  }

  void startTracking({Duration? interval}) {
    if (_trackingCacheManager == null && _trackingApi == null) {
      debugPrint(
        '[MapProvider] Cannot start tracking: Neither TrackingCacheManager nor TrackingApi is set',
      );
      return;
    }
    _trackingTimer?.cancel();
    _trackingInterval = interval ?? _trackingInterval;

    _isTracking = true;
    notifyListeners();

    // fire now, then periodically
    _sendTrackingNow();
    _trackingTimer = Timer.periodic(
      _trackingInterval,
      (_) => _sendTrackingNow(),
    );

    debugPrint(
      '[MapProvider] tracking STARTED every ${_trackingInterval.inSeconds}s',
    );
  }

  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    if (_isTracking) {
      _isTracking = false;
    }
    debugPrint('[MapProvider] tracking STOPPED');
  }

  void clearUserLocationAndStopTracking() {
    stopTracking();
    currentPosition = null;
    currentAddress = '';
    selectedPosition = null;
    selectedAddress = '';
    _lastSentTrackingPosition = null;
    _trackingCacheManager?.clearCache();
    notifyListeners();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    super.dispose();
  }
}
