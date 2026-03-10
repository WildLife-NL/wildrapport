import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/config/mock_location.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/beta_models/polygon_area_model.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/map/wildlifenl_map.dart';

/// Kaart met schuifbalk: straal instellen (5 m – 2 km), cirkel groeit mee op de kaart.
class RadiusSelectionScreen extends StatefulWidget {
  final void Function(PolygonArea) onAreaSelected;

  const RadiusSelectionScreen({
    super.key,
    required this.onAreaSelected,
  });

  @override
  State<RadiusSelectionScreen> createState() => _RadiusSelectionScreenState();
}

class _RadiusSelectionScreenState extends State<RadiusSelectionScreen> {
  final fm.MapController _mapController = fm.MapController();
  LatLng? _currentLocation;
  String? _error;
  bool _loading = true;

  static const double _minRadiusM = 5;
  static const double _maxRadiusM = 2000;
  double _radiusMeters = 100;

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
    try {
      if (!MockLocationConfig.kForceMockLocation) {
        final enabled = await Geolocator.isLocationServiceEnabled();
        if (!enabled) {
          if (!mounted) return;
          setState(() {
            _error = 'Zet locatie aan';
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

      final pos = MockLocationConfig.kForceMockLocation
          ? Position(
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
            )
          : await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best,
              ),
            );

      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _error = null;
        _loading = false;
      });
      _mapController.move(_currentLocation!, 16);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Locatie ophalen mislukt';
        _loading = false;
      });
    }
  }

  void _confirmSelection() {
    if (_currentLocation == null) return;
    final area = PolygonArea.fromCircle(_currentLocation!, _radiusMeters);
    widget.onAreaSelected(area);
    Navigator.of(context).pop();
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
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.lightMintGreen,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CustomAppBar(
            leftIcon: Icons.arrow_back_ios,
            centerText: 'Straal kiezen',
            onLeftIconPressed: () => Navigator.of(context).pop(),
            showUserIcon: false,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.lightMintGreen,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: CustomAppBar(
            leftIcon: Icons.arrow_back_ios,
            centerText: 'Straal kiezen',
            onLeftIconPressed: () => Navigator.of(context).pop(),
            showUserIcon: false,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _loadCurrentLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Opnieuw proberen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final center = _currentLocation!;

    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CustomAppBar(
          leftIcon: Icons.arrow_back_ios,
          centerText: 'Straal kiezen',
          onLeftIconPressed: () => Navigator.of(context).pop(),
          showUserIcon: false,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: WildLifeNLMap(
              mapController: _mapController,
              options: fm.MapOptions(
                initialCenter: center,
                initialZoom: 16,
                minZoom: 4.0,
                maxZoom: 17.0,
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
                      point: center,
                      width: 32,
                      height: 32,
                      child: const Icon(
                        Icons.place,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                fm.CircleLayer(
                  circles: [
                    fm.CircleMarker(
                      point: center,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _formatRadius(_radiusMeters),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown900,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      onChanged: (v) => setState(() => _radiusMeters = v),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Deze straal gebruiken',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
