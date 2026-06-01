import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/widgets/map/animal_detail_card.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/detection_pin.dart';
import 'package:wildrapport/models/animal_waarneming_models/interaction_to_animal_pin.dart';
import 'package:wildrapport/widgets/map/detection_detail_dialog.dart';
import 'package:wildrapport/data_managers/tracking_api.dart';
import 'package:wildrapport/interfaces/data_apis/tracking_api_interface.dart';
import 'package:wildrapport/config/app_config.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart'
    as cl;
import 'package:wildrapport/interfaces/other/permission_interface.dart';
import 'package:wildrapport/utils/species_icon_utils.dart';
import 'package:wildrapport/utils/location_sharing_dialog.dart';
import 'package:wildrapport/widgets/map/wildlifenl_map.dart';
class _IconStyle {
  final Color color;
  final double size;
  const _IconStyle(this.color, this.size);
}

class _LocalTrackingPoint {
  final LatLng point;
  final DateTime timestamp;
  const _LocalTrackingPoint({required this.point, required this.timestamp});
}

class KaartOverviewScreen extends StatefulWidget {
  const KaartOverviewScreen({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  State<KaartOverviewScreen> createState() => _KaartOverviewScreenState();
}

class _KaartOverviewScreenState extends State<KaartOverviewScreen>
    with TickerProviderStateMixin {
  fm.MapOptions? _mapOptions;
  final _location = LocationMapManager();

  bool _mapReady = false;
  LatLng? _pendingCenter;
  double? _pendingZoom;

  // cache things we must clean up
  late MapProvider _mp; // <— cached provider
  StreamSubscription<Position>? _posSub;
  VoidCallback? _mpListener;
  bool _listenerAttached = false;
  Timer? _debounce;
  String? _lastNoticeKey;

  double? _lastZoom;
  static const _debounceMs = 450;

  bool _useClusters = true;
  static const double _clusterUntilZoom = 17.0;

  static const double _initialZoom =
      15.0; // Zoom level for "Center on me" button
  static const double _netherlandsOverviewZoom = 7.0;
  static const LatLng _netherlandsCenter = LatLng(52.1326, 5.2913);
  bool _followUser = true;
  bool _hasLiveLocation = false;
  DateTime? _lastFollowMoveAt;
  static const _followMoveThrottleMs = 600;

  // Tracking history state
  bool _showTrackingHistory = false;
  List<TrackingReadingResponse> _trackingHistory = [];
  final List<_LocalTrackingPoint> _localTrackingHistory = [];
  bool _loadingTrackingHistory = false;
  int _trackingHistoryMinutes = 10; // Default: show last 10 minutes

  /// Break the trail when points are farther apart (avoids a line to an old start).
  static const double _trackingGapBreakMeters = 150;

  // Scale bar state
  double _scaleBarWidth = 80;
  String _scaleBarLabel = '100 m';

  // Selected animal for detail card
  AnimalPin? _selectedAnimal;
  bool _showLegend = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mp = context.read<MapProvider>();

    // Guard: ensure the map controller exists as early as possible to avoid a blank first render
    if (!_mp.isInitialized) {
      _mp.initialize();
    }

    // Only initialize once
    if (_mapOptions == null) {
      final trackingEnabled =
          context.read<AppStateProvider>().isLocationTrackingEnabled;
      _mapOptions = fm.MapOptions(
        initialCenter: LatLng(
          _mp.currentPosition?.latitude ??
              _netherlandsCenter.latitude,
          _mp.currentPosition?.longitude ??
              _netherlandsCenter.longitude,
        ),
        initialZoom:
            (trackingEnabled && _mp.currentPosition != null)
                ? _initialZoom
                : _netherlandsOverviewZoom,
        minZoom: 4.0,
        maxZoom: 17.0,
        onMapReady: () {
          debugPrint('[Map] ready');
          _mapReady = true;
          final app = context.read<AppStateProvider>();
          if (_pendingCenter == null || _pendingZoom == null) {
            final p = _mp.currentPosition ?? _mp.selectedPosition;
            if (app.isLocationTrackingEnabled && p != null) {
              _pendingCenter = LatLng(p.latitude, p.longitude);
              _pendingZoom = _initialZoom;
            } else {
              _pendingCenter = _netherlandsCenter;
              _pendingZoom = _netherlandsOverviewZoom;
            }
          }
          _applyPendingCamera();
          _updateScaleBar();
        },
        interactionOptions: const fm.InteractionOptions(
          flags:
              fm.InteractiveFlag.drag |
              fm.InteractiveFlag.pinchZoom |
              fm.InteractiveFlag.doubleTapZoom |
              fm.InteractiveFlag.scrollWheelZoom |
              fm.InteractiveFlag.flingAnimation |
              fm.InteractiveFlag.pinchMove,
          // Rotatie uit: kaart blijft noord-omhoog, zoals navigatie
        ),
        onMapEvent: (evt) {
          final mp = context.read<MapProvider>();
          final currentZoom = mp.mapController.camera.zoom;
          final isProgrammatic = evt.source == fm.MapEventSource.mapController;

          // Keep scale bar in sync for both user and programmatic zoom changes.
          if (_lastZoom != currentZoom) {
            _lastZoom = currentZoom;
            _updateScaleBar();
          }

          // Stop following only on user gestures
          if (!isProgrammatic &&
              (evt is fm.MapEventMoveStart || evt is fm.MapEventMove)) {
            if (_followUser) _followUser = false; // no setState needed
          }

          // Handle rotation changes - rebuild markers to counter-rotate
          if (evt is fm.MapEventRotate && mounted) {
            setState(() {}); // Rebuild to update marker rotations
          }

          // Handle zoom changes only for user gestures
          if (!isProgrammatic && _lastZoom != currentZoom) {
            _lastZoom = currentZoom;
            final next = currentZoom < _clusterUntilZoom;
            if (next != _useClusters && mounted) {
              setState(() => _useClusters = next);
            }
            // Recenter only if following AND tracking is enabled (still user-driven)
            final p = mp.currentPosition ?? mp.selectedPosition;
            final appStateProvider = context.read<AppStateProvider>();
            if (_followUser &&
                appStateProvider.isLocationTrackingEnabled &&
                p != null) {
              mp.mapController.move(
                LatLng(p.latitude, p.longitude),
                currentZoom,
              );
            }
          }

          if (!isProgrammatic && evt is fm.MapEventMoveEnd) {
            _updateScaleBar();
          }
        },
      );
    }

    _mpListener ??= () {
      debugPrint('[Kaart] 📨 Listener triggered');
      final n = _mp.lastTrackingNotice;

      if (n == null) {
        debugPrint('[Kaart] No tracking notice to show');
        return;
      }

      if (!mounted) {
        debugPrint('[Kaart] Widget not mounted, skipping notice');
        return;
      }

      debugPrint(
        '[Kaart] Received notice: "${n.text}" (severity: ${n.severity})',
      );

      // Dedup the same notice
      final key = '${n.text}|${n.severity ?? ''}';
      if (_lastNoticeKey == key) {
        debugPrint('[Kaart] Duplicate notice, skipping');
        return;
      }
      _lastNoticeKey = key;

      debugPrint('[Kaart] Scheduling popup dialog to show');
      // Do not show in-map popup dialogs; phone notifications are handled
      // via NotificationService in MapProvider. This listener now only logs.
      debugPrint('[Kaart] ℹ️ Map popup suppressed (phone notification only)');
    };

    if (!_listenerAttached) {
      debugPrint('[Kaart] 🔗 Attaching listener to MapProvider');
      _mp.addListener(_mpListener!);
      _listenerAttached = true;
    }
  }

  @override
  void initState() {
    super.initState();
    final bool isIosDebug = !kIsWeb && Platform.isIOS && kDebugMode;
    if (isIosDebug) {
      debugPrint('[Kaart] iOS debug: skipping bootstrap and live-follow startup');
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrap();
      _startFollowingMe();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _posSub?.cancel();
    if (_listenerAttached && _mpListener != null) {
      _mp.removeListener(_mpListener!);
    }
    _mp.stopTracking();
    super.dispose();
  }

  void _queueFetch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
      if (mounted) _fetchAllForView();
    });
  }

  /// Verticale kaartknoppen (tracking → mijn locatie).
  Widget _mapVerticalControlPill() {
    const bg = Color(0xFF2E2E2E);
    const dividerColor = Color(0x33FFFFFF);
    const size = 52.0;

    return Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Trackinggeschiedenis',
                onPressed: _loadingTrackingHistory
                    ? null
                    : () {
                        if (_showTrackingHistory) {
                          setState(() => _showTrackingHistory = false);
                        } else {
                          _loadTrackingHistory();
                        }
                      },
                icon:
                    _loadingTrackingHistory
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : Icon(
                          Icons.directions_walk,
                          color:
                              _showTrackingHistory
                                  ? Colors.lightBlueAccent
                                  : Colors.white,
                          size: 24,
                        ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: dividerColor),
            SizedBox(
              width: size,
              height: size,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Centreer op mijn locatie',
                onPressed: () => _centerOnMyLocation(),
                icon: const Icon(Icons.my_location, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
    );
  }

  Future<void> _centerOnMyLocation() async {
    final mp = context.read<MapProvider>();
    final appState = context.read<AppStateProvider>();
    debugPrint('[Map] centreer op locatie');

    if (!appState.isLocationTrackingEnabled) {
      final enable = await showLocationSharingOffDialog(context);
      if (!mounted) return;
      if (enable == true) {
        await appState.setLocationTrackingEnabled(true);
      } else {
        _followUser = false;
        mp.mapController.move(_netherlandsCenter, _netherlandsOverviewZoom);
        _updateScaleBar();
        return;
      }
    }

    _followUser = true;
    // Always zoom in to the configured "my location" zoom level.
    const targetZoom = _initialZoom;

    Position? target = mp.currentPosition ?? mp.selectedPosition;
    if (target == null) {
      target = await Geolocator.getLastKnownPosition();
    }

    if (target != null) {
      mp.mapController.move(
        LatLng(target.latitude, target.longitude),
        targetZoom,
      );
      _updateScaleBar();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Zoeken naar je locatie…'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
    }

    Future(() async {
      Position? fresh;
      try {
        fresh = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        ).timeout(const Duration(seconds: 2));
      } catch (_) {}

      fresh ??= target;
      if (fresh == null || !mounted) return;

      String address = mp.currentAddress;
      try {
        final a = await _location.getAddressFromPosition(fresh);
        if (a.trim().isNotEmpty) address = a;
      } catch (e) {
        debugPrint('[Map] Reverse geocoding failed: $e');
      }

      await mp.resetToCurrentLocation(fresh, address);

      final appStateProvider = context.read<AppStateProvider>();
      if (appStateProvider.isLocationTrackingEnabled) {
        await mp.sendTrackingPingFromPosition(fresh);
      }

      if (_followUser && appStateProvider.isLocationTrackingEnabled) {
        mp.mapController.move(
          LatLng(fresh.latitude, fresh.longitude),
          targetZoom,
        );
        _updateScaleBar();
      }
      _queueFetch();
    });
  }

  void _startFollowingMe() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0, // Update often when walking (like Google Maps)
    );

    final Stream<Position> stream =
        Geolocator.getPositionStream(locationSettings: settings);

    _posSub = stream.listen((pos) async {
      if (!mounted) return;
      _hasLiveLocation = true;

      // accuracy can be null on some platforms
      final double acc = pos.accuracy;
      final String accStr =
          (acc.isNaN || acc.isInfinite || acc <= 0)
              ? '?'
              : acc.toStringAsFixed(1);

      debugPrint(
        '[ME/live] ${pos.latitude.toStringAsFixed(6)}, '
        '${pos.longitude.toStringAsFixed(6)}  acc=$accStr m',
      );

      final now = DateTime.now();
      _localTrackingHistory.add(
        _LocalTrackingPoint(
          point: LatLng(pos.latitude, pos.longitude),
          timestamp: now,
        ),
      );
      final cutoff = now.subtract(const Duration(hours: 24));
      _localTrackingHistory.removeWhere((p) => p.timestamp.isBefore(cutoff));
      if (_localTrackingHistory.length > 4000) {
        _localTrackingHistory.removeRange(0, _localTrackingHistory.length - 4000);
      }

      // use cached provider, not context.read(...)
      await _mp.updatePosition(pos, _mp.currentAddress);

      // Tracking pings are sent every 5 min via MapProvider timer, not on every position update

      // Keep center on user when following and tracking is enabled; throttle camera moves for smooth follow
      if (_followUser &&
          _mp.isInitialized) {
        final now = DateTime.now();
        final allowed = _lastFollowMoveAt == null ||
            now.difference(_lastFollowMoveAt!).inMilliseconds >= _followMoveThrottleMs;
        if (allowed) {
          _lastFollowMoveAt = now;
          final z = _mp.mapController.camera.zoom;
          _mp.mapController.move(LatLng(pos.latitude, pos.longitude), z);
        }
      }
    }, onError: (Object e) {
      // Location sharing can be off or permission denied; map should still render.
      debugPrint('[ME/live] position stream error ignored: $e');
    });
  }

  List<({DateTime timestamp, LatLng point})> _trackingSamplesInWindow() {
    final threshold = DateTime.now().subtract(
      Duration(minutes: _trackingHistoryMinutes),
    );
    final samples = <({DateTime timestamp, LatLng point})>[];

    for (final entry in _localTrackingHistory) {
      if (entry.timestamp.isAfter(threshold)) {
        samples.add((timestamp: entry.timestamp, point: entry.point));
      }
    }
    for (final reading in _trackingHistory) {
      if (reading.timestamp.isAfter(threshold)) {
        samples.add((
          timestamp: reading.timestamp,
          point: LatLng(reading.latitude, reading.longitude),
        ));
      }
    }

    samples.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return samples;
  }

  List<LatLng> _visibleTrackingPoints() {
    return _trackingSamplesInWindow().map((s) => s.point).toList();
  }

  /// Chronological segments; large GPS jumps start a new piece (no line to old start).
  List<List<LatLng>> _trackingPathSegments() {
    final samples = _trackingSamplesInWindow();
    if (samples.isEmpty) return const [];
    if (samples.length == 1) return const [];

    final segments = <List<LatLng>>[];
    var current = <LatLng>[samples.first.point];
    const distance = Distance();

    for (var i = 1; i < samples.length; i++) {
      final prev = samples[i - 1].point;
      final next = samples[i].point;
      final gapMeters = distance(prev, next);
      if (gapMeters > _trackingGapBreakMeters) {
        if (current.length >= 2) {
          segments.add(List<LatLng>.from(current));
        }
        current = <LatLng>[next];
      } else {
        current.add(next);
      }
    }

    if (current.length >= 2) {
      segments.add(current);
    }
    return segments;
  }

  Future<void> _fetchAllForView() async {
    final map = context.read<MapProvider>();
    final app = context.read<AppStateProvider>();
    map.setVicinityNotificationsEnabled(
      app.isLocationTrackingEnabled && app.notificationsEnabled,
    );

    debugPrint('[Map] Fetching pins from latest tracking-reading');

    await map.loadAllPinsFromVicinity();

    debugPrint(
      '[Map] vicinity totals  animals=${map.animalPins.length} '
      'detections=${map.detectionPins.length} interactions=${map.interactions.length} '
      'total=${map.totalPins}',
    );

    // Log all animals with JSON output
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
    debugPrint('[ANIMALS] Total count: ${map.animalPins.length}');
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );

    for (int i = 0; i < map.animalPins.length; i++) {
      final animal = map.animalPins[i];
      try {
        final jsonOutput = jsonEncode({
          'index': i,
          'id': animal.id,
          'speciesName': animal.speciesName,
          'lat': animal.lat,
          'lon': animal.lon,
          'seenAt': animal.seenAt.toIso8601String(),
        });
        debugPrint('[ANIMAL $i] JSON: $jsonOutput');
      } catch (e) {
        debugPrint('[ANIMAL $i] Error serializing: $e');
        debugPrint(
          '[ANIMAL $i] Raw: id=${animal.id}, species=${animal.speciesName}, lat=${animal.lat}, lon=${animal.lon}, seenAt=${animal.seenAt}',
        );
      }
    }
    debugPrint(
      '═══════════════════════════════════════════════════════════════',
    );
  }

  Future<void> _bootstrap() async {
    final map = context.read<MapProvider>();
    final app = context.read<AppStateProvider>();
    map.setVicinityNotificationsEnabled(
      app.isLocationTrackingEnabled && app.notificationsEnabled,
    );
    final mgr = _location;

    await map.initialize();

    final permissionManager = context.read<PermissionInterface>();

    bool hasLocationPermission = false;
    hasLocationPermission =
        await permissionManager.isPermissionGranted(PermissionType.location);
    if (!hasLocationPermission) {
      hasLocationPermission = await permissionManager.requestPermission(
        context,
        PermissionType.location,
        showRationale: false,
      );
      if (hasLocationPermission) {
        await app.setLocationTrackingEnabled(true);
      }
    }
    if (!mounted) return;

    Position? pos;
    if (hasLocationPermission) {
      pos = app.isLocationCacheValid ? app.cachedPosition : null;
      pos ??= await mgr.determinePosition();
    }

    // Log what we got
    debugPrint('[Loc] raw=${pos?.latitude},${pos?.longitude}');

    final bool useUserLocation = hasLocationPermission && pos != null;

    if (pos == null ||
        !mgr.isLocationInNetherlands(pos.latitude, pos.longitude)) {
      pos = Position(
        latitude: _netherlandsCenter.latitude,
        longitude: _netherlandsCenter.longitude,
        timestamp: DateTime.now(),
        accuracy: 100,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
      debugPrint(
        '[Loc] using fallback center: '
        '${pos.latitude},${pos.longitude}',
      );
    }

    if (useUserLocation) {
      _hasLiveLocation = true;
      await map.resetToCurrentLocation(pos, 'Locatie gevonden');
    } else {
      _hasLiveLocation = false;
    }

    _pendingCenter = LatLng(pos.latitude, pos.longitude);
    _pendingZoom = useUserLocation ? _initialZoom : _netherlandsOverviewZoom;
    _applyPendingCamera();

    final appStateProvider = context.read<AppStateProvider>();
    if (appStateProvider.isLocationTrackingEnabled) {
      debugPrint('[Kaart/Bootstrap] 📡 Sending initial tracking ping');
      final initialNotice = await map.sendTrackingPingFromPosition(pos);
      if (initialNotice != null) {
        debugPrint(
          '[Kaart/Bootstrap] 🔔 Initial ping returned notice: "${initialNotice.text}"',
        );
      } else {
        debugPrint('[Kaart/Bootstrap] Initial ping returned no notice');
      }

      debugPrint(
        '[Kaart/Bootstrap] ⏰ Starting periodic tracking '
        '(every ${MapProvider.defaultTrackingInterval.inMinutes} min)',
      );
      map.startTracking(interval: MapProvider.defaultTrackingInterval);
    } else {
      debugPrint('[Kaart/Bootstrap] Location sharing disabled; local location use stays enabled');
      map.stopTracking();
    }

    // 5) Move camera & load data after first frame so the map is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _pendingCenter = LatLng(pos!.latitude, pos.longitude);
        _pendingZoom = useUserLocation ? _initialZoom : _netherlandsOverviewZoom;
        _applyPendingCamera();

        debugPrint('[Bootstrap] Loading data from vicinity endpoint');
        try {
          await map.loadAllPinsFromVicinity().timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('[Bootstrap] ⚠️ Vicinity API timeout after 15s');
              // Continue anyway - map will show without pins
              return;
            },
          );
        } catch (e) {
          debugPrint('[Bootstrap] ❌ Failed to load vicinity data: $e');
          // Continue anyway - map will show without pins
        }

        debugPrint(
          '[Map] initial totals  '
          'animals=${map.animalPins.length} '
          'detections=${map.detectionPins.length} '
          'interactions=${map.interactions.length} '
          'total=${map.totalPins}',
        );

        // Log all animals with JSON output
        debugPrint(
          '═══════════════════════════════════════════════════════════════',
        );
        debugPrint('[BOOTSTRAP ANIMALS] Total count: ${map.animalPins.length}');
        debugPrint(
          '═══════════════════════════════════════════════════════════════',
        );

        for (int i = 0; i < map.animalPins.length; i++) {
          final animal = map.animalPins[i];
          try {
            final jsonOutput = jsonEncode({
              'index': i,
              'id': animal.id,
              'speciesName': animal.speciesName,
              'lat': animal.lat,
              'lon': animal.lon,
              'seenAt': animal.seenAt.toIso8601String(),
            });
            debugPrint('[BOOTSTRAP ANIMAL $i] JSON: $jsonOutput');
          } catch (e) {
            debugPrint('[BOOTSTRAP ANIMAL $i] Error serializing: $e');
            debugPrint(
              '[BOOTSTRAP ANIMAL $i] Raw: id=${animal.id}, species=${animal.speciesName}, lat=${animal.lat}, lon=${animal.lon}, seenAt=${animal.seenAt}',
            );
          }
        }
        debugPrint(
          '═══════════════════════════════════════════════════════════════',
        );
      } catch (_) {}
    });

    // 6) Reverse-geocode address (don’t block UI)
    if (useUserLocation) {
      try {
        final address = await mgr.getAddressFromPosition(pos);
        if (!mounted) return;
        map.setSelectedLocation(pos, address);
      } catch (e) {
        debugPrint('[Kaart] Reverse geocoding failed: $e');
      }
    }
  }

  Future<void> _loadTrackingHistory() async {
    if (_loadingTrackingHistory) return;

    setState(() {
      _loadingTrackingHistory = true;
    });

    try {
      final trackingApi = TrackingApi(AppConfig.shared.apiClient);

      final readings = await trackingApi.getMyTrackingReadings().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout after 10 seconds');
        },
      );

      if (!mounted) return;

      if (readings.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen tracking gegevens beschikbaar'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _loadingTrackingHistory = false);
        return;
      }

      // CRITICAL DIAGNOSTIC: Show timestamp range in database
      final sorted = List<TrackingReadingResponse>.from(readings);
      sorted.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final oldest = sorted.first.timestamp;
      final newest = sorted.last.timestamp;
      final now = DateTime.now();

      debugPrint('[TRACKING] 🔴 CRITICAL DATA:');
      debugPrint('[TRACKING] Now: ${now.toIso8601String()}');
      debugPrint(
        '[TRACKING] Newest in DB: ${newest.toIso8601String()} (${now.difference(newest).inSeconds}s ago)',
      );
      debugPrint(
        '[TRACKING] Oldest in DB: ${oldest.toIso8601String()} (${now.difference(oldest).inSeconds}s ago)',
      );
      debugPrint('[TRACKING] Total readings: ${readings.length}');

      // Filter to configurable time window
      final threshold = now.subtract(
        Duration(minutes: _trackingHistoryMinutes),
      );

      final filteredReadings =
          readings.where((r) => r.timestamp.isAfter(threshold)).toList();

      // IMPORTANT: If no recent data found, also filter out OLD junk data (>24h old)
      // This handles stale test data in the database
      if (filteredReadings.isEmpty && readings.isNotEmpty) {
        final oneDayAgo = now.subtract(const Duration(days: 1));
        final recentOnlyReadings =
            readings.where((r) => r.timestamp.isAfter(oneDayAgo)).toList();

        if (recentOnlyReadings.isNotEmpty) {
          debugPrint(
            '[TRACKING] No data in 5min window, but found ${recentOnlyReadings.length} readings from last 24h',
          );
          recentOnlyReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          setState(() {
            _trackingHistory = recentOnlyReadings;
            _showTrackingHistory = true;
            _loadingTrackingHistory = false;
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${recentOnlyReadings.length} locaties van laatste 24 uur (geen recente in 5min)',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      filteredReadings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      setState(() {
        _trackingHistory = filteredReadings;
        _showTrackingHistory = true;
        _loadingTrackingHistory = false;
      });

      // Show success message
      if (!mounted) return;

      String message;
      if (filteredReadings.isEmpty) {
        // Show data from last 24 hours as fallback
        final oneDayAgo = now.subtract(const Duration(days: 1));
        final recentOnlyReadings =
            readings.where((r) => r.timestamp.isAfter(oneDayAgo)).toList();

        if (recentOnlyReadings.isNotEmpty) {
          message =
              '${recentOnlyReadings.length} locaties van vandaag (geen pingen in ${_trackingHistoryMinutes} min)';
        } else {
          message =
              'Geen locaties in laatste ${_trackingHistoryMinutes} minuten';
        }
      } else {
        message =
            '${filteredReadings.length} locaties van laatste ${_trackingHistoryMinutes} minuten';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _loadingTrackingHistory = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verzoek timeout - probeer opnieuw'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingTrackingHistory = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _clusterBadge({
    required IconData icon,
    required int count,
    required Color color,
    required double mapRotation,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    double size;
    double iconSize;
    double badgeFontSize;
    double badgePadH;
    double badgePadV;
    double badgeOffset;
    if (screenWidth < 400) {
      size = 30;
      iconSize = 16;
      badgeFontSize = 9;
      badgePadH = 4;
      badgePadV = 1.5;
      badgeOffset = -4;
    } else if (screenWidth < 700) {
      size = 36;
      iconSize = 19;
      badgeFontSize = 11;
      badgePadH = 5;
      badgePadV = 2;
      badgeOffset = -5;
    } else {
      size = 42;
      iconSize = 22;
      badgeFontSize = 12;
      badgePadH = 6;
      badgePadV = 2;
      badgeOffset = -6;
    }
    return Transform.rotate(
      angle: -mapRotation * math.pi / 180,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.95),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 6,
                  spreadRadius: 1,
                  offset: Offset(0, 2),
                  color: Colors.black26,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: iconSize, color: Colors.white),
          ),
          Positioned(
            right: badgeOffset,
            top: badgeOffset,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: badgePadH,
                vertical: badgePadV,
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: badgeFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vicinity on tracking readings: backend returns recent pins (~48h).
  /// Client filter must not suggest a longer range.
  static const Duration _vicinityPinMaxAge = Duration(hours: 48);

  bool _withinVicinityPinWindow(DateTime timestamp) {
    return DateTime.now().difference(timestamp) < _vicinityPinMaxAge;
  }

  void _updateScaleBar() {
    if (!_mp.isInitialized) return;

    final center = _mp.mapController.camera.center;
    final zoom = _mp.mapController.camera.zoom;

    const earthCircumference = 40075016.686; // meters
    final metersPerPixel =
        math.cos(center.latitude * math.pi / 180) *
        earthCircumference /
        (256 * math.pow(2, zoom));

    // Schalen van 5 m t/m 500 km zodat de schaal altijd klopt (ook na 100 km uitzoomen)
    const candidates = [
      5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000,
      20000, 50000, 100000, 200000, 500000,
    ];

    const minWidthPx = 50.0;
    const maxWidthPx = 200.0;
    const idealMin = 60.0;
    const idealMax = 160.0;

    double chosenMeters = candidates.first.toDouble();
    double chosenWidth = chosenMeters / metersPerPixel;

    // Eerst: voorkeur voor breedte in ideaal bereik (60–160 px)
    for (final m in candidates) {
      final widthPx = m / metersPerPixel;
      if (widthPx >= idealMin && widthPx <= idealMax) {
        chosenMeters = m.toDouble();
        chosenWidth = widthPx;
        break;
      }
    }

    // Geen ideale match: kies grootste schaal die nog binnen maxWidthPx past (juiste label bij ver uitzoomen)
    if (chosenMeters == 5) {
      for (var i = candidates.length - 1; i >= 0; i--) {
        final m = candidates[i];
        final widthPx = m / metersPerPixel;
        if (widthPx >= minWidthPx && widthPx <= maxWidthPx) {
          chosenMeters = m.toDouble();
          chosenWidth = widthPx;
          break;
        }
        if (widthPx < minWidthPx) {
          chosenMeters = m.toDouble();
          chosenWidth = widthPx.clamp(minWidthPx, maxWidthPx);
          break;
        }
      }
    }

    final label =
        chosenMeters >= 1000
            ? '${(chosenMeters / 1000).toStringAsFixed(chosenMeters >= 100000 ? 0 : (chosenMeters % 1000 == 0 ? 0 : 1))}km'
            : '${chosenMeters.toInt()}m';

    if ((chosenWidth - _scaleBarWidth).abs() > 0.5 || _scaleBarLabel != label) {
      setState(() {
        _scaleBarWidth = chosenWidth.clamp(40, 200);
        _scaleBarLabel = label;
      });
    }
  }

  void _applyPendingCamera() {
    if (!_mapReady || _pendingCenter == null || _pendingZoom == null) return;
    try {
      _mp.mapController.move(_pendingCenter!, _pendingZoom!);
      _nudgeMapToTriggerTiles();
    } catch (e) {
      debugPrint('[Map] Failed to apply pending camera: $e');
    }
  }

  // Some devices delay tile requests until the first manual interaction; tiny nudge forces tiles to start loading immediately
  void _nudgeMapToTriggerTiles() {
    if (!_mp.isInitialized) return;
    final cam = _mp.mapController.camera;
    final LatLng c = cam.center;
    const double delta = 0.000001; // ~0.1 m, invisible but triggers refresh
    try {
      _mp.mapController.move(
        LatLng(c.latitude + delta, c.longitude + delta),
        cam.zoom,
      );
      _mp.mapController.move(c, cam.zoom);
    } catch (e) {
      debugPrint('[Map] Nudge failed: $e');
    }
  }

   @override
  Widget build(BuildContext context) {
    final map = context.watch<MapProvider>();
    final pos = map.selectedPosition ?? map.currentPosition;
    const locationSharingOn = true;
    final visibleTrackingPoints = _visibleTrackingPoints();
    final trackingPathSegments = _trackingPathSegments();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (widget.onBackPressed != null) {
          widget.onBackPressed!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.read<NavigationStateInterface>().pushReplacementBack(
                context,
                const MainNavScreen(),
              );
        }
      },
      child: Scaffold(
        body: _mapOptions == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Stack(
                    children: [
                      WildLifeNLMap(
                        mapController: map.mapController,
                        options: _mapOptions!,
                        userAgentPackageName: 'nl.wildlife.rapport',
                        tileKeepBuffer: 1,
                        extraLayers: [
                          if (locationSharingOn)
                            _useClusters
                                ? cl.MarkerClusterLayerWidget(
                                  options: cl.MarkerClusterLayerOptions(
                                    markers:
                                        map.animalPins
                                            .where(
                                              (pin) =>
                                                  _withinVicinityPinWindow(pin.seenAt),
                                            )
                                            .map((pin) {
                                              final mapRotation =
                                                  map
                                                      .mapController
                                                      .camera
                                                      .rotation;
                                              return fm.Marker(
                                                point: LatLng(pin.lat, pin.lon),
                                                width: 64,
                                                height: 64,
                                                rotate: false,
                                                child: _animalPinMarkerContent(
                                                  pin,
                                                  mapRotation,
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedAnimal = pin;
                                                    });
                                                  },
                                                ),
                                              );
                                            })
                                            .toList(),
                                    maxClusterRadius: 60,
                                    disableClusteringAtZoom: 99,
                                    padding: const EdgeInsets.all(40),
                                    maxZoom: 17.0,
                                    polygonOptions: const cl.PolygonOptions(
                                      borderColor: Colors.transparent,
                                    ),
                                    zoomToBoundsOnClick: true,
                                    markerChildBehavior: true,
                                    builder:
                                        (context, markers) => _clusterBadge(
                                          icon: Icons.pets,
                                          count: markers.length,
                                          color: AppColors.primaryGreen,
                                          mapRotation:
                                              map.mapController.camera.rotation,
                                        ),
                                  ),
                                )
                                : fm.MarkerLayer(
                                  markers:
                                      map.animalPins
                                          .where(
                                            (pin) =>
                                                _withinVicinityPinWindow(
                                                  pin.seenAt,
                                                ),
                                          )
                                          .map((pin) {
                                            final mapRotation =
                                                map
                                                    .mapController
                                                    .camera
                                                    .rotation;
                                            return fm.Marker(
                                              point: LatLng(pin.lat, pin.lon),
                                              width: 64,
                                              height: 64,
                                              rotate: false,
                                              child: _animalPinMarkerContent(
                                                pin,
                                                mapRotation,
                                                onTap: () {
                                                  setState(() {
                                                    _selectedAnimal = pin;
                                                  });
                                                },
                                              ),
                                            );
                                          })
                                          .toList(),
                                ),

                            // ── DETECTIONS ────────────────────────────────────────────────────────────
                            if (locationSharingOn)
                              _useClusters
                                ? cl.MarkerClusterLayerWidget(
                                  options: cl.MarkerClusterLayerOptions(
                                    markers:
                                        map.detectionPins.map((pin) {
                                              final style =
                                                  _iconStyleForTimestamp(
                                                    pin.detectedAt,
                                                  );
                                              final mapRotation =
                                                  map
                                                      .mapController
                                                      .camera
                                                      .rotation;

                                              return fm.Marker(
                                                point: LatLng(pin.lat, pin.lon),
                                                width: (style.size + 8).clamp(
                                                  24.0,
                                                  44.0,
                                                ),
                                                height: (style.size + 8).clamp(
                                                  24.0,
                                                  44.0,
                                                ),
                                                rotate: false,
                                                child: _detectionPinMarker(
                                                  pin: pin,
                                                  mapRotation: mapRotation,
                                                  style: style,
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          DetectionDetailDialog(
                                                            detection: pin,
                                                          ),
                                                    );
                                                  },
                                                ),
                                              );
                                            })
                                            .toList(),
                                    maxClusterRadius: 60,
                                    disableClusteringAtZoom: 99,
                                    padding: const EdgeInsets.all(40),
                                    maxZoom: 17.0,
                                    polygonOptions: const cl.PolygonOptions(
                                      borderColor: Colors.transparent,
                                    ),
                                    zoomToBoundsOnClick: true,
                                    markerChildBehavior: true,
                                    builder:
                                        (context, markers) => _clusterBadge(
                                          icon: Icons.sensors,
                                          count: markers.length,
                                          color: AppColors.primaryGreen,
                                          mapRotation:
                                              map.mapController.camera.rotation,
                                        ),
                                  ),
                                )
                                : fm.MarkerLayer(
                                  markers:
                                      map.detectionPins.map((pin) {
                                            final style =
                                                _iconStyleForTimestamp(
                                                  pin.detectedAt,
                                                );
                                            final mapRotation =
                                                map
                                                    .mapController
                                                    .camera
                                                    .rotation;

                                            return fm.Marker(
                                              point: LatLng(pin.lat, pin.lon),
                                              width: (style.size + 8).clamp(
                                                24.0,
                                                44.0,
                                              ),
                                              height: (style.size + 8).clamp(
                                                24.0,
                                                44.0,
                                              ),
                                              rotate: false,
                                              child: _detectionPinMarker(
                                                pin: pin,
                                                mapRotation: mapRotation,
                                                style: style,
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        DetectionDetailDialog(
                                                          detection: pin,
                                                        ),
                                                  );
                                                },
                                              ),
                                            );
                                          })
                                          .toList(),
                                ),

                            // ── CURRENT POSITION ─────────────────────────────────────────────────────
                            // Show user location pin when local location is available
                            if (_hasLiveLocation)
                              Builder(
                                builder: (context) {
                                  return fm.MarkerLayer(
                                    markers: pos != null
                                        ? [
                                            fm.Marker(
                                              point: LatLng(
                                                pos.latitude,
                                                pos.longitude,
                                              ),
                                              width: 28,
                                              height: 28,
                                              rotate: false,
                                              child: Center(
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue.withValues(
                                                      alpha: 0.25,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.blue,
                                                        border: Border.fromBorderSide(
                                                          BorderSide(
                                                            color: Colors.white,
                                                            width: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            ]
                                        : [],
                                  );
                                },
                              ),

                          if (_showTrackingHistory &&
                              trackingPathSegments.isNotEmpty)
                            fm.PolylineLayer(
                              polylines: trackingPathSegments
                                  .map(
                                    (segment) => fm.Polyline(
                                      points: segment,
                                      color: Colors.blue.withValues(alpha: 0.6),
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                  .toList(),
                            ),

                          if (_showTrackingHistory &&
                              visibleTrackingPoints.isNotEmpty)
                            fm.CircleLayer(
                              circles: visibleTrackingPoints.map((point) {
                                return fm.CircleMarker(
                                  point: point,
                                  radius: 4,
                                  color: Colors.blue.withValues(alpha: 0.8),
                                  borderColor: Colors.white,
                                  borderStrokeWidth: 1,
                                  useRadiusInMeter: false,
                                );
                              }).toList(),
                            ),

                          if (locationSharingOn)
                            _useClusters
                                ? cl.MarkerClusterLayerWidget(
                                  options: cl.MarkerClusterLayerOptions(
                                    markers:
                                        map.interactions
                                            .where(
                                              (itx) => _withinVicinityPinWindow(
                                                itx.moment,
                                              ),
                                            )
                                            .map((itx) {
                                              final mapRotation =
                                                  map
                                                      .mapController
                                                      .camera
                                                      .rotation;
                                              return fm.Marker(
                                                point: LatLng(itx.lat, itx.lon),
                                                width: 56,
                                                height: 56,
                                                rotate: false,
                                                child: Transform.rotate(
                                                  angle:
                                                      -mapRotation *
                                                      math.pi /
                                                      180,
                                                  child: GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedAnimal =
                                                            itx.toAnimalPin();
                                                      });
                                                    },
                                                    child: Builder(
                                                      builder: (ctx) {
                                                        final style =
                                                            _iconStyleForTimestamp(
                                                              itx.moment,
                                                            );
                                                        return _buildStyledAnimalPin(
                                                          itx.speciesName,
                                                          itx.typeName,
                                                          style,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              );
                                            })
                                            .toList(),
                                    builder:
                                        (context, markers) => _clusterBadge(
                                          icon: Icons.place,
                                          count: markers.length,
                                          color: AppColors.primaryGreen,
                                          mapRotation:
                                              map.mapController.camera.rotation,
                                        ),
                                  ),
                                )
                                : fm.MarkerLayer(
                                  markers: map.interactions
                                      .where(
                                        (itx) =>
                                            _withinVicinityPinWindow(itx.moment),
                                      )
                                      .map((itx) {
                                        final mapRotation =
                                            map.mapController.camera.rotation;
                                        return fm.Marker(
                                          point: LatLng(itx.lat, itx.lon),
                                          width: 56,
                                          height: 56,
                                          rotate: false,
                                          child: Transform.rotate(
                                            angle: -mapRotation * math.pi / 180,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                setState(() {
                                                  _selectedAnimal = itx.toAnimalPin();
                                                });
                                              },
                                              child: Builder(
                                                builder: (ctx) {
                                                  final style =
                                                      _iconStyleForTimestamp(itx.moment);
                                                  return _buildStyledAnimalPin(
                                                    itx.speciesName,
                                                    itx.typeName,
                                                    style,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                          ],
                        ),

                      Positioned(
                        left: 12,
                        bottom: 44,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _scaleBarLabel,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: _scaleBarWidth,
                                height: 3,
                                child: const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(1.5),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        right: 14,
                        bottom: 44,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showLegend = !_showLegend;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222222),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showLegend ? Icons.close : Icons.help_outline,
                                  size: 19,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Legenda',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      if (_showLegend)
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              setState(() => _showLegend = false);
                            },
                            child: const SizedBox.expand(),
                          ),
                        ),

                      if (_showLegend)
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 110,
                          child: Material(
                            color: Colors.transparent,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _legendRow(
                                    const Color(0xFF8613A8),
                                    'Waarneming',
                                  ),
                                  _legendRow(
                                    const Color(0xFF00BFD8),
                                    'Cameraval',
                                    icon: Icons.camera_alt,
                                  ),
                                  _legendRow(
                                    const Color(0xFFFF9100),
                                    'Akoestische sensor',
                                    icon: Icons.graphic_eq,
                                  ),
                                  _legendRow(
                                    const Color(0xFFFE008E),
                                    'Diergedragen sensor',
                                    badgeIcon: Icons.settings_remote,
                                  ),
                                  _legendRow(
                                    const Color(0xFF0078DA),
                                    'Dieraanrijding',
                                  ),
                                  _legendRow(
                                    const Color(0xFF008C7B),
                                    'Schademelding',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      if (_selectedAnimal == null)
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 8,
                          right: 12,
                          child: _mapVerticalControlPill(),
                        ),

                      if (_selectedAnimal != null)
                        Positioned.fill(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAnimal = null;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                          ),
                        ),

                      if (_selectedAnimal != null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1, end: 0),
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, value * 80),
                                child: Opacity(
                                  opacity: 1 - value,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: AnimalDetailCard(
                                animal: _selectedAnimal!,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }


  Color _getBorderColorForDetectionType(String? detectionType) {
    if (detectionType == null) return Colors.white;

    final type = detectionType.toLowerCase();

    if (type.contains('camera') || type.contains('foto')) {
      return const Color(0xFF00BFD8); // Aqua
    } else if (type.contains('acoustic') || type.contains('geluid')) {
      return const Color(0xFFFF9100); // Orange
    } else if (type.contains('waarneming') || type.contains('sighting')) {
      return const Color(0xFF8613A8); // Purple
    } else if (type.contains('collision') || type.contains('botsing')) {
      return const Color(0xFF0078DA); // Blue
    } else if (type.contains('schadamelding') || type.contains('damage')) {
      return const Color(0xFF008C7B); // Teal
    } else if (type.contains('collar')) {
      return const Color(0xFFFE008E); // Pink
    }

    return Colors.white;
  }

  int? _eventCountForPin(AnimalPin pin) {
    final type = pin.reportType?.toLowerCase();
    final isFixedPin =
        type?.contains('camera') == true ||
        type?.contains('foto') == true ||
        type?.contains('acoustic') == true ||
        type?.contains('geluid') == true;

    return isFixedPin ? 3 : null;
  }

  Widget _buildStyledAnimalPin(
    String? speciesName,
    String? detectionType,
    _IconStyle style, {
    int? eventCount,
  }) {
    final borderColor = _getBorderColorForDetectionType(detectionType);
    final type = detectionType?.toLowerCase();

    final bool isCamera =
        type?.contains('camera') == true || type?.contains('foto') == true;

    final bool isAcoustic =
        type?.contains('acoustic') == true || type?.contains('geluid') == true;

    final bool isCollar = type?.contains('collar') == true;
    final iconPath = getSpeciesIconPath(speciesName);

    return SizedBox(
      width: style.size + 28,
      height: style.size + 28,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: style.size + 16,
            height: style.size + 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: borderColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isCamera)
                  Icon(
                    Icons.camera_alt,
                    size: style.size * 0.9,
                    color: style.color,
                  )
                else if (isAcoustic)
                  Icon(
                    Icons.graphic_eq,
                    size: style.size * 0.9,
                    color: style.color,
                  )
                else if (iconPath != null)
                  SizedBox(
                    width: style.size,
                    height: style.size,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        style.color,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        iconPath,
                        width: style.size,
                        height: style.size,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.pets,
                            size: style.size * 0.9,
                            color: style.color,
                          );
                        },
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.pets,
                    size: style.size,
                    color: style.color,
                  ),
                if (eventCount != null && eventCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        '$eventCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isCollar)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: borderColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings_remote,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(
    Color color,
    String label, {
    IconData? icon,
    IconData? badgeIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: color,
                    width: 3,
                  ),
                ),
                child: icon != null
                    ? Icon(
                        icon,
                        size: 16,
                        color: Colors.black,
                      )
                    : null,
              ),
              if (badgeIcon != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      badgeIcon,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _animalPinMarkerContent(
    AnimalPin pin,
    double mapRotation, {
    VoidCallback? onTap,
  }) {
    final style = _iconStyleForTimestamp(pin.seenAt);

    Widget child = Transform.rotate(
      angle: -mapRotation * math.pi / 180,
      child: _buildStyledAnimalPin(
        pin.speciesName,
        pin.reportType,
        style,
        eventCount: _eventCountForPin(pin),
      ),
    );

    if (onTap != null) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      );
    }

    return Tooltip(
      message: pin.speciesName != null && pin.speciesName!.isNotEmpty
          ? 'Dier: ${pin.speciesName}'
          : 'Dier',
      child: child,
    );
  }

  Widget _detectionPinMarker({
    required DetectionPin pin,
    required double mapRotation,
    required VoidCallback onTap,
    required _IconStyle style,
  }) {
    return Tooltip(
      message: pin.label != null && pin.label!.isNotEmpty
          ? 'Detectie: ${pin.label}'
          : 'Detectie',
      child: Transform.rotate(
        angle: -mapRotation * math.pi / 180,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: _buildStyledAnimalPin(
            pin.label,
            pin.label,
            style,
          ),
        ),
      ),
    );
  }


  _IconStyle _iconStyleForTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final age = now.difference(timestamp);

    if (age.inMinutes < 60) {
      return const _IconStyle(Color(0xFF000000), 32.0);
    } else if (age.inHours < 24) {
      return const _IconStyle(Color(0xFF2F2E2E), 28.0);
    } else if (age.inDays < 7) {
      return const _IconStyle(Color(0xFF4D4D4D), 22.0);
    }

    return _IconStyle(Colors.grey.shade600, 20.0);
  }
}