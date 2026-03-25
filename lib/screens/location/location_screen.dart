import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/reporting/interaction_interface.dart';
import 'package:wildrapport/interfaces/location/location_screen_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/models/beta_models/animal_sighting_report_wrapper.dart';
import 'package:wildrapport/models/beta_models/accident_report_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/models/beta_models/sighted_animal_model.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';
import 'package:wildrapport/models/enums/report_type.dart';
import 'package:wildrapport/models/enums/location_source.dart';
import 'package:wildrapport/models/beta_models/location_model.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/screens/waarneming/animal_list_overview_screen.dart';
import 'package:wildrapport/screens/waarneming/collision_details_screen.dart';
import 'package:wildrapport/screens/questionnaire/questionnaire_screen.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/utils/sighting_api_transformer.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/location_screen_ui_widget.dart';
import 'package:wildrapport/utils/toast_notification_handler.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? _pendingSnackBarMessage;
  Widget? _pendingNavigationScreen;

  void _handlePendingActions() {
    final screen = _pendingNavigationScreen;
    final message = _pendingSnackBarMessage;
    _pendingNavigationScreen = null;
    _pendingSnackBarMessage = null;

    if (screen == null) {
      if (mounted && message != null) {
        ToastNotificationHandler.sendToastNotification(context, message);
      }
      return;
    }

    if (!mounted) return;

    final rootNav = context.read<AppStateProvider>().navigatorKey.currentState ??
        Navigator.of(context, rootNavigator: true);
    rootNav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
    debugPrint('\x1B[32m[LocationScreen] Navigeer naar scherm (vragenlijst of hoofdpagina)\x1B[0m');

    if (message != null) {
      ToastNotificationHandler.sendToastNotification(context, message);
    }
  }

  Future<void> _handleNextPressed() async {
    final animalSightingManager =
        context.read<AnimalSightingReportingInterface>();
    final locationManager = context.read<LocationScreenInterface>();
    final interactionManager = context.read<InteractionInterface>();
    final mapProvider = context.read<MapProvider>();

    try {
      debugPrint(
        '\x1B[35m[LocationScreen] Starting location update process\x1B[0m',
      );

      final locationInfo = await locationManager.getLocationAndDateTime(
        context,
      );
      debugPrint('\x1B[35m[LocationScreen] LocationInfo: $locationInfo\x1B[0m');

      // 1. Require a location source: either user-selected OR current GPS
      final hasUserSelection = locationInfo['selectedLocation'] != null;
      final hasCurrentGps = locationInfo['currentGpsLocation'] != null;
      if (!hasUserSelection && !hasCurrentGps) {
        _pendingSnackBarMessage = 'Locatie niet beschikbaar. Schakel locatie in.';
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handlePendingActions(),
        );
        return;
      }

      final currentSighting = animalSightingManager.getCurrentanimalSighting();
      if (currentSighting == null) {
        throw StateError('No active animal sighting found');
      }

      // 2. update locations in the sighting
      if (locationInfo['currentGpsLocation'] != null) {
        final systemLocation = LocationModel(
          latitude: locationInfo['currentGpsLocation']['latitude'],
          longitude: locationInfo['currentGpsLocation']['longitude'],
          source: LocationSource.system,
        );
        animalSightingManager.updateLocation(systemLocation);
        debugPrint(
          '\x1B[35m[LocationScreen] Updated system location: ${systemLocation.latitude}, ${systemLocation.longitude}\x1B[0m',
        );
      }

      if (hasUserSelection) {
        final userLocation = LocationModel(
          latitude: locationInfo['selectedLocation']['latitude'],
          longitude: locationInfo['selectedLocation']['longitude'],
          source: LocationSource.manual,
        );
        animalSightingManager.updateLocation(userLocation);
        debugPrint(
          '\x1B[35m[LocationScreen] Updated user location: ${userLocation.latitude}, ${userLocation.longitude}\x1B[0m',
        );
      } else if (hasCurrentGps) {
        // No manual selection: default manual to current GPS so API has both
        final userLocation = LocationModel(
          latitude: locationInfo['currentGpsLocation']['latitude'],
          longitude: locationInfo['currentGpsLocation']['longitude'],
          source: LocationSource.manual,
        );
        animalSightingManager.updateLocation(userLocation);
        debugPrint(
          '\x1B[35m[LocationScreen] Defaulted manual location to current GPS\x1B[0m',
        );
      }

      // 3. update datetime in the sighting
      if (locationInfo['dateTime'] == null ||
          locationInfo['dateTime']['dateTime'] == null) {
        _pendingSnackBarMessage = 'Selecteer een datum en tijd';
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handlePendingActions(),
        );
        return;
      }

      final dateTimeStr = locationInfo['dateTime']['dateTime'];
      final dateTime = DateTime.parse(dateTimeStr);
      animalSightingManager.updateDateTime(dateTime);
      debugPrint('\x1B[35m[LocationScreen] Updated datetime: $dateTime\x1B[0m');

      // reset map provider state for next run
      mapProvider.resetState();

      // 🔴 4. CRUCIAL STEP FOR R4:
      // Make sure the grouped animal batches from AnimalCounting
      // are copied into currentSighting.animals so the API transformer
      // can build reportOfSighting.involvedAnimals.
      animalSightingManager.syncObservedAnimalsToSighting();
      debugPrint(
        '\x1B[35m[LocationScreen] Synced observed animals into sighting.animals\x1B[0m',
      );

      // 5. re-read the sighting AFTER sync
      final updatedSighting = animalSightingManager.getCurrentanimalSighting();

      // sanity check: we require datetime and at least one animal
      if (updatedSighting!.dateTime == null ||
          updatedSighting.dateTime!.dateTime == null) {
        _pendingSnackBarMessage = 'Datum en tijd zijn verplicht';
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handlePendingActions(),
        );
        return;
      }

      if (updatedSighting.animals == null || updatedSighting.animals!.isEmpty) {
        _pendingSnackBarMessage = 'Voeg eerst een dier toe aan de lijst';
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _handlePendingActions(),
        );
        return;
      }

      // 6. build the payload we are about to send
      final apiFormat = SightingApiTransformer.transformForApi(updatedSighting);
      debugPrint(
        '\x1B[35m[LocationScreen] Final API format (detailed):\x1B[0m',
      );
      debugPrint(const JsonEncoder.withIndent('  ').convert(apiFormat));

      // 7. send to backend
      final responseModel = await submitReport(
        animalSightingManager,
        interactionManager,
        context,
      );

      // 8. handle backend result
      if (responseModel != null) {
        final q = responseModel.questionnaire;
        final questionCount = q.questions?.length ?? 0;
        debugPrint(
          '\x1B[36m[LocationScreen] Questionnaire: id=${q.id}, name=${q.name}, questions=$questionCount\x1B[0m',
        );
        final rootNav = context.read<AppStateProvider>().navigatorKey.currentState;
        final Widget targetScreen;
        final String? toastMessage;
        debugPrint(
          '\x1B[35m========== WAARNEMING VERSTUURD ========== questions=$questionCount → ${questionCount > 0 ? "Vragenlijst" : "Hoofdpagina"}\x1B[0m',
        );
        if (questionCount == 0) {
          debugPrint(
            '\x1B[33m[LocationScreen] Geen vragen → hoofdpagina\x1B[0m',
          );
          toastMessage = 'Melding succesvol verstuurd';
          targetScreen = const MainNavScreen();
        } else {
          debugPrint(
            '\x1B[34m[LocationScreen] Toon vragenlijst: ${q.name} ($questionCount vragen)\x1B[0m',
          );
          toastMessage = null;
          targetScreen = QuestionnaireScreen(
            questionnaire: responseModel.questionnaire,
            interactionID: responseModel.interactionID,
          );
        }

        if (rootNav != null) {
          debugPrint('\x1B[32m[LocationScreen] Navigeer direct naar ${questionCount > 0 ? "vragenlijst" : "hoofdpagina"}\x1B[0m');
          rootNav.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => targetScreen),
            (route) => false,
          );
          if (toastMessage != null && mounted) {
            ToastNotificationHandler.sendToastNotification(context, toastMessage);
          }
        } else {
          _pendingSnackBarMessage = toastMessage;
          _pendingNavigationScreen = targetScreen;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _handlePendingActions(),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('\x1B[31m[LocationScreen] Error: $e\x1B[0m');
      debugPrint('\x1B[31m[LocationScreen] Stack trace: $stackTrace\x1B[0m');
      _pendingSnackBarMessage = 'Er is een fout opgetreden: $e';
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _handlePendingActions(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: null,
              centerText: 'Locatie',
              rightIcon: null,
              showUserIcon: false,
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            Expanded(child: const LocationScreenUIWidget()),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () {
          final navigationManager = context.read<NavigationStateInterface>();
          final appStateProvider = context.read<AppStateProvider>();
          final reportType = appStateProvider.currentReportType;

          // For collision flow, go back to collision details screen
          if (reportType == ReportType.verkeersongeval) {
            navigationManager.pushReplacementBack(
              context,
              const CollisionDetailsScreen(),
            );
          } else {
            // For other flows, go back to animal list overview
            // Clear remarks before returning to overview
            final animalSightingManager =
                context.read<AnimalSightingReportingInterface>();
            animalSightingManager.updateDescription('');
            navigationManager.pushReplacementBack(
              context,
              AnimalListOverviewScreen(),
            );
          }
        },
        onNextPressed: _handleNextPressed,
        showNextButton: true,
        showBackButton: true,
      ),
    );
  }
}

