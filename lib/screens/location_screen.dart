import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
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
        onNextPressed: () {
          // Get the current animal sighting from provider
          final animalSightingManager = context.read<AnimalSightingReportingInterface>();
          final currentSighting = animalSightingManager.getCurrentanimalSighting();
          
          // Check if location is set
          if (currentSighting?.locations == null || currentSighting!.locations!.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selecteer eerst een locatie'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          try {
            // Convert to API format
            final apiFormat = AnimalSightingConvertor.toApiFormat(currentSighting!);
            
            // Pretty print the API format in pink
            final pinkLog = '\x1B[95m';
            final resetLog = '\x1B[0m';
            
            debugPrint('$pinkLog[LocationScreen] Converting to API format:$resetLog');
            debugPrint('$pinkLog{$resetLog');
            apiFormat.forEach((key, value) {
              if (value is Map) {
                debugPrint('$pinkLog  "$key": {$resetLog');
                (value as Map).forEach((k, v) {
                  debugPrint('$pinkLog    "$k": $v,$resetLog');
                });
                debugPrint('$pinkLog  },$resetLog');
              } else if (value is List) {
                debugPrint('$pinkLog  "$key": [$resetLog');
                for (var item in value) {
                  debugPrint('$pinkLog    $item,$resetLog');
                }
                debugPrint('$pinkLog  ],$resetLog');
              } else {
                debugPrint('$pinkLog  "$key": $value,$resetLog');
              }
            });
            debugPrint('$pinkLog}$resetLog');

            // Continue with the original next pressed handler
            context
                .read<LocationScreenInterface>()
                .handleNextPressed(context);
          } catch (e) {
            final pinkLog = '\x1B[95m';
            final resetLog = '\x1B[0m';
            debugPrint('$pinkLog[LocationScreen] Error: $e$resetLog');
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




