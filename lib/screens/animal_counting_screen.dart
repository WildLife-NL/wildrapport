import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/screens/animal_condition_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/animal_counting.dart';
import 'package:wildrapport/widgets/animal_list_table.dart';

class AnimalCountingScreen extends StatefulWidget {
  const AnimalCountingScreen({super.key});

  @override
  State<AnimalCountingScreen> createState() => _AnimalCountingScreenState();
}

class _AnimalCountingScreenState extends State<AnimalCountingScreen> {
  void _handleBackNavigation(BuildContext context) {
    final navigationManager = context.read<NavigationStateInterface>();
    navigationManager.pushReplacementBack(
      context,
      const AnimalConditionScreen(),
    );
  }

  void _handleAgeSelected(String age) {
    debugPrint('[AnimalCountingScreen] Selected age: $age');
  }

  void _handleAddToList(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    if (currentSighting != null) {
      setState(() {}); // Refresh the UI to show updated list
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
              centerText: 'Aantal Dieren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => _handleBackNavigation(context),
              onRightIconPressed: () {
                debugPrint('[AnimalCountingScreen] Menu button pressed');
              },
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimalCounting(
                      onAgeSelected: _handleAgeSelected,
                      onAddToList: () => _handleAddToList(context),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => _handleBackNavigation(context),
        onNextPressed: () {
          debugPrint('[AnimalCountingScreen] Next button pressed');
        },
        showNextButton: false,
      ),
    );
  }
}