Future<InteractionResponse?> submitReport(
  AnimalSightingReportingInterface animalSightingManager,
  InteractionInterface interactionManager,
  BuildContext context,
) async {
  try {
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    if (currentSighting == null) {
      throw StateError('No active animal sighting found');
    }

    // Get the current report type from app state
    final appStateProvider = context.read<AppStateProvider>();
    final reportType = appStateProvider.currentReportType;

    // Map ReportType to InteractionType
    final interactionType = switch (reportType) {
      ReportType.waarneming => InteractionType.waarneming,
      ReportType.gewasschade => InteractionType.gewasschade,
      ReportType.verkeersongeval => InteractionType.verkeersongeval,
      null => InteractionType.waarneming, // Default fallback
    };

    debugPrint(
      '\x1B[36m[LocationScreen] Using report type: $reportType -> interaction type: $interactionType\x1B[0m',
    );

    // Build the appropriate report wrapper based on report type
    final dynamic reportWrapper;
    if (interactionType == InteractionType.verkeersongeval) {
      // For vehicle collision, we need to build an AccidentReport
      reportWrapper = _buildAccidentReportFromSighting(currentSighting);
      debugPrint(
        '\x1B[36m[LocationScreen] Built AccidentReport for verkeersongeval\x1B[0m',
      );
    } else {
      // For waarneming (sighting), use the existing wrapper
      reportWrapper = AnimalSightingReportWrapper(currentSighting);
      debugPrint(
        '\x1B[36m[LocationScreen] Built AnimalSightingReportWrapper for waarneming\x1B[0m',
      );
    }

    final InteractionResponse? response = await interactionManager
        .postInteraction(reportWrapper, interactionType);
    if (response != null) {
      if (response.questionnaire.questions != null &&
          response.questionnaire.questions!.isNotEmpty) {
        debugPrint(
          '\x1B[32m[LocationScreen] Questionnaire has ${response.questionnaire.questions!.length} questions\x1B[0m',
        );
      } else {
        debugPrint(
          '\x1B[33m[LocationScreen] Questionnaire has no questions\x1B[0m',
        );
      }
    }
    return response;
  } catch (e) {
    rethrow;
  }
}

