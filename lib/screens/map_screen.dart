import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/screens/location_screen.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/interfaces/map/map_state_interface.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final LocationServiceInterface _locationService;
  late final MapServiceInterface _mapService;
  late final MapStateInterface _mapState;
  late final MapProvider _mapProvider;
  bool _isDisposed = false;

  Position? _currentPosition;
  String _currentAddress = 'Loading...';
  bool _isLoading = true;
  bool _isSatelliteView = false;
  LatLng? _markedLocation;
  String _markedAddress = '';

  // Constants moved from MapStateInterface
  static const String _standardTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _satelliteTileUrl = 
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const LatLng denBoschCenter = LatLng(51.6988, 5.3041);

  @override
  void initState() {
    super.initState();
    _locationService = LocationMapManager();
    _mapService = LocationMapManager();
    _mapState = LocationMapManager();
    _mapProvider = context.read<MapProvider>();
    
    if (!_mapProvider.isInitialized) {
      _mapProvider.initialize();
    }
    // Start location fetch immediately
    _initLocation();
    // Also start a quick permission check to show location faster
    _quickLocationCheck();
  }

  Future<void> _quickLocationCheck() async {
    if (_isDisposed) return;
    
    // Try to get last known location first for quick display
    final lastPosition = await Geolocator.getLastKnownPosition();
    if (_isDisposed || !mounted) return;

    if (lastPosition != null && 
        _locationService.isLocationInNetherlands(lastPosition.latitude, lastPosition.longitude)) {
      setState(() {
        _currentPosition = lastPosition;
        _isLoading = false;
      });
      
      // Update map position immediately
      if (_mapProvider.mapController.camera.zoom == 0) {  // Only if not already set
        _mapState.animateToLocation(
          mapController: _mapProvider.mapController,
          targetLocation: LatLng(lastPosition.latitude, lastPosition.longitude),
          targetZoom: 16,
          vsync: this,
        );
      }
    }
  }

  void _constrainMap() {
    _mapState.constrainMapCamera(_mapProvider.mapController);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initLocation() async {
    if (_isDisposed) return;
    
    // Start with a lower accuracy location request for faster initial response
    Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.reduced,
      timeLimit: const Duration(seconds: 5)
    ).catchError((_) => null);

    if (_isDisposed || !mounted) return;

    if (position != null && 
        _locationService.isLocationInNetherlands(position.latitude, position.longitude)) {
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Update address in background
      _updateAddress(position);

      // Then get high accuracy location
      _getHighAccuracyLocation();
    }
  }

  Future<void> _getHighAccuracyLocation() async {
    if (_isDisposed) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    if (_isDisposed || !mounted) return;

    if (position != null && 
        _locationService.isLocationInNetherlands(position.latitude, position.longitude)) {
      setState(() {
        _currentPosition = position;
      });
      _updateAddress(position);
    }
  }

  Future<void> _updateAddress(Position position) async {
    if (_isDisposed) return;

    final address = await _locationService.getAddressFromPosition(position);
    if (_isDisposed || !mounted) return;

    setState(() {
      _currentAddress = address;
    });
  }

  Future<void> _handleTap(TapPosition tapPosition, LatLng point) async {
    if (_isDisposed) return;

    if (_mapService.isLocationInNetherlands(point.latitude, point.longitude)) {
      if (mounted) {
        setState(() {
          _markedLocation = point;
          _markedAddress = "Fetching address...";
        });
      }

      final address = await _mapService.getAddressFromLatLng(point);
      if (_isDisposed) return;

      if (mounted) {
        setState(() {
          _markedAddress = address;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          leftIcon: Icons.arrow_back_ios,
          centerText: 'Kaart',
          rightIcon: Icons.menu,
          onLeftIconPressed: () => context
              .read<NavigationStateInterface>()
              .pushReplacementBack(context, const LocationScreen()),
          onRightIconPressed: () {/* Handle menu */},
        ),
      ),
      body: SafeArea(
        child: Consumer<MapProvider>(
          builder: (context, mapProvider, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: FlutterMap(
                        mapController: mapProvider.mapController,
                        options: MapOptions(
                          initialCenter: mapProvider.currentPosition != null
                              ? _mapService.constrainLatLng(
                                  LatLng(
                                    mapProvider.currentPosition!.latitude,
                                    mapProvider.currentPosition!.longitude,
                                  ),
                                )
                              : denBoschCenter,
                          initialZoom: 16,
                          minZoom: 10,
                          maxZoom: 18,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                          ),
                          onPositionChanged: (MapPosition position, bool hasGesture) {
                            if (hasGesture) _constrainMap();
                          },
                          onTap: _handleTap,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: _isSatelliteView ? _satelliteTileUrl : _standardTileUrl,
                            userAgentPackageName: 'com.wildrapport.app',
                          ),
                          MarkerLayer(
                            markers: [
                              if (_currentPosition != null &&
                                  _locationService.isLocationInNetherlands(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ))
                                Marker(
                                  point: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  width: 40,
                                  height: 40,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.blue[100]!.withOpacity(0.3),
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[600],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_markedLocation != null)
                                Marker(
                                  point: _markedLocation!,
                                  width: 80,
                                  height: 80,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "satellite",
                        onPressed: () {
                          setState(() {
                            _isSatelliteView = !_isSatelliteView;
                          });
                        },
                        backgroundColor: AppColors.brown,
                        child: Icon(
                          _isSatelliteView ? Icons.map : Icons.satellite,
                          color: AppColors.offWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        heroTag: "location",
                        onPressed: () {
                          if (_currentPosition != null &&
                              _locationService.isLocationInNetherlands(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              )) {
                            setState(() {
                              _markedLocation = null;
                              _markedAddress = "";
                            });

                            _mapState.animateToLocation(
                              mapController: mapProvider.mapController,
                              targetLocation: LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                              targetZoom: 16,
                              vsync: this,
                            );
                          }
                        },
                        backgroundColor: AppColors.brown,
                        child: const Icon(
                          Icons.my_location,
                          color: AppColors.offWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => context
            .read<NavigationStateInterface>()
            .pushReplacementBack(context, const LocationScreen()),
        onNextPressed: _markedLocation != null ? () {
          // Handle next
        } : null,
        showNextButton: true,
        showBackButton: true,
      ),
    );
  }
}


