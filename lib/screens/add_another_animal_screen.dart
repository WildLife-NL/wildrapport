import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/overzicht/action_buttons.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';

class AddAnotherAnimalScreen extends StatelessWidget {
  const AddAnotherAnimalScreen({super.key});

  void _handleButtonSelection(BuildContext context, String selection) {
    debugPrint('[AddAnotherAnimalScreen] Button selected: $selection');
    
    if (selection.toLowerCase() == 'overslaan') {
      final animalSightingManager = context.read<AnimalSightingReportingInterface>();
      
      try {
        // Log the state before finalizing
        final currentanimalSighting = animalSightingManager.getCurrentanimalSighting();
        debugPrint('[AddAnotherAnimalScreen] animalSighting before finalizing: ${currentanimalSighting?.toJson()}');

        // Finalize the current animal (adds to list and clears selected)
        final updatedanimalSighting = animalSightingManager.finalizeAnimal();
        debugPrint('[AddAnotherAnimalScreen] animalSighting after finalizing animal: ${updatedanimalSighting.toJson()}');
        
      } catch (e) {
        debugPrint('[AddAnotherAnimalScreen] Error finalizing animal: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Er is een fout opgetreden bij het verwerken van het dier'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    // Handle other button selections here if needed
  }

  List<({String text, String? imagePath, IconData? icon, VoidCallback onPressed})> _getAvailableButtons(
    BuildContext context,
    AnimalGender? existingGender,
  ) {
    final List<({String text, String? imagePath, IconData? icon, VoidCallback onPressed})> allButtons = [
      (
        text: 'Vrouwelijk',
        imagePath: 'assets/icons/gender/female_gender.png',
        icon: null,
        onPressed: () => _handleButtonSelection(context, 'vrouwelijk'),
      ),
      (
        text: 'Mannelijk',
        imagePath: 'assets/icons/gender/male_gender.png',
        icon: null,
        onPressed: () => _handleButtonSelection(context, 'mannelijk'),
      ),
      (
        text: 'Onbekend',
        imagePath: 'assets/icons/gender/unknown_gender.png',
        icon: null,
        onPressed: () => _handleButtonSelection(context, 'onbekend'),
      ),
      (
        text: 'Overslaan',
        imagePath: null,
        icon: Icons.double_arrow,
        onPressed: () => _handleButtonSelection(context, 'overslaan'),
      ),
    ];

    // Filter out the button that matches the existing gender
    return allButtons.where((button) {
      switch (existingGender) {
        case AnimalGender.vrouwelijk:
          return button.text != 'Vrouwelijk';
        case AnimalGender.mannelijk:
          return button.text != 'Mannelijk';
        case AnimalGender.onbekend:
          return button.text != 'Onbekend';
        case null:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentanimalSighting = animalSightingManager.getCurrentanimalSighting();
    final existingGender = currentanimalSighting?.animalSelected?.gender;
    
    debugPrint('[AddAnotherAnimalScreen] Building screen');
    debugPrint('[AddAnotherAnimalScreen] Current animalSighting: ${currentanimalSighting?.toJson()}');
    debugPrint('[AddAnotherAnimalScreen] Current animal gender: $existingGender');

    // Calculate responsive dimensions
    final double titleFontSize = screenSize.width * 0.05;
    final double minTitleSize = 18.0;
    final double maxTitleSize = 24.0;
    final double finalTitleSize = titleFontSize.clamp(minTitleSize, maxTitleSize);

    final double iconSize = screenSize.width * 0.18;
    final double minIconSize = 76.0;
    final double maxIconSize = 96.0;
    final double finalIconSize = iconSize.clamp(minIconSize, maxIconSize);

    final double buttonHeight = screenSize.height * 0.15;
    final double minButtonHeight = 100.0;
    final double maxButtonHeight = 120.0;
    final double finalButtonHeight = buttonHeight.clamp(minButtonHeight, maxButtonHeight);

    final double horizontalPadding = screenSize.width * 0.04;
    final double buttonSpacing = screenSize.height * 0.02;

    final availableButtons = _getAvailableButtons(context, existingGender);
    final skipButtonIndex = availableButtons.indexWhere((b) => b.text == 'Overslaan');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: 'Voeg dier toe',
                rightIcon: Icons.menu,
                onLeftIconPressed: () {
                  debugPrint('[AddAnotherAnimalScreen] Back button pressed');
                  Navigator.pop(context);
                },
                onRightIconPressed: () {
                  debugPrint('[AddAnotherAnimalScreen] Menu button pressed');
                },
              ),
              SizedBox(height: screenSize.height * 0.03),
              Text(
                'Selecteer optie',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: finalTitleSize,
                  color: Colors.brown,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              // Remove the outer Expanded widget and keep only this one
              Expanded(
                child: ActionButtons(
                  buttons: availableButtons,
                  useCircleIcons: false,
                  iconSize: finalIconSize,
                  verticalPadding: 0,
                  horizontalPadding: 0,
                  buttonSpacing: buttonSpacing,
                  buttonHeight: finalButtonHeight,
                  customIconColors: {skipButtonIndex: AppColors.darkGreen},
                  useCircleIconsForIndices: {skipButtonIndex},
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () {
          debugPrint('[AddAnotherAnimalScreen] Bottom back button pressed');
          Navigator.pop(context);
        },
        onNextPressed: () {},
        showNextButton: false,
        showBackButton: true,
      ),
    );
  }
}













