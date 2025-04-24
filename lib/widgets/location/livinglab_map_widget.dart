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

class LivingLabMapScreen extends StatefulWidget {
  final String labName;
  final LatLng labCenter;
  final double boundaryOffset; // Distance from center in degrees
  final LocationMapManager? locationService; // For testing
  final LocationMapManager? mapService;      // For testing
  
  const LivingLabMapScreen({
    super.key,
    required this.labName,
    required this.labCenter,
    this.boundaryOffset = 0.018, // Default value based on original implementation
    this.locationService,
    this.mapService,
  });

  @override
  State<LivingLabMapScreen> createState() => _LivingLabMapScreenState();
}

class _LivingLabMapScreenState extends State<LivingLabMapScreen> with TickerProviderStateMixin {
  static const String _standardTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _satelliteTileUrl = 
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  
  // Calculate bounds based on widget parameters
  late final double minLat;
  late final double maxLat;
  late final double minLng;
  late final double maxLng;
  late final List<LatLng> squareBoundary;

  late final LocationMapManager _locationService;
  late final LocationMapManager _mapService;
  late final LocationMapManager _mapState;
  late final MapProvider _mapProvider;
  
  Position? _currentPosition;
  String _currentAddress = '';
  LatLng? _markedLocation;
  String _markedAddress = '';
  bool _isLoading = true;
  bool _isDisposed = false;
  bool _isSatelliteView = false;

  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().setMapController(_mapController);
      _quickLocationCheck();
    });
  }

  void _initializeBoundaries() {
    // Initialize the boundary coordinates
    minLat = widget.labCenter.latitude - widget.boundaryOffset;
    maxLat = widget.labCenter.latitude + widget.boundaryOffset;
    minLng = widget.labCenter.longitude - (widget.boundaryOffset * 1.556); // Adjust for longitude scaling
    maxLng = widget.labCenter.longitude + (widget.boundaryOffset * 1.556);

    // Initialize the square boundary
    squareBoundary = [
      LatLng(maxLat, minLng),
      LatLng(maxLat, maxLng),
      LatLng(minLat, maxLng),
      LatLng(minLat, minLng),
      LatLng(maxLat, minLng), // Close the polygon
    ];
  }

  void _initializeMapView() {
    if (_mapProvider.mapController.camera != null) {
      _mapState.animateToLocation(
        mapController: _mapProvider.mapController,
        targetLocation: widget.labCenter,
        targetZoom: 15,
        vsync: this,
      );
    }
  }

  Future<void> _quickLocationCheck() async {
    if (_isDisposed) return;
    
    setState(() => _isLoading = true);
    
    // Get last known position immediately
    final lastPosition = await Geolocator.getLastKnownPosition();
    if (_isDisposed || !mounted) return;

    if (lastPosition != null) {
      await _handleUserLocation(lastPosition, animate: false);
    }

    // Get fresh location in background
    _initLocation();
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
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _handleUserLocation(Position position, {bool animate = true}) async {
    if (_isDisposed) return;

    bool isInBounds = position.latitude >= minLat && 
        position.latitude <= maxLat && 
        position.longitude >= minLng && 
        position.longitude <= maxLng;

    setState(() {
      _isLoading = false;
      _currentPosition = position;
      _markedLocation = null;
      _markedAddress = "";
      _currentAddress = isInBounds ? "Fetching address..." : 'Buiten het onderzoeksgebied';
    });

    if (isInBounds) {
      if (animate) {
        _mapState.animateToLocation(
          mapController: _mapProvider.mapController,
          targetLocation: LatLng(position.latitude, position.longitude),
          targetZoom: 16,
          vsync: this,
        );
      }
      // Get address in background
      _updateAddress(position);
    } else if (animate) {
      _mapState.animateToLocation(
        mapController: _mapProvider.mapController,
        targetLocation: widget.labCenter,
        targetZoom: 15,
        vsync: this,
      );
    }
  }

  Future<void> _initLocation() async {
    if (_isDisposed) return;
    
    print('Initializing location');
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5)
      );

      print('Got current position: $position');
      if (_isDisposed || !mounted) return;

      await _handleUserLocation(position, animate: false);
    } catch (e) {
      print('Error getting location: $e');
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

      await _handleUserLocation(position, animate: false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentAddress = 'Locatie niet beschikbaar';  // Changed from setting _currentPosition to null
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

    if (point.latitude >= minLat && 
        point.latitude <= maxLat && 
        point.longitude >= minLng && 
        point.longitude <= maxLng) {
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
            if (!mapProvider.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return Stack(
              children: [
                FlutterMap(
                  mapController: mapProvider.mapController,
                  options: MapOptions(
                    minZoom: 14,
                    maxZoom: 18,
                    initialCenter: widget.labCenter,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onPositionChanged: (MapPosition position, bool hasGesture) {
                      if (hasGesture) _constrainMap();
                    },
                    onTap: _handleTap,
                    onMapReady: _initializeMapView,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _isSatelliteView ? _satelliteTileUrl : _standardTileUrl,
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
                    latitude: _markedLocation?.latitude ?? _currentPosition?.latitude,
                    longitude: _markedLocation?.longitude ?? _currentPosition?.longitude,
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
                    final position = Position(
                      latitude: _markedLocation!.latitude,
                      longitude: _markedLocation!.longitude,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      altitudeAccuracy: 0,
                      heading: 0,
                      headingAccuracy: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      isMocked: false,
                    );
                    context.read<MapProvider>().setSelectedLocation(position, _markedAddress);
                    context.read<NavigationStateInterface>()
                      .pushReplacementBack(context, const LocationScreen());
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
    print('Location button pressed');
    if (_currentPosition != null) {
      _handleUserLocation(_currentPosition!, animate: true);
    } else {
      print('No current position available');
      _initLocation(); // Try to get current location again
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






