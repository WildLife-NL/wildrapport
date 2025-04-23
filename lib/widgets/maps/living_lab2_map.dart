import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_state_interface.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/providers/map_provider.dart';

class LivingLab2Map extends StatefulWidget {
  const LivingLab2Map({super.key});

  @override
  State<LivingLab2Map> createState() => _LivingLab2MapState();
}

class _LivingLab2MapState extends State<LivingLab2Map> with TickerProviderStateMixin {
  static const LatLng labCenter = LatLng(51.1950, 5.7230);
  
  // Calculate bounds based on square boundary
  static const double minLat = 51.1950 - 0.045;  // Bottom
  static const double maxLat = 51.1950 + 0.045;  // Top
  static const double minLng = 5.7230 - 0.070;   // Left
  static const double maxLng = 5.7230 + 0.070;   // Right

  final List<LatLng> kempenBroekSquare = [
    LatLng(51.1950 + 0.045, 5.7230 - 0.070), // Top-left
    LatLng(51.1950 + 0.045, 5.7230 + 0.070), // Top-right
    LatLng(51.1950 - 0.045, 5.7230 + 0.070), // Bottom-right
    LatLng(51.1950 - 0.045, 5.7230 - 0.070), // Bottom-left
    LatLng(51.1950 + 0.045, 5.7230 - 0.070), // Closing point
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
        targetZoom: 12,
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
            minZoom: 13,
            maxZoom: 18,
            initialCenter: labCenter,
            initialZoom: 17,
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
                  points: kempenBroekSquare,
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