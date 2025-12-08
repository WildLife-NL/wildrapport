import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/models/beta_models/polygon_area_model.dart';
import 'package:wildrapport/constants/app_colors.dart';

class AreaSelectionMap extends StatefulWidget {
  final Function(PolygonArea) onAreaSelected;
  final LatLng? initialCenter;
  final PolygonArea? existingArea;

  const AreaSelectionMap({
    super.key,
    required this.onAreaSelected,
    this.initialCenter,
    this.existingArea,
  });

  @override
  State<AreaSelectionMap> createState() => _AreaSelectionMapState();
}

class _AreaSelectionMapState extends State<AreaSelectionMap> {
  late fm.MapController _mapController;
  List<LatLng> _polygonPoints = [];
  bool _isDrawing = false;
  bool _isGpsRecording = false;
  List<LatLng> _gpsTrack = [];
  late LatLng _centerPoint;
  LatLng? _currentLocation;
  StreamSubscription<Position>? _liveLocationSub;

  @override
  void initState() {
    super.initState();
    _mapController = fm.MapController();
    
    if (widget.existingArea != null) {
      _polygonPoints = widget.existingArea!.points;
    }
    
    _centerPoint = widget.initialCenter ?? const LatLng(51.7, 5.27);
    _loadCurrentLocation();
    _startLiveLocationUpdates();
  }

  @override
  void dispose() {
    _liveLocationSub?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng point) {
    if (!_isDrawing || _isGpsRecording) return;

    setState(() {
      _polygonPoints.add(point);
    });
  }

  void _startDrawing() {
    setState(() {
      _isDrawing = !_isDrawing;
      if (!_isDrawing) {
        _gpsTrack.clear();
      }
    });
  }

  void _startGpsRecording() async {
    if (_isGpsRecording) {
      // Stop recording
      setState(() {
        _isGpsRecording = false;
      });
      if (_gpsTrack.length >= 3) {
        widget.onAreaSelected(
          PolygonArea(points: _gpsTrack, areaType: 'gps_recording'),
        );
      }
      return;
    }

    // Start recording
    setState(() {
      _isGpsRecording = true;
      _gpsTrack.clear();
      _polygonPoints.clear();
    });

    try {
      final positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update every 5 meters
        ),
      );

      positionStream.listen((Position position) {
        if (_isGpsRecording) {
          setState(() {
            final point = LatLng(position.latitude, position.longitude);
            _gpsTrack.add(point);
            _polygonPoints = List.from(_gpsTrack);
          });
        }
      });
    } catch (e) {
      debugPrint('GPS recording error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('GPS error: $e')),
      );
      setState(() {
        _isGpsRecording = false;
      });
    }
  }

  void _undoLastPoint() {
    if (_polygonPoints.isNotEmpty) {
      setState(() {
        _polygonPoints.removeLast();
      });
    }
  }

  void _clearArea() {
    setState(() {
      _polygonPoints.clear();
      _gpsTrack.clear();
      _isDrawing = false;
      _isGpsRecording = false;
    });
  }

  void _completeArea() {
    if (_polygonPoints.length >= 3) {
      widget.onAreaSelected(
        PolygonArea(
          points: _polygonPoints,
          areaType: _isGpsRecording ? 'gps_recording' : 'polygon',
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draw at least 3 points to create an area'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final here = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        _currentLocation = here;
        if (widget.initialCenter == null) {
          _centerPoint = here;
        }
      });
      // Move map to current location if no explicit initial center provided
      if (widget.initialCenter == null) {
        _mapController.move(here, 16);
      }
    } catch (e) {
      debugPrint('Current location error: $e');
    }
  }

  Future<void> _startLiveLocationUpdates() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      _liveLocationSub?.cancel();
      final stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 3,
        ),
      );
      _liveLocationSub = stream.listen((pos) {
        final here = LatLng(pos.latitude, pos.longitude);
        if (!mounted) return;
        setState(() {
          _currentLocation = here;
        });
      });
    } catch (e) {
      debugPrint('Live location stream error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Damaged Area',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Map
          fm.FlutterMap(
            mapController: _mapController,
            options: fm.MapOptions(
              initialCenter: _centerPoint,
              initialZoom: 16,
              onTap: (tapPosition, point) => _onMapTap(point),
            ),
            children: [
              fm.TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              // Current location marker
              if (_currentLocation != null)
                fm.MarkerLayer(
                  markers: [
                    fm.Marker(
                      point: _currentLocation!,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              // Draw polygon
              if (_polygonPoints.isNotEmpty)
                fm.PolygonLayer(
                  polygons: [
                    fm.Polygon(
                      points: _polygonPoints,
                      color: Colors.blue.withOpacity(0.3),
                      borderStrokeWidth: 2,
                      borderColor: Colors.blue,
                    ),
                  ],
                ),
              // Draw points
              fm.MarkerLayer(
                markers: _polygonPoints
                    .asMap()
                    .entries
                    .map(
                      (entry) => fm.Marker(
                        point: entry.value,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

          // Control panel at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.darkGreen.withOpacity(0.95),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info text
                  Text(
                    _isGpsRecording
                        ? 'GPS recording active... Points: ${_polygonPoints.length}'
                        : _isDrawing
                            ? 'Tap on the map to add points (${_polygonPoints.length} points)'
                            : 'Choose a way to mark the damaged area',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Area info if polygon exists
                  if (_polygonPoints.length >= 3) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Area: ${PolygonArea(points: _polygonPoints).getAreaInHectares().toStringAsFixed(2)} hectares',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      // Manual drawing button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startDrawing,
                          icon: Icon(
                            _isDrawing ? Icons.check : Icons.edit_location,
                          ),
                          label: Text(
                            _isDrawing ? 'Drawing' : 'Draw Area',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isDrawing
                                ? AppColors.lightGreen
                                : AppColors.lightMintGreen,
                            foregroundColor: _isDrawing
                                ? AppColors.offWhite
                                : AppColors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // GPS recording button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startGpsRecording,
                          icon: Icon(
                            _isGpsRecording
                                ? Icons.stop_circle
                                : Icons.my_location,
                          ),
                          label: Text(
                            _isGpsRecording
                                ? 'Stop GPS'
                                : 'GPS Record',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isGpsRecording
                                ? Colors.red
                                : AppColors.lightMintGreen,
                            foregroundColor: _isGpsRecording
                                ? AppColors.offWhite
                                : AppColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Secondary action buttons
                  Row(
                    children: [
                      // Undo button
                      if (_polygonPoints.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _undoLastPoint,
                            icon: const Icon(Icons.undo),
                            label: const Text('Undo'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                      if (_polygonPoints.isNotEmpty) const SizedBox(width: 8),

                      // Clear button
                      if (_polygonPoints.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _clearArea,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Clear'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Confirm button
                  if (_polygonPoints.length >= 3)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _completeArea,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Confirm Area'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  // Extra spacing to make the bottom container feel larger
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
