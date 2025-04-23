import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_state_interface.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/providers/map_provider.dart';

class LivingLab1Map extends StatefulWidget {
  const LivingLab1Map({super.key});

  @override
  State<LivingLab1Map> createState() => _LivingLab1MapState();
}

class _LivingLab1MapState extends State<LivingLab1Map> with TickerProviderStateMixin {
  static const LatLng labCenter = LatLng(52.4114, 4.5733);
  
  // Calculate bounds based on square boundary
  static const double minLat = 52.4114 - 0.018;  // Bottom
  static const double maxLat = 52.4114 + 0.018;  // Top
  static const double minLng = 4.5733 - 0.028;   // Left
  static const double maxLng = 4.5733 + 0.028;   // Right

  final List<LatLng> squareBoundary = [
    LatLng(52.4114 + 0.018, 4.5733 - 0.028), // Top-left
    LatLng(52.4114 + 0.018, 4.5733 + 0.028), // Top-right
    LatLng(52.4114 - 0.018, 4.5733 + 0.028), // Bottom-right
    LatLng(52.4114 - 0.018, 4.5733 - 0.028), // Bottom-left
    LatLng(52.4114 + 0.018, 4.5733 - 0.028), // Closing point (same as first)
  ];

  late final MapStateInterface _mapState;
  late final MapProvider _mapProvider;
  final String _standardTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  void initState() {
    super.initState();
    _mapState = LocationMapManager();
    _mapProvider = context.read<MapProvider>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_mapProvider.isInitialized) {
        _mapProvider.initialize();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeMapView();
        });
      } else {
        _initializeMapView();
      }
    });
  }

  void _initializeMapView() {
    if (_mapProvider.mapController.camera != null) {
      _mapState.animateToLocation(
        mapController: _mapProvider.mapController,
        targetLocation: labCenter,
        targetZoom: 15,
        vsync: this,
      );
    }
  }

  void _constrainMap() {
    final currentCenter = _mapProvider.mapController.camera.center;
    var newCenter = currentCenter;
    
    if (currentCenter.latitude < minLat) {
      newCenter = LatLng(minLat, newCenter.longitude);
    } else if (currentCenter.latitude > maxLat) {
      newCenter = LatLng(maxLat, newCenter.longitude);
    }
    
    if (currentCenter.longitude < minLng) {
      newCenter = LatLng(newCenter.latitude, minLng);
    } else if (currentCenter.longitude > maxLng) {
      newCenter = LatLng(newCenter.latitude, maxLng);
    }
    
    if (newCenter != currentCenter) {
      _mapProvider.mapController.move(newCenter, _mapProvider.mapController.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        return FlutterMap(
          mapController: mapProvider.mapController,
          options: MapOptions(
            minZoom: 14,
            maxZoom: 18,
            initialCenter: labCenter,
            initialZoom: 15,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            onPositionChanged: (MapPosition position, bool hasGesture) {
              if (hasGesture) _constrainMap();
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _standardTileUrl,
              userAgentPackageName: 'com.wildrapport.app',
            ),
            PolygonLayer(
              polygons: [
                Polygon(
                  points: squareBoundary,
                  color: Colors.blue.withOpacity(0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}


