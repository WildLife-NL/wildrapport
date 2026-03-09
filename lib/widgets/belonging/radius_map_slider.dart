import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/config/mock_location.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/beta_models/polygon_area_model.dart';
import 'package:wildrapport/widgets/map/wildlifenl_map.dart';

/// Inline kaart + schuifbalk op hetzelfde scherm. Geen pagina-wissel.
/// Straal wordt direct doorgegeven bij schuiven; standaard 25 m.
class RadiusMapSlider extends StatefulWidget {
  final void Function(PolygonArea?) onAreaChanged;

  const RadiusMapSlider({
    super.key,
    required this.onAreaChanged,
  });

  @override
  State<RadiusMapSlider> createState() => _RadiusMapSliderState();
}

class _RadiusMapSliderState extends State<RadiusMapSlider> {
  final fm.MapController _mapController = fm.MapController();
  /// GPS-locatie (blauwe pin). Cirkel staat altijd in het midden van de kaart; slepen verplaatst de kaart.
  LatLng? _pinLocation;
  /// Huidig kaartmidden (cirkel staat hier). Niet van controller lezen vóór kaart klaar is (LateInitializationError).
  LatLng? _currentMapCenter;
  String? _error;
  bool _loading = true;

  static const double _minRadiusM = 5;
  static const double _maxRadiusM = 500;
  double _radiusMeters = 25;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      if (!MockLocationConfig.kForceMockLocation) {
        final enabled = await Geolocator.isLocationServiceEnabled();
        if (!enabled) {
          if (!mounted) return;
          setState(() {
            _error = 'Zet locatie aan om een straal te kiezen';
            _loading = false;
          });
          return;
        }
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied) {
          perm = await Geolocator.requestPermission();
        }
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          if (!mounted) return;
          setState(() {
            _error = 'Geen toestemming voor locatie';
            _loading = false;
          });
          return;
        }
      }

      Position? pos;

      if (MockLocationConfig.kForceMockLocation) {
        pos = Position(
          latitude: MockLocationConfig.kMockLat,
          longitude: MockLocationConfig.kMockLon,
          timestamp: DateTime.now(),
          accuracy: 3.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } else {
        try {
          pos = await Geolocator.getLastKnownPosition();
          if (pos != null && mounted) {
            final p = pos;
            final loc = LatLng(p.latitude, p.longitude);
            setState(() {
              _pinLocation = loc;
              _currentMapCenter = loc;
              _loading = false;
            });
            try { _mapController.move(loc, 16); } catch (_) {}
            _notifyArea();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _pinLocation != null) _fitMapToCircle();
            });
          }
        } catch (_) {}

        final fresh = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          ),
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw TimeoutException('Locatie timeout'),
        );
        pos = fresh;
      }

      if (!mounted) return;
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _pinLocation = loc;
        _currentMapCenter = loc;
        _error = null;
        _loading = false;
      });
      _mapController.move(loc, 16);
      _notifyArea();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pinLocation != null) _fitMapToCircle();
      });
    } on TimeoutException {
      if (!mounted) return;
      if (_pinLocation != null) {
        setState(() => _loading = false);
        _notifyArea();
      } else {
        setState(() {
          _error = 'Locatie duurt te lang. Zet GPS aan en tik op Opnieuw.';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (_pinLocation != null) {
        setState(() => _loading = false);
        _notifyArea();
      } else {
        setState(() {
          _error = 'Locatie ophalen mislukt. Tik op Opnieuw.';
          _loading = false;
        });
      }
    }
  }

  void _notifyArea() {
    if (_currentMapCenter == null) {
      widget.onAreaChanged(null);
      return;
    }
    widget.onAreaChanged(
      PolygonArea.fromCircle(_currentMapCenter!, _radiusMeters),
    );
  }

  /// Zorgt dat de cirkel volledig in beeld blijft (automatisch uitzoomen indien nodig).
  void _fitMapToCircle() {
    if (_currentMapCenter == null) return;
    const mPerDegLat = 111320.0;
    final center = _currentMapCenter!;
    final latRad = center.latitude * math.pi / 180;
    final mPerDegLon = 111320.0 * math.cos(latRad);
    final dLat = _radiusMeters / mPerDegLat;
    final dLon = _radiusMeters / mPerDegLon;
    final sw = LatLng(center.latitude - dLat, center.longitude - dLon);
    final ne = LatLng(center.latitude + dLat, center.longitude + dLon);
    final bounds = fm.LatLngBounds(sw, ne);
    try {
      _mapController.fitCamera(
        fm.CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(32),
          maxZoom: 18,
          minZoom: 4,
        ),
      );
    } catch (_) {}
  }

  /// Kaart (en cirkel) terug naar GPS-locatie; cirkel gaat mee.
  void _goToCurrentLocation() {
    if (_pinLocation == null) return;
    setState(() => _currentMapCenter = _pinLocation);
    try { _mapController.move(_pinLocation!, 16); } catch (_) {}
    _notifyArea();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fitMapToCircle();
    });
  }

  static String _formatRadius(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return km == km.roundToDouble()
          ? '${km.toInt()} km'
          : '${km.toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _pinLocation == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Beschadigd gebied',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Locatie ophalen...'),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_error != null && _pinLocation == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Beschadigd gebied',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _loadCurrentLocation,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Opnieuw'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final pinLocation = _pinLocation!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Beschadigd gebied: sleep de kaart, cirkel blijft in het midden',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              SizedBox(
                height: 220,
                child: WildLifeNLMap(
                  mapController: _mapController,
                  options: fm.MapOptions(
                    initialCenter: pinLocation,
                    initialZoom: 16,
                    minZoom: 4.0,
                    maxZoom: 18.0,
                    onMapEvent: (evt) {
                      if (evt is fm.MapEventMove || evt is fm.MapEventMoveEnd) {
                        if (mounted) {
                          try {
                            final center = _mapController.camera.center;
                            setState(() => _currentMapCenter = center);
                            _notifyArea();
                          } catch (_) {}
                        }
                      }
                    },
                    interactionOptions: const fm.InteractionOptions(
                      flags:
                          fm.InteractiveFlag.drag |
                          fm.InteractiveFlag.pinchZoom |
                          fm.InteractiveFlag.doubleTapZoom |
                          fm.InteractiveFlag.flingAnimation |
                          fm.InteractiveFlag.pinchMove,
                    ),
                  ),
                  userAgentPackageName: 'nl.wildlife.rapport',
                  extraLayers: [
                    fm.MarkerLayer(
                      markers: [
                        fm.Marker(
                          point: pinLocation,
                          width: 28,
                          height: 28,
                          child: const Icon(
                            Icons.place,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    fm.CircleLayer(
                      circles: [
                        fm.CircleMarker(
                          point: _currentMapCenter!,
                          radius: _radiusMeters,
                          useRadiusInMeter: true,
                          color: AppColors.darkGreen.withValues(alpha: 0.25),
                          borderColor: AppColors.darkGreen,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  elevation: 2,
                  child: InkWell(
                    onTap: _goToCurrentLocation,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.my_location, size: 20, color: AppColors.darkGreen),
                          const SizedBox(width: 6),
                          const Text(
                            'Huidige locatie',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _formatRadius(_radiusMeters),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.brown900,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.darkGreen,
            inactiveTrackColor: AppColors.darkGreen.withValues(alpha: 0.3),
            thumbColor: AppColors.darkGreen,
          ),
          child: Slider(
            value: _radiusMeters.clamp(_minRadiusM, _maxRadiusM),
            min: _minRadiusM,
            max: _maxRadiusM,
            onChanged: (v) {
              setState(() => _radiusMeters = v);
              _notifyArea();
              _fitMapToCircle();
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatRadius(_minRadiusM),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              _formatRadius(_maxRadiusM),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

