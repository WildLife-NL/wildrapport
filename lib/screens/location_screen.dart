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

    // If there's a selected position, use it instead of getting current position
    if (_mapProvider.selectedPosition != null) {
      _mapProvider.updatePosition(
        _mapProvider.selectedPosition!,
        _mapProvider.selectedAddress,
      );
      // Move map to selected position
      _mapProvider.mapController.move(
        LatLng(
          _mapProvider.selectedPosition!.latitude,
          _mapProvider.selectedPosition!.longitude,
        ),
        15,
      );
    } else {
      final position = await _locationService.determinePosition();
      if (position != null && _locationService.isLocationInNetherlands(
        position.latitude,
        position.longitude,
      )) {
        final address = await _locationService.getAddressFromPosition(position);
        _mapProvider.updatePosition(position, address);
        // Move map to current position
        _mapProvider.mapController.move(
          LatLng(position.latitude, position.longitude),
          15,
        );
      }
    }
  }

  bool _isExpanded = false;
  bool _isDateTimeExpanded = false;
  String _selectedDateTime = DateTimeType.current.displayText;

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
    
    if (location == LocationType.current.displayText) {
      final mapProvider = context.read<MapProvider>();
      mapProvider.setLoading(true);  // Start loading state
      
      // Clear the selected position first
      await mapProvider.clearSelectedLocation();
      
      // Then initialize map which will get current location
      await _initializeMap();
      
      // Loading state will be set to false in updatePosition
    } else if (location == LocationType.npZuidKennemerland.displayText) {
      // Coordinates for National Park Zuid-Kennemerland
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
      // Coordinates for Grenspark from LivingLab2Map
      const LatLng grensparkCenter = LatLng(51.1950, 5.7230);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            title: 'Grenspark Kempen-Broek',
            mapWidget: LivingLabMapScreen(
              labName: 'Grenspark Kempen-Broek',
              labCenter: grensparkCenter,
              boundaryOffset: 0.045, // Using the larger boundary from LivingLab2Map
            ),
          ),
        ),
      );
    }
  }

  void _toggleDateTimeExpanded() {
    setState(() {
      _isDateTimeExpanded = !_isDateTimeExpanded;
    });
  }

  void _handleDateTimeSelection(String dateTime) {
    setState(() {
      _selectedDateTime = dateTime;
    });
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
                      crossAxisAlignment: CrossAxisAlignment.center, // Changed from start to center
                      children: [
                        const SizedBox(height: 40), // Increased from 20
                        // Location section header - centered and bigger
                        Center( // Added Center widget
                          child: Text(
                            'Selecteer je locatie',
                            style: TextStyle(
                              fontSize: 24, // Increased from 18
                              fontWeight: FontWeight.bold,
                              color: AppColors.brown,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24), // Increased from 12
                        // Location dropdown
                        dropdownInterface.buildDropdown(
                          type: DropdownType.location,
                          selectedValue: _selectedLocation,
                          isExpanded: _isExpanded,
                          onExpandChanged: (value) => setState(() => _isExpanded = value),
                          onOptionSelected: _handleLocationSelection,
                          context: context,
                        ),
                        const SizedBox(height: 32), // Increased from 20
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
                        const SizedBox(height: 32), // Increased from 24
                        // Date & Time section header
                        Text(
                          'Datum en tijd',
                          style: TextStyle(
                            fontSize: 24, // Increased from 18
                            fontWeight: FontWeight.bold,
                            color: AppColors.brown,
                          ),
                        ),
                        const SizedBox(height: 24), // Increased from 12
                        // DateTime dropdown
                        dropdownInterface.buildDropdown(
                          type: DropdownType.dateTime,
                          selectedValue: _selectedDateTime,
                          isExpanded: _isDateTimeExpanded,
                          onExpandChanged: (_) => _toggleDateTimeExpanded(),
                          onOptionSelected: _handleDateTimeSelection,
                          context: context,
                        ),
                        const SizedBox(height: 24), // Increased from 16
                        // Date and time cards remain the same...
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Handle date selection
                                },
                                child: Container(
                                  height: 60,
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 16.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Datum',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '24 Dec 2023',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 16.0),
                                        child: Icon(
                                          Icons.calendar_today,
                                          color: Colors.black54,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Handle time selection
                                },
                                child: Container(
                                  height: 60,
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
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 16.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Tijd',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '14:30',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 16.0),
                                        child: Icon(
                                          Icons.access_time,
                                          color: Colors.black54,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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

























