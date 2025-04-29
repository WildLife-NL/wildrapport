import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/models/enums/location_source.dart';
import 'package:wildrapport/models/location_model.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/location_screen-ui_widget.dart';
import 'package:wildrapport/utils/animal_sighting_convertor.dart';

class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

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
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => context
            .read<NavigationStateInterface>()
            .pushReplacementBack(context, const Rapporteren()),
        onNextPressed: () async {
          final animalSightingManager = context.read<AnimalSightingReportingInterface>();
          final locationManager = context.read<LocationScreenInterface>();
          
          try {
            debugPrint('\x1B[35m[LocationScreen] Starting location update process\x1B[0m');
            
            // Get location and datetime information once
            final locationInfo = await locationManager.getLocationAndDateTime(context);
            
            if (locationInfo['selectedLocation'] == null) {
              debugPrint('\x1B[31m[LocationScreen] No location selected\x1B[0m');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Selecteer eerst een locatie'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final currentSighting = animalSightingManager.getCurrentanimalSighting();
            if (currentSighting == null) {
              throw StateError('No active animal sighting found');
            }

            debugPrint('\x1B[35m[LocationScreen] Updating locations in animal sighting model\x1B[0m');

            // Update locations
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

            // Update datetime
            if (locationInfo['dateTimeInfo'] != null) {
              final dateTimeStr = locationInfo['dateTimeInfo']['dateTime'];
              if (dateTimeStr != null) {
                final dateTime = DateTime.parse(dateTimeStr);
                animalSightingManager.updateDateTime(dateTime);
                debugPrint('\x1B[35m[LocationScreen] Updated datetime: $dateTime\x1B[0m');
              }
            }

            // Convert to API format
            final updatedSighting = animalSightingManager.getCurrentanimalSighting();
            final apiFormat = AnimalSightingConvertor.toApiFormat(updatedSighting!);

            debugPrint('\x1B[35m[LocationScreen] Final API format (detailed):\x1B[0m');
            debugPrint('\x1B[35m- Description: ${apiFormat['description']}\x1B[0m');
            debugPrint('\x1B[35m- Location: ${apiFormat['location']}\x1B[0m');
            debugPrint('\x1B[35m- Moment: ${apiFormat['moment']}\x1B[0m');
            debugPrint('\x1B[35m- Place: ${apiFormat['place']}\x1B[0m');
            
            final reportOfSighting = apiFormat['reportOfSighting'] as Map<String, dynamic>;
            debugPrint('\x1B[35m- Report ID: ${reportOfSighting['sightingReportID']}\x1B[0m');
            
            final involvedAnimals = reportOfSighting['involvedAnimals'] as List;
            debugPrint('\x1B[35m- Number of involved animals: ${involvedAnimals.length}\x1B[0m');
            
            for (var i = 0; i < involvedAnimals.length; i++) {
              debugPrint('\x1B[35m  Animal $i: ${involvedAnimals[i]}\x1B[0m');
            }

            // Navigate to next screen
            context
                .read<NavigationStateInterface>()
                .pushReplacementBack(context, const Rapporteren());
            
          } catch (e, stackTrace) {
            debugPrint('\x1B[31m[LocationScreen] Error: $e\x1B[0m');
            debugPrint('\x1B[31m[LocationScreen] Stack trace: $stackTrace\x1B[0m');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Er is een fout opgetreden: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        showNextButton: true,
        showBackButton: true,
      ),
    );
  }
}




