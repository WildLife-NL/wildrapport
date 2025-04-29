import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/screens/questionnaire/questionnaire_screen.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/location_screen-ui_widget.dart';
import 'package:wildrapport/widgets/permission_gate.dart';

class PossesionLocationScreen extends StatefulWidget {
  const PossesionLocationScreen({super.key});

  @override
  State<PossesionLocationScreen> createState() => _PossesionLocationScreenState();
}

class _PossesionLocationScreenState extends State<PossesionLocationScreen> {
  late final PossesionInterface _possesionManager;
  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';
  final blueLog = '\x1B[34m';
  final purpleLog = '\x1B[35m';
  late final PossesionDamageFormProvider possesionProvider;
  late final MapProvider mapProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint("$yellowLog[PossesionLocationScreen] 🔄 initState called\x1B[0m");
    _initializeScreen();  // Remove the post-frame callback
  }

  Future<void> _initializeScreen() async {
    if (!mounted) return;
    
    debugPrint("$yellowLog[PossesionLocationScreen] 🔄 Initializing screen\x1B[0m");
    
    try {
      _possesionManager = context.read<PossesionInterface>();
      possesionProvider = context.read<PossesionDamageFormProvider>();
      mapProvider = context.read<MapProvider>();
      
      if (!mapProvider.isInitialized) {
        debugPrint("$yellowLog[PossesionLocationScreen] 🔄 Initializing map provider\x1B[0m");
        await mapProvider.initialize();
      } else {
        debugPrint("$greenLog[PossesionLocationScreen] ✅ Map provider already initialized\x1B[0m");
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        debugPrint("$greenLog[PossesionLocationScreen] ✅ Screen initialized successfully\x1B[0m");
      }
    } catch (e) {
      debugPrint("$redLog[PossesionLocationScreen] ❌ Error initializing screen: $e\x1B[0m");
    }
  }

  void _handleNextPressed() async {
    final navigationManager = context.read<NavigationStateInterface>();
    debugPrint("$purpleLog[PossesionLocationScreen] ⚡ Next button callback triggered\x1B[0m");
    debugPrint("$yellowLog[PossesionLocationScreen] 🔍 Is screen initialized: $_isInitialized\x1B[0m");
    debugPrint("$yellowLog[PossesionLocationScreen] 🗺️ MapProvider initialized: ${mapProvider.isInitialized}\x1B[0m");
    
    // Force reinitialize map provider if needed
    if (!_isInitialized) {
      debugPrint("$yellowLog[PossesionLocationScreen] 🔄 Attempting to reinitialize screen\x1B[0m");
      await _initializeScreen();
      if (!_isInitialized) {
        debugPrint("$redLog[PossesionLocationScreen] ❌ Failed to initialize map\x1B[0m");
        return;
      }
    }
    
    final locationManager = context.read<LocationScreenInterface>();
    final locationInfo = await locationManager.getLocationAndDateTime(context);
    
    debugPrint("\n$blueLog[PossesionLocationScreen] 📍 Location and DateTime Info:\x1B[0m");
    debugPrint("$blueLog[PossesionLocationScreen] Current GPS Location: ${locationInfo['currentGpsLocation']}\x1B[0m");
    debugPrint("$blueLog[PossesionLocationScreen] Selected Location: ${locationInfo['selectedLocation']}\x1B[0m");

    if (locationInfo['selectedLocation'] == null) {
      debugPrint("$redLog[PossesionLocationScreen] ⚠️ No selected location found\x1B[0m");
      return;
    }

    // Update locations in possesion manager
    if (locationInfo['selectedLocation'] != null) {
      final selectedLocation = locationInfo['selectedLocation'];
      final reportLocation = ReportLocation(
        latitude: selectedLocation['latitude'],
        longtitude: selectedLocation['longitude'],
      );
      _possesionManager.updateUserLocation(reportLocation);
      debugPrint("$greenLog[PossesionLocationScreen] ✅ Updated user location\x1B[0m");
    }

    if (locationInfo['currentGpsLocation'] != null) {
      final currentLocation = locationInfo['currentGpsLocation'];
      final systemLocation = ReportLocation(
        latitude: currentLocation['latitude'],
        longtitude: currentLocation['longitude'],
      );
      _possesionManager.updateSystemLocation(systemLocation);
      debugPrint("$greenLog[PossesionLocationScreen] ✅ Updated system location\x1B[0m");
    }
    Questionnaire questionnaire = await _possesionManager.postInteraction();

    navigationManager.pushReplacementForward(
                    context,
                    const QuestionnaireScreen(),
                  );
    // Navigate to next screen or handle completion
    // Add your navigation logic here
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: 'Locatie',
                rightIcon: Icons.menu,
                onLeftIconPressed: () => context
                    .read<NavigationStateInterface>()
                    .pushReplacementBack(context, const Rapporteren()),
                onRightIconPressed: () {/* Handle menu */},
              ),
              Expanded(
                child: _isInitialized
                    ? const LocationScreenUIWidget()
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(
          onBackPressed: () => context
              .read<NavigationStateInterface>()
              .pushReplacementBack(context, const Rapporteren()),
          onNextPressed: () {
            debugPrint("$yellowLog[PossesionLocationScreen] 🔄 Next button pressed in build\x1B[0m");
            _handleNextPressed();
          },
          showNextButton: true,
          showBackButton: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Remove any map-related disposal
    super.dispose();
  }
}