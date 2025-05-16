import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/belonging_damage_report_interface.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/belonging_damage_report_provider.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/screens/questionnaire/questionnaire_screen.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/location_screen_ui_widget.dart';
import 'package:wildrapport/widgets/permission_gate.dart';
import 'package:wildrapport/widgets/toasts/snack_bar_with_progress_bar.dart';

class BelongingLocationScreen extends StatefulWidget {
  const BelongingLocationScreen({super.key});

  @override
  State<BelongingLocationScreen> createState() =>
      _BelongingLocationScreenState();
}

class _BelongingLocationScreenState extends State<BelongingLocationScreen> {
  late final BelongingDamageReportInterface _belongingManager;
  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';
  final blueLog = '\x1B[34m';
  final purpleLog = '\x1B[35m';
  late final BelongingDamageReportProvider belongingProvider;
  late final MapProvider mapProvider;
  bool _isInitialized = false;

  NavigationStateInterface get navigationManager =>
      context.read<NavigationStateInterface>();

  @override
  void initState() {
    super.initState();
    debugPrint(
      "$yellowLog[BelongingLocationScreen] 🔄 initState called\x1B[0m",
    );
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    if (!mounted) return;

    debugPrint(
      "$yellowLog[BelongingLocationScreen] 🔄 Initializing screen\x1B[0m",
    );

    try {
      _belongingManager = context.read<BelongingDamageReportInterface>();
      belongingProvider = context.read<BelongingDamageReportProvider>();
      mapProvider = context.read<MapProvider>();

      if (!mapProvider.isInitialized) {
        debugPrint(
          "$yellowLog[BelongingLocationScreen] 🔄 Initializing map provider\x1B[0m",
        );
        await mapProvider.initialize();
      } else {
        debugPrint(
          "$greenLog[BelongingLocationScreen] ✅ Map provider already initialized\x1B[0m",
        );
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        debugPrint(
          "$greenLog[BelongingLocationScreen] ✅ Screen initialized successfully\x1B[0m",
        );
      }
    } catch (e) {
      debugPrint(
        "$redLog[BelongingLocationScreen] ❌ Error initializing screen: $e\x1B[0m",
      );
    }
  }

  void _handleNextPressed() async {
    debugPrint(
      "$yellowLog[BelongingLocationScreen] 🔄 Next button pressed\x1B[0m",
    );

    // Force reinitialize map provider if needed
    if (!_isInitialized) {
      await _initializeScreen();
      if (!_isInitialized) {
        return;
      }
    }

    // Reset map provider state
    final mapProvider = context.read<MapProvider>();

    final locationManager = context.read<LocationScreenInterface>();
    final locationInfo = await locationManager.getLocationAndDateTime(context);

    debugPrint(
      "\n$blueLog[BelongingLocationScreen] 📍 Location and DateTime Info:\x1B[0m",
    );
    debugPrint(
      "$blueLog[BelongingLocationScreen] Current GPS Location: ${locationInfo['currentGpsLocation']}\x1B[0m",
    );
    debugPrint(
      "$blueLog[BelongingLocationScreen] Selected Location: ${locationInfo['selectedLocation']}\x1B[0m",
    );

    if (locationInfo['selectedLocation'] == null) {
      debugPrint(
        "$redLog[BelongingLocationScreen] ⚠️ No selected location found\x1B[0m",
      );
      return;
    }

    // Update locations in possesion manager
    if (locationInfo['selectedLocation'] != null) {
      final selectedLocation = locationInfo['selectedLocation'];
      final reportLocation = ReportLocation(
        latitude: selectedLocation['latitude'],
        longtitude: selectedLocation['longitude'],
      );
      _belongingManager.updateUserLocation(reportLocation);
      debugPrint(
        "$greenLog[BelongingLocationScreen] ✅ Updated user location\x1B[0m",
      );
    }

    if (locationInfo['currentGpsLocation'] != null) {
      final currentLocation = locationInfo['currentGpsLocation'];
      final systemLocation = ReportLocation(
        latitude: currentLocation['latitude'],
        longtitude: currentLocation['longitude'],
      );
      _belongingManager.updateSystemLocation(systemLocation);
      debugPrint(
        "$greenLog[BelongingLocationScreen] ✅ Updated system location\x1B[0m",
      );
    }

    InteractionResponse? interactionResponseModel =
        await _belongingManager.postInteraction();

    if (mounted) {
      SnackBarWithProgressBar.show(
        context: context,
        message: (interactionResponseModel == null) 
          ? "Geen toegang tot internet, interactie opgeslagen in opslag van uw toestel" 
          : "interactie succesvol verstuurd",
        duration: const Duration(seconds: 3),
      );
      await Future.delayed(const Duration(seconds: 3));

      navigationManager.pushReplacementForward(
        context,
        interactionResponseModel != null
            ? QuestionnaireScreen(
              questionnaire: interactionResponseModel.questionnaire,
              interactionID: interactionResponseModel.interactionID,
            )
            : OverzichtScreen(),
      );
    }
    mapProvider.resetState();
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
                onLeftIconPressed: () {
                    belongingProvider.clearStateOfValues();
                    navigationManager.pushReplacementForward(
                      context,
                      const Rapporteren(),
                    );
                  },
                onRightIconPressed: () {
                  /* Handle menu */
                },
              ),
              Expanded(
                child:
                    _isInitialized
                        ? const LocationScreenUIWidget()
                        : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(
          onBackPressed:
              () => navigationManager.pushReplacementBack(
                context,
                const Rapporteren(),
              ),
          onNextPressed: _handleNextPressed,
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
