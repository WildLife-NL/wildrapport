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
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/location_display.dart';
import 'package:wildrapport/widgets/permission_gate.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late final LocationServiceInterface _locationService;
  
  @override
  void initState() {
    super.initState();
    _locationService = LocationMapManager();
    // Use addPostFrameCallback to schedule the initialization after the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    final mapProvider = context.read<MapProvider>();
    if (!mapProvider.isInitialized) {
      mapProvider.initialize();
      
      final position = await _locationService.determinePosition();
      if (position != null && _locationService.isLocationInNetherlands(
        position.latitude,
        position.longitude,
      )) {
        final address = await _locationService.getAddressFromPosition(position);
        mapProvider.updatePosition(position, address);
      }
    }
  }

  bool _isExpanded = false;
  bool _isDateTimeExpanded = false;
  String _selectedLocation = LocationType.current.displayText;
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

  void _handleLocationSelection(String location) {
    setState(() {
      _selectedLocation = location;
    });
    
    // Check if "Kies op de kaart" is selected
    if (location == LocationType.map.displayText) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MapScreen(),
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
                          onExpandChanged: (_) => _toggleExpanded(),
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
                              // Map preview placeholder
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15),
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.map,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              // Location display
                              LocationDisplay(
                                onLocationIconTap: _handleLocationIconTap,
                                locationText: 'Huidige locatie wordt geladen...',
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