AccidentReport _buildAccidentReportFromSighting(dynamic sighting) {
  // Extract locations
  // Prefer system location if available, fall back to manual if GPS wasn't acquired
  
  LocationModel? systemLocation;
  LocationModel? manualLocation;
  
  // Find system location
  try {
    systemLocation = sighting.locations!.firstWhere(
      (loc) => loc.source == LocationSource.system,
    );
  } catch (e) {
    // System location not found, will try manual
    systemLocation = null;
  }
  
  // Find manual location
  try {
    manualLocation = sighting.locations!.firstWhere(
      (loc) => loc.source == LocationSource.manual,
    );
  } catch (e) {
    // Manual location not found, will try system
    manualLocation = null;
  }
  
  // Use system if available, otherwise use manual
  final LocationModel? finalSystemLocationNullable = systemLocation ?? manualLocation;
  if (finalSystemLocationNullable == null) {
    throw StateError('At least one location (system or manual) is required');
  }
  final LocationModel finalSystemLocation = finalSystemLocationNullable;
  
  if (systemLocation == null && manualLocation != null) {
    debugPrint('⚠️ System location not available for accident report, using manual location as fallback');
  }
  
  // For manual, prefer actual manual selection, but fallback to system if not available
  final LocationModel finalManualLocation = manualLocation ?? finalSystemLocation;

  // Convert locations to ReportLocation format
  final systemReportLocation = ReportLocation(
    latitude: finalSystemLocation.latitude,
    longtitude: finalSystemLocation.longitude,
  );
  final manualReportLocation = ReportLocation(
    latitude: finalManualLocation.latitude,
    longtitude: finalManualLocation.longitude,
  );

  // Transform animals to SightedAnimal format (same logic as SightingApiTransformer)
  final List<SightedAnimal> sightedAnimals = [];
  for (final animal in sighting.animals!) {
    final condition = animal.condition?.toString().split('.').last ?? 'other';
    final mappedCondition = _mapCondition(condition);

    for (final genderView in animal.genderViewCounts) {
      final genderString = genderView.gender.toString().split('.').last;
      final sex = _mapSex(genderString);

      void addEntries(int amount, String ageKey) {
        if (amount > 0) {
          final lifeStage = _mapLifeStage(ageKey);
          for (int i = 0; i < amount; i++) {
            sightedAnimals.add(
              SightedAnimal(
                condition: mappedCondition,
                lifeStage: lifeStage,
                sex: sex,
              ),
            );
          }
        }
      }

      addEntries(genderView.viewCount.pasGeborenAmount, 'pasGeborenAmount');
      addEntries(genderView.viewCount.onvolwassenAmount, 'onvolwassenAmount');
      addEntries(genderView.viewCount.volwassenAmount, 'volwassenAmount');
      addEntries(genderView.viewCount.unknownAmount, 'unknownAmount');
    }
  }

  return AccidentReport(
    description: sighting.description ?? '',
    damages:
        '0', // Default damage value - will be converted to 0 (number) in toJson()
    animals: sightedAnimals,
    suspectedSpeciesID: sighting.animalSelected?.animalId,
    userSelectedLocation: manualReportLocation,
    systemLocation: systemReportLocation,
    userSelectedDateTime: sighting.dateTime?.dateTime,
    systemDateTime: sighting.dateTime?.dateTime ?? DateTime.now(),
    intensity: 'medium', // Default to medium intensity
    urgency: 'medium', // Default to medium urgency
  );
}

String _mapCondition(String condition) {
  switch (condition.toLowerCase()) {
    case 'gezond':
      return 'healthy';
    case 'ziek':
      return 'impaired';
    case 'dood':
      return 'dead';
    default:
      return 'other';
  }
}

String _mapSex(String genderEnum) {
  switch (genderEnum.toLowerCase()) {
    case 'vrouwelijk':
      return 'female';
    case 'mannelijk':
      return 'male';
    case 'onbekend':
    default:
      return 'unknown';
  }
}

String _mapLifeStage(String ageKey) {
  switch (ageKey) {
    case 'pasGeborenAmount':
      return 'infant';
    case 'onvolwassenAmount':
      return 'adolescent';
    case 'volwassenAmount':
      return 'adult';
    case 'unknownAmount':
    default:
      return 'unknown';
  }
}
