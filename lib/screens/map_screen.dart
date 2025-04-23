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
import 'package:wildrapport/widgets/location/location_data_card.dart';

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
    // Start with immediate location check
    _quickLocationCheck();
  }

  Future<void> _quickLocationCheck() async {
    if (_isDisposed) return;
    
    // First try to get last known location for immediate display
    final lastPosition = await Geolocator.getLastKnownPosition();
    if (_isDisposed || !mounted) return;

    if (lastPosition != null && 
        _locationService.isLocationInNetherlands(lastPosition.latitude, lastPosition.longitude)) {
      setState(() {
        _currentPosition = lastPosition;
        _isLoading = false;
      });
      
      // Always center map on user location, regardless of previous zoom
      _mapState.animateToLocation(
        mapController: _mapProvider.mapController,
        targetLocation: LatLng(lastPosition.latitude, lastPosition.longitude),
        targetZoom: 16,
        vsync: this,
      );
      
      // Update address in background
      _updateAddress(lastPosition);
    }

    // Immediately request current position for accuracy
    _initLocation();
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
    
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5)
      );

      if (_isDisposed || !mounted) return;

      if (_locationService.isLocationInNetherlands(position.latitude, position.longitude)) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });

        // Update map to accurate position
        _mapState.animateToLocation(
          mapController: _mapProvider.mapController,
          targetLocation: LatLng(position.latitude, position.longitude),
          targetZoom: 16,
          vsync: this,
        );

        // Update address
        _updateAddress(position);
      }
    } catch (e) {
      // If high accuracy fails, try with reduced accuracy
      _getReducedAccuracyLocation();
    }
  }

  Future<void> _getReducedAccuracyLocation() async {
    if (_isDisposed) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.reduced
      );

      if (_isDisposed || !mounted) return;

      if (_locationService.isLocationInNetherlands(position.latitude, position.longitude)) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });

        _mapState.animateToLocation(
          mapController: _mapProvider.mapController,
          targetLocation: LatLng(position.latitude, position.longitude),
          targetZoom: 16,
          vsync: this,
        );

        _updateAddress(position);
      }
    } catch (e) {
      // If all location attempts fail, show error state
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentAddress = 'Locatie niet beschikbaar';
        });
      }
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
      body: SafeArea(
        child: Consumer<MapProvider>(
          builder: (context, mapProvider, child) {
            return Stack(
              children: [
                // Base map layer
                FlutterMap(
                  mapController: mapProvider.mapController,
                  options: MapOptions(
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
                      markers: _buildMarkers(),
                    ),
                  ],
                ),

                // Top location card with proper spacing and shadow
                Positioned(
                  top: 16,  // Add some padding from the top safe area
                  left: 16,
                  right: 16,
                  child: LocationDataCard(
                    cityName: _markedLocation != null 
                      ? _getLocationCity(_markedAddress)
                      : _getLocationCity(_currentAddress),
                    streetName: _markedLocation != null 
                      ? _getLocationStreet(_markedAddress)
                      : _getLocationStreet(_currentAddress),
                    houseNumber: _markedLocation != null 
                      ? _getLocationHouseNumber(_markedAddress)
                      : _getLocationHouseNumber(_currentAddress),
                    isLoading: _isLoading,
                    isCurrentLocation: _markedLocation == null,
                  ),
                ),

                // Loading indicator
                if (_isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Back button
                _buildNavButton(
                  icon: Icons.arrow_back,
                  label: 'Terug',
                  onPressed: () => context
                    .read<NavigationStateInterface>()
                    .pushReplacementBack(context, const LocationScreen()),
                ),

                // Toggle map type button
                _buildNavButton(
                  icon: _isSatelliteView ? Icons.map : Icons.satellite,
                  label: _isSatelliteView ? 'Kaart' : 'Satelliet',
                  onPressed: () {
                    setState(() {
                      _isSatelliteView = !_isSatelliteView;
                    });
                  },
                ),

                // Current location button
                _buildNavButton(
                  icon: Icons.my_location,
                  label: 'Mijn Locatie',
                  onPressed: _handleLocationButtonPress,
                ),

                // Confirm location button
                _buildNavButton(
                  icon: Icons.check_circle,
                  label: 'Bevestig',
                  onPressed: _markedLocation != null ? () {
                    // Handle location confirmation
                  } : null,
                  isEnabled: _markedLocation != null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isEnabled = true,
  }) {
    final color = isEnabled ? AppColors.brown : AppColors.brown.withOpacity(0.3);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build markers
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Current location marker
    if (_currentPosition != null &&
        _locationService.isLocationInNetherlands(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        )) {
      markers.add(
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
      );
    }

    // Selected location marker
    if (_markedLocation != null) {
      markers.add(
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
      );
    }

    return markers;
  }

  // Helper method for location button press
  void _handleLocationButtonPress() {
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
        mapController: _mapProvider.mapController,
        targetLocation: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        targetZoom: 16,
        vsync: this,
      );
    }
  }

  String? _getLocationCity(String address) {
    final parts = address.split(',');
    return parts.length > 2 ? parts[2].trim() : null;
  }

  String? _getLocationStreet(String address) {
    final parts = address.split(',');
    if (parts.isNotEmpty) {
      final streetParts = parts[0].trim().split(' ');
      // Return everything except the last part (house number)
      return streetParts.length > 1 
          ? streetParts.take(streetParts.length - 1).join(' ') 
          : streetParts[0];
    }
    return null;
  }

  String? _getLocationHouseNumber(String address) {
    final parts = address.split(',');
    if (parts.isNotEmpty) {
      final streetParts = parts[0].trim().split(' ');
      return streetParts.length > 1 ? streetParts.last : null;
    }
    return null;
  }
}








