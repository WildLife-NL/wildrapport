import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/screens/category_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/compact_animal_display.dart';
import 'package:wildrapport/widgets/selection_button_group.dart';
import 'package:collection/collection.dart';

class AnimalConditionScreen extends StatelessWidget {
  const AnimalConditionScreen({super.key});

  void _handleStatusSelection(BuildContext context, String status) {
    debugPrint('[AnimalConditionScreen] Handling status selection: $status');
    
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    final currentWaarneming = waarnemingManager.getCurrentWaarneming();
    
    if (currentWaarneming == null) {
      debugPrint('[AnimalConditionScreen] ERROR: No waarneming model found when handling status selection');
      return;
    }
    
    debugPrint('[AnimalConditionScreen] Current waarneming state before update: ${currentWaarneming.toJson()}');
    
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

    debugPrint('[AnimalConditionScreen] Updating condition to: ${selectedCondition.toString()}');
    final updatedWaarneming = waarnemingManager.updateCondition(selectedCondition);
    debugPrint('[AnimalConditionScreen] Waarneming state after update: ${updatedWaarneming.toJson()}');
    
    // Navigate to category screen
    debugPrint('[AnimalConditionScreen] Navigating to CategoryScreen');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[AnimalConditionScreen] Building screen');
    
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    final currentWaarneming = waarnemingManager.getCurrentWaarneming();
    
    if (currentWaarneming == null) {
      debugPrint('[AnimalConditionScreen] ERROR: No waarneming model found');
    } else {
      debugPrint('[AnimalConditionScreen] Current waarneming state: ${currentWaarneming.toJson()}');
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
                debugPrint('[AnimalConditionScreen] Navigating back');
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



