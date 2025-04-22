import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/screens/rapporteren.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  Position? _currentPosition;
  String _currentAddress = "Loading...";
  bool _isLoading = true;
  final MapController _mapController = MapController();
  bool _isSatelliteView = false;
  LatLng? _markedLocation;
  String _markedAddress = "";

  // Define Den Bosch and lower Netherlands boundaries
  static const double minLat = 51.2; // Southern boundary
  static const double maxLat = 52.0; // Northern boundary
  static const double minLng = 4.9;  // Western boundary
  static const double maxLng = 5.9;  // Eastern boundary
  static const LatLng denBoschCenter = LatLng(51.6988, 5.3041); // Den Bosch coordinates

  // Map tile URLs
  static const String _standardTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _satelliteTileUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  @override
  void initState() {
    super.initState();
    _determinePosition();
    
    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        _constrainMap();
      }
    });
  }

  void _constrainMap() {
    final center = _mapController.camera.center;
    var newLat = center.latitude;
    var newLng = center.longitude;
    var needsUpdate = false;

    if (center.latitude > maxLat) {
      newLat = maxLat;
      needsUpdate = true;
    } else if (center.latitude < minLat) {
      newLat = minLat;
      needsUpdate = true;
    }

    if (center.longitude > maxLng) {
      newLng = maxLng;
      needsUpdate = true;
    } else if (center.longitude < minLng) {
      newLng = minLng;
      needsUpdate = true;
    }

    if (needsUpdate) {
      _mapController.move(
        LatLng(newLat, newLng),
        _mapController.camera.zoom,
      );
    }
  }

  Future<void> _handleTap(TapPosition tapPosition, LatLng point) async {
    if (_isLocationInNetherlands(point.latitude, point.longitude)) {
      setState(() {
        _markedLocation = point;
        _markedAddress = "Fetching address...";
      });
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          point.latitude,
          point.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _markedAddress =
                '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';
          });
        }
      } catch (e) {
        setState(() {
          _markedAddress = 'Error fetching address';
        });
        debugPrint('Error getting marked location address: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _currentPosition != null
                                    ? LatLng(
                                        _currentPosition!.latitude.clamp(minLat, maxLat),
                                        _currentPosition!.longitude.clamp(minLng, maxLng),
                                      )
                                    : denBoschCenter,
                                initialZoom: 16,  // Keep initial zoom at 16 for close view
                                minZoom: 10,     // Changed to 10 to allow zooming out further
                                maxZoom: 18,     // Keep max zoom at 18
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                                ),
                                onPositionChanged: (MapPosition position, bool hasGesture) {
                                  if (hasGesture) {
                                    _constrainMap();
                                  }
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
                                        _isLocationInNetherlands(
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
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
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
                                          child: Icon(
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
                            Positioned(
                              right: 16,
                              bottom: 16,  // Changed from 100 to 16 to be closer to the text container
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
                                      if (_currentPosition != null && _isLocationInNetherlands(
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                      )) {
                                        // Clear marked location when returning to current location
                                        setState(() {
                                          _markedLocation = null;
                                          _markedAddress = "";
                                        });

                                        final latTween = Tween<double>(
                                          begin: _mapController.camera.center.latitude,
                                          end: _currentPosition!.latitude,
                                        );
                                        final lngTween = Tween<double>(
                                          begin: _mapController.camera.center.longitude,
                                          end: _currentPosition!.longitude,
                                        );
                                        final zoomTween = Tween<double>(
                                          begin: _mapController.camera.zoom,
                                          end: 16,  // Maintained at 16 for consistency
                                        );

                                        var controller = AnimationController(
                                          duration: const Duration(milliseconds: 500),
                                          vsync: this,
                                        );

                                        Animation<double> animation = CurvedAnimation(
                                          parent: controller,
                                          curve: Curves.easeInOut,
                                        );

                                        controller.addListener(() {
                                          _mapController.move(
                                            LatLng(
                                              latTween.evaluate(animation),
                                              lngTween.evaluate(animation),
                                            ),
                                            zoomTween.evaluate(animation),
                                          );
                                        });

                                        animation.addStatusListener((status) {
                                          if (status == AnimationStatus.completed) {
                                            controller.dispose();
                                          } else if (status == AnimationStatus.dismissed) {
                                            controller.dispose();
                                          }
                                        });

                                        controller.forward();
                                      }
                                    },
                                    backgroundColor: AppColors.brown,
                                    child: Icon(
                                      Icons.my_location,
                                      color: AppColors.offWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,  // Makes container full width
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: AppColors.offWhite,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, -2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _markedLocation != null ? "Geselecteerde Locatie" : "Huidige Locatie",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _markedLocation != null 
                                  ? Colors.red 
                                  : Colors.blue[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _markedLocation != null ? _markedAddress : _currentAddress,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: _markedLocation != null 
                                  ? Colors.red 
                                  : Colors.blue[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => context.read<NavigationStateInterface>().pushReplacementBack(context, const Rapporteren()),
        onNextPressed: _markedLocation != null ? () {
          // Handle next action with selected location
        } : null,
        showNextButton: true,
        showBackButton: true,
      ),
      // Remove the floatingActionButton here
    );
  }

  bool _isLocationInNetherlands(double lat, double lon) {
    return lat >= minLat && lat <= maxLat && lon >= minLng && lon <= maxLng;
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location services are disabled';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = 'Location permissions are denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentAddress = 'Location permissions are permanently denied';
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_isLocationInNetherlands(position.latitude, position.longitude)) {
        setState(() {
          _currentPosition = position;
        });
        await _getAddressFromLatLng();
      } else {
        setState(() {
          _currentPosition = null;
          _currentAddress = 'Location outside Netherlands';
        });
        _mapController.move(denBoschCenter, 10); // Move to Den Bosch center
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _currentAddress = 'Error getting location';
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng() async {
    try {
      if (_currentPosition == null) return;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }
}









