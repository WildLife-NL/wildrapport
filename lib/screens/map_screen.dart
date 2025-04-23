import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/constants/app_colors.dart';
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

  final MapController _mapController = MapController();

  Position? _currentPosition;
  String _currentAddress = "Loading...";
  bool _isLoading = true;
  bool _isSatelliteView = false;
  LatLng? _markedLocation;
  String _markedAddress = "";

  static const String _standardTileUrl = MapStateInterface.standardTileUrl;
  static const String _satelliteTileUrl = MapStateInterface.satelliteTileUrl;
  static const LatLng denBoschCenter = MapStateInterface.denBoschCenter;

  @override
  void initState() {
    super.initState();
    final manager = LocationMapManager();
    _locationService = manager;
    _mapService = manager;
    _mapState = manager;

    _initLocation();

    _mapController.mapEventStream.listen((event) {
      if (event is MapEventMoveEnd) {
        _constrainMap();
      }
    });
  }

  void _constrainMap() {
    _mapState.constrainMapCamera(_mapController);
  }

  Future<void> _initLocation() async {
    final position = await _locationService.determinePosition();
    if (position == null || !_locationService.isLocationInNetherlands(position.latitude, position.longitude)) {
      setState(() {
        _currentAddress = 'Unable to get valid location';
        _isLoading = false;
      });
      return;
    }

    final address = await _locationService.getAddressFromPosition(position);
    setState(() {
      _currentPosition = position;
      _currentAddress = address;
      _isLoading = false;
    });
  }

  Future<void> _handleTap(TapPosition tapPosition, LatLng point) async {
    if (_mapService.isLocationInNetherlands(point.latitude, point.longitude)) {
      setState(() {
        _markedLocation = point;
        _markedAddress = "Fetching address...";
      });

      final address = await _mapService.getAddressFromLatLng(point);
      setState(() {
        _markedAddress = address;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentPosition != null
                                ? _mapService.constrainLatLng(
                                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
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
                                      mapController: _mapController,
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
                    width: double.infinity,
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
                                color:
                                    _markedLocation != null ? Colors.red : Colors.blue[600],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _markedLocation != null ? _markedAddress : _currentAddress,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color:
                                    _markedLocation != null ? Colors.red : Colors.blue[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => context
            .read<NavigationStateInterface>()
            .pushReplacementBack(context, const Rapporteren()),
        onNextPressed: _markedLocation != null ? () {
          // Handle next
        } : null,
        showNextButton: true,
        showBackButton: true,
      ),
    );
  }
}


