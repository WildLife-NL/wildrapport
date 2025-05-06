import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/api/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';
import 'package:wildrapport/models/beta_models/animal_sighting_report_wrapper.dart';
import 'package:wildrapport/models/beta_models/interaction_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';
import 'package:wildrapport/models/enums/location_source.dart';
import 'package:wildrapport/models/location_model.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/screens/questionnaire/questionnaire_screen.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/utils/sighting_api_transformer.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/location_screen_ui_widget.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: const LocationScreenUIWidget(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 60, // Constrain height to avoid SnackBar overlap
        child: CustomBottomAppBar(
          onBackPressed: () => context
              .read<NavigationStateInterface>()
              .pushReplacementBack(context, const Rapporteren()),
          onNextPressed: () async {
            final animalSightingManager = context.read<AnimalSightingReportingInterface>();
            final locationManager = context.read<LocationScreenInterface>();
            final mapProvider = context.read<MapProvider>();

            try {
              debugPrint('\x1B[35m[LocationScreen] Starting location update process\x1B[0m');              
              final locationInfo = await locationManager.getLocationAndDateTime(context);
              debugPrint('\x1B[35m[LocationScreen] LocationInfo: $locationInfo\x1B[0m');

              if (locationInfo['selectedLocation'] == null) {
                debugPrint('\x1B[31m[LocationScreen] No location selected\x1B[0m');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selecteer eerst een locatie'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.fixed,
                  ),
                );
                return;
              }

              final currentSighting = animalSightingManager.getCurrentanimalSighting();
              if (currentSighting == null) {
                throw StateError('No active animal sighting found');
              }

              debugPrint('\x1B[35m[LocationScreen] Updating locations in animal sighting model\x1B[0m');

              if (locationInfo['currentGpsLocation'] != null) {
                final systemLocation = LocationModel(
                  latitude: locationInfo['currentGpsLocation']['latitude'],
                  longitude: locationInfo['currentGpsLocation']['longitude'],
                  source: LocationSource.system,
                );
                animalSightingManager.updateLocation(systemLocation);
                debugPrint('\x1B[35m[LocationScreen] Updated system location: ${systemLocation.latitude}, ${systemLocation.longitude}\x1B[0m');
              }

              if (locationInfo['selectedLocation'] != null) {
                final userLocation = LocationModel(
                  latitude: locationInfo['selectedLocation']['latitude'],
                  longitude: locationInfo['selectedLocation']['longitude'],
                  source: LocationSource.manual,
                );
                animalSightingManager.updateLocation(userLocation);
                debugPrint('\x1B[35m[LocationScreen] Updated user location: ${userLocation.latitude}, ${userLocation.longitude}\x1B[0m');
              }

              if (locationInfo['dateTime'] != null && 
                  locationInfo['dateTime']['dateTime'] != null) {
                final dateTimeStr = locationInfo['dateTime']['dateTime'];
                final dateTime = DateTime.parse(dateTimeStr);
                animalSightingManager.updateDateTime(dateTime);
                debugPrint('\x1B[35m[LocationScreen] Updated datetime: $dateTime\x1B[0m');
                 mapProvider.resetState();

              } else {
                debugPrint('\x1B[31m[LocationScreen] No datetime provided in locationInfo\x1B[0m');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Selecteer een datum en tijd'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.fixed,
                  ),
                );
                return;
              }

              final updatedSighting = animalSightingManager.getCurrentanimalSighting();
              if (updatedSighting!.dateTime == null || updatedSighting.dateTime!.dateTime == null) {
                debugPrint('\x1B[31m[LocationScreen] DateTime is still null after update\x1B[0m');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Datum en tijd zijn verplicht'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.fixed,
                  ),
                );
                return;
              }

              final apiFormat = SightingApiTransformer.transformForApi(updatedSighting);

              debugPrint('\x1B[35m[LocationScreen] Final API format (detailed):\x1B[0m');
              debugPrint(const JsonEncoder.withIndent('  ').convert(apiFormat));

              final questionnaire = await submitReport(context);
              
              // Check if questionnaire has valid content
              if (questionnaire.questions == null || questionnaire.questions!.isEmpty) {
                debugPrint('\x1B[31m[LocationScreen] Received empty questionnaire\x1B[0m');
                // Navigate back to Rapporteren if no questions
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Geen vragen beschikbaar voor deze melding'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  context.read<NavigationStateInterface>().pushReplacementBack(context, const Rapporteren());
                }
              } else {
                debugPrint('\x1B[34m[LocationScreen] Received valid questionnaire: ${questionnaire.name}\x1B[0m');
                // Navigate to questionnaire screen with the response
                if (mounted) {
                  context.read<NavigationStateInterface>().pushReplacementForward(
                    context,
                    QuestionnaireScreen(questionnaire: questionnaire),
                  );
                }
              }
            } catch (e, stackTrace) {
              debugPrint('\x1B[31m[LocationScreen] Error: $e\x1B[0m');
              debugPrint('\x1B[31m[LocationScreen] Stack trace: $stackTrace\x1B[0m');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Er is een fout opgetreden: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.fixed,
                ),
              );
            }
          },
          showNextButton: true,
          showBackButton: true,
        ),
      ),
    );
  }
}

Future<Questionnaire> submitReport(BuildContext context) async {
  try {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();

    if (currentSighting == null) {
      throw StateError('No active animal sighting found');
    }

    // Create the interaction object using the wrapper
    final interaction = Interaction(
      interactionType: InteractionType.waarnemning,
      userID: "your-user-id-here",
      report: AnimalSightingReportWrapper(currentSighting),
    );

    final interactionAPI = context.read<InteractionApiInterface>();
    final response = await interactionAPI.sendInteraction(interaction);

    // Log questionnaire details for debugging
    if (response.questions != null && response.questions!.isNotEmpty) {
      debugPrint('\x1B[32m[LocationScreen] Questionnaire has ${response.questions!.length} questions\x1B[0m');
    } else {
      debugPrint('\x1B[33m[LocationScreen] Questionnaire has no questions\x1B[0m');
    }

    return response;
  } catch (e) {
    // Error handling...
    rethrow;
  }
}










