import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/screens/category_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/selection_button_group.dart';

class AnimalConditionScreen extends StatelessWidget {
  const AnimalConditionScreen({super.key});

  void _handleStatusSelection(BuildContext context, String status) {
    debugPrint('[AnimalConditionScreen] Handling status selection: $status');
    
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentanimalSighting = animalSightingManager.getCurrentanimalSighting();
    
    if (currentanimalSighting == null) {
      debugPrint('[AnimalConditionScreen] ERROR: No animalSighting model found when handling status selection');
      // Create a new animalSighting if none exists
      animalSightingManager.createanimalSighting();
    }
    
    // Map the selected status to AnimalCondition enum
    AnimalCondition selectedCondition;
    switch (status.toLowerCase()) {
      case 'gezond':
        selectedCondition = AnimalCondition.gezond;
        break;
      case 'ziek':
        selectedCondition = AnimalCondition.ziek;
        break;
      case 'dood':
        selectedCondition = AnimalCondition.dood;
        break;
      default:
        selectedCondition = AnimalCondition.andere;
    }

    try {
      debugPrint('[AnimalConditionScreen] Updating condition to: ${selectedCondition.toString()}');
      final updatedanimalSighting = animalSightingManager.updateCondition(selectedCondition);
      
      // Convert to JSON and highlight changes
      final oldJson = currentanimalSighting?.toJson() ?? {};
      final newJson = updatedanimalSighting.toJson();
      final greenStart = '\x1B[32m';
      final colorEnd = '\x1B[0m';
      
      final prettyJson = newJson.map((key, value) {
        final oldValue = oldJson[key];
        final isChanged = oldValue != value;
        final prettyValue = isChanged ? '$greenStart$value$colorEnd' : value;
        return MapEntry(key, prettyValue);
      });
      
      debugPrint('[AnimalConditionScreen] animalSighting state after update: $prettyJson');
      
      // Navigate to category screen
      debugPrint('[AnimalConditionScreen] Navigating to CategoryScreen');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CategoryScreen(),
        ),
      );
    } catch (e) {
      debugPrint('[AnimalConditionScreen] Error updating condition: $e');
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
    debugPrint('[AnimalConditionScreen] Building screen');
    
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentanimalSighting = animalSightingManager.getCurrentanimalSighting();
    
    if (currentanimalSighting == null) {
      debugPrint('[AnimalConditionScreen] ERROR: No animalSighting model found');
    } else {
      debugPrint('[AnimalConditionScreen] Current animalSighting state: ${currentanimalSighting.toJson()}');
    }
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Dier Conditie',
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                debugPrint('[AnimalConditionScreen] Navigating back and clearing animalSighting');
                // Get the manager and clear the animalSighting
                final animalSightingManager = context.read<AnimalSightingReportingInterface>();
                animalSightingManager.clearCurrentanimalSighting();
                Navigator.pop(context);
              },
              onRightIconPressed: () {
                debugPrint('[AnimalConditionScreen] Menu button pressed');
                /* Handle menu */
              },
            ),
            SelectionButtonGroup(
              buttons: const [
                (text: 'Gezond', icon: Icons.check_circle, imagePath: null),
                (text: 'Ziek', icon: Icons.sick, imagePath: null),
                (text: 'Dood', icon: Icons.dangerous, imagePath: null),
                (text: 'Andere', icon: Icons.more_horiz, imagePath: null),
              ],
              onStatusSelected: (status) => _handleStatusSelection(context, status),
              title: 'Selecteer dier Conditie',
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () {
          debugPrint('[AnimalConditionScreen] Back button pressed in bottom bar');
          // Also clear the animalSighting when using the bottom back button
          final animalSightingManager = context.read<AnimalSightingReportingInterface>();
          animalSightingManager.clearCurrentanimalSighting();
          Navigator.pop(context);
        },
        onNextPressed: () {
          debugPrint('[AnimalConditionScreen] Next button pressed in bottom bar');
          // Since no condition is selected yet, we can either disable the next button
          // or show a message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecteer eerst een conditie'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}







