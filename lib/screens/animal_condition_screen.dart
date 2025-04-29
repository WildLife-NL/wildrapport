import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/screens/category_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/invisible_map_preloader.dart'; // ✅ import preloader
import 'package:wildrapport/widgets/selection_button_group.dart';

class AnimalConditionScreen extends StatelessWidget {
  const AnimalConditionScreen({super.key});

  void _handleStatusSelection(BuildContext context, String status) {
    final greenLog = '\x1B[32m';
    final resetLog = '\x1B[0m';

    debugPrint('${greenLog}[AnimalConditionScreen] Handling status selection: $status$resetLog');

    final animalSightingManager = context.read<AnimalSightingReportingInterface>();

    try {
      final updatedSighting = animalSightingManager.updateConditionFromString(status);
      debugPrint('${greenLog}[AnimalConditionScreen] Successfully updated condition to: $status$resetLog');
      debugPrint('${greenLog}[AnimalConditionScreen] Current animal sighting state: ${updatedSighting.toJson()}$resetLog');

      final navigationManager = context.read<NavigationStateInterface>();
      // Use push instead of pushReplacement
      navigationManager.pushForward(context, const CategoryScreen());
    } catch (e) {
      debugPrint('${greenLog}[AnimalConditionScreen] Error updating condition: $e$resetLog');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er is een fout opgetreden bij het bijwerken van de conditie'),
          backgroundColor: Colors.red,
        ),
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
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Dier Conditie',
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                final navigationManager = context.read<NavigationStateInterface>();
                navigationManager.resetToHome(context);
              },
              onRightIconPressed: () {
                debugPrint('[AnimalConditionScreen] Menu button pressed');
              },
            ),

            Expanded(  // Wrap content in Expanded
              child: Column(
                children: [
                  // 🟢 Selection UI
                  SelectionButtonGroup(
                    buttons: AnimalSightingReportingInterface.conditionButtons,
                    onStatusSelected: (status) => _handleStatusSelection(context, status),
                    title: 'Selecteer dier Conditie',
                  ),

                  // 🟡 Invisible Map Preloader
                  const InvisibleMapPreloader(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


