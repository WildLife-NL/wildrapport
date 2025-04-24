import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/permission_interface.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/models/enums/date_time_type.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/screens/map_screen.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/widgets/location/livinglab_map_widget.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/location_display.dart';
import 'package:wildrapport/widgets/location/location_map_preview.dart';
import 'package:wildrapport/widgets/permission_gate.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:wildrapport/widgets/time_selection_row.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late final LocationServiceInterface _locationService;
  String _selectedLocation = LocationType.current.displayText;
  late final MapProvider _mapProvider;

  @override
  void initState() {
    super.initState();
    _locationService = LocationMapManager();
    _mapProvider = context.read<MapProvider>();
    _initializeMap();
    _updateSelectedLocation();
  }

  void _updateSelectedLocation() {
    if (_mapProvider.selectedPosition != null) {
      final selectedPoint = LatLng(
        _mapProvider.selectedPosition!.latitude,
        _mapProvider.selectedPosition!.longitude,
      );

      // Define boundaries for each living lab
      const double zuidKennemerlandTolerance = 0.018; // matches boundaryOffset
      const double grensparkTolerance = 0.045; // matches boundaryOffset

      // Check Zuid-Kennemerland boundaries
      if (_isWithinBoundary(
        selectedPoint,
        const LatLng(52.3874, 4.5753), // zuidCenter
        zuidKennemerlandTolerance,
      )) {
        setState(() {
          _selectedLocation = LocationType.npZuidKennemerland.displayText;
        });
      }
      // Check Grenspark boundaries
      else if (_isWithinBoundary(
        selectedPoint,
        const LatLng(51.1950, 5.7230), // grensparkCenter
        grensparkTolerance,
      )) {
        setState(() {
          _selectedLocation = LocationType.grensparkKempenbroek.displayText;
        });
      }
      // If outside both areas, set to current location
      else {
        setState(() {
          _selectedLocation = LocationType.current.displayText;
        });
      }
    } else {
      setState(() {
        _selectedLocation = LocationType.current.displayText;
      });
    }
  }

  bool _isWithinBoundary(LatLng point, LatLng center, double tolerance) {
    return (point.latitude >= center.latitude - tolerance &&
            point.latitude <= center.latitude + tolerance) &&
           (point.longitude >= center.longitude - tolerance &&
            point.longitude <= center.longitude + tolerance);
  }

  Future<void> _initializeMap() async {
    if (!_mapProvider.isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapProvider.initialize();
      });
    }

    // If there's a selected position, use it and don't fetch current location
    if (_mapProvider.selectedPosition != null) {
      _mapProvider.updatePosition(
        _mapProvider.selectedPosition!,
        _mapProvider.selectedAddress,
      );
      _mapProvider.mapController.move(
        LatLng(
          _mapProvider.selectedPosition!.latitude,
          _mapProvider.selectedPosition!.longitude,
        ),
        15,
      );
      return; // Early return to prevent current location fetch
    }

    // Only fetch current location if no location is selected
    final position = await _locationService.determinePosition();
    if (position != null && _locationService.isLocationInNetherlands(
      position.latitude,
      position.longitude,
    )) {
      final address = await _locationService.getAddressFromPosition(position);
      _mapProvider.updatePosition(position, address);
      _mapProvider.mapController.move(
        LatLng(position.latitude, position.longitude),
        15,
      );
    }
  }

  bool _isExpanded = false;

  Future<void> _checkLocationPermission() async {
    final permissionManager = context.read<PermissionInterface>();
    final hasPermission = await permissionManager.isPermissionGranted(PermissionType.location);
    
    if (!hasPermission && mounted) {
      // If somehow reached this screen without permission, go back
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Locatie toegang is nodig om deze pagina te gebruiken'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _handleLocationSelection(String location) async {
    setState(() {
      _selectedLocation = location;
      _isExpanded = false;  // Close dropdown after selection
    });
    
    if (location == LocationType.unknown.displayText) {
      final mapProvider = context.read<MapProvider>();
      mapProvider.clearSelectedLocation();
      mapProvider.currentPosition = null;
      mapProvider.currentAddress = LocationType.unknown.displayText;
      return;
    }
    
    if (location == LocationType.current.displayText) {
      final mapProvider = context.read<MapProvider>();
      mapProvider.setLoading(true);  // Start loading state
      
      // Clear the selected position first
      await mapProvider.clearSelectedLocation();
      
      // Then initialize map which will get current location
      await _initializeMap();
    } else if (location == LocationType.npZuidKennemerland.displayText) {
      // Clear current location data before navigating
      _mapProvider.currentPosition = null;
      _mapProvider.currentAddress = '';
      
      const LatLng zuidCenter = LatLng(52.3874, 4.5753);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            title: 'Nationaal Park Zuid-Kennemerland',
            mapWidget: LivingLabMapScreen(
              labName: 'Nationaal Park Zuid-Kennemerland',
              labCenter: zuidCenter,
              boundaryOffset: 0.018,
            ),
          ),
        ),
      );
    } else if (location == LocationType.grensparkKempenbroek.displayText) {
      // Clear current location data before navigating
      _mapProvider.currentPosition = null;
      _mapProvider.currentAddress = '';
      
      const LatLng grensparkCenter = LatLng(51.1950, 5.7230);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            title: 'Grenspark Kempen-Broek',
            mapWidget: LivingLabMapScreen(
              labName: 'Grenspark Kempen-Broek',
              labCenter: grensparkCenter,
              boundaryOffset: 0.045,
            ),
          ),
        ),
      );
    }
  }

  void _handleLocationIconTap() {
    debugPrint('Location icon tapped in LocationScreen');
  }

  @override
  Widget build(BuildContext context) {
    final dropdownInterface = context.read<DropdownInterface>();
    final screenWidth = MediaQuery.of(context).size.width;

    return PermissionGate(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: 'Locatie',
                rightIcon: Icons.menu,
                onLeftIconPressed: () => context.read<NavigationStateInterface>().pushReplacementBack(context, const Rapporteren()),
                onRightIconPressed: () {/* Handle menu */},
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        // Add Location header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selecteer locatie',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brown,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 160,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.brown.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Location dropdown
                        dropdownInterface.buildDropdown(
                          type: DropdownType.location,
                          selectedValue: _selectedLocation,
                          isExpanded: _isExpanded,
                          onExpandChanged: (value) => setState(() => _isExpanded = value),
                          onOptionSelected: _handleLocationSelection,
                          context: context,
                        ),
                        const SizedBox(height: 20),
                        // Location display with map preview
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const LocationMapPreview(),
                              LocationDisplay(
                                onLocationIconTap: _handleLocationIconTap,
                                locationText: context.watch<MapProvider>().selectedAddress,
                                isLoading: context.watch<MapProvider>().selectedAddress.isEmpty,
                                position: context.watch<MapProvider>().selectedPosition ?? context.watch<MapProvider>().currentPosition,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Date & Time section header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Datum en tijd',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brown,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 130,  // Increased from 120 to 140 for a bit more length
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.brown.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),  // Adjusted spacing after the header
                        TimeSelectionRow(
                          onOptionSelected: (selectedOption) {
                            debugPrint('Selected time option: $selectedOption');
                          },
                          onDateSelected: (date) {
                            debugPrint('Selected date: $date');
                          },
                          onTimeSelected: (time) {
                            debugPrint('Selected time: $time');
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(
          onBackPressed: () => context.read<NavigationStateInterface>().pushReplacementBack(context, const Rapporteren()),
          onNextPressed: () {
            // Handle next action
          },
          showNextButton: true,
          showBackButton: true,
        ),
      ),
    );
  }
}











