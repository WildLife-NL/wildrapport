import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/models/view_count_model.dart';
import 'package:wildrapport/screens/animal_amount_selection.dart';
import 'package:wildrapport/screens/animal_list_overview_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/overzicht/action_buttons.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';

class AddAnotherAnimalScreen extends StatelessWidget {
  const AddAnotherAnimalScreen({super.key});

  void _handleButtonSelection(BuildContext context, String selection) {
    final greenLog = '\x1B[32m';
    final resetLog = '\x1B[0m';
    debugPrint('${greenLog}[AddAnotherAnimalScreen] Button selected: $selection$resetLog');
    
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    
    try {
      if (selection.toLowerCase() == 'overslaan') {
        // Log the state before adding to list
        final currentanimalSighting = animalSightingManager.getCurrentanimalSighting();
        debugPrint('${greenLog}[AddAnotherAnimalScreen] State before adding to list: ${currentanimalSighting?.toJson()}$resetLog');
        
        // Add current animal to the list and clear it
        if (currentanimalSighting?.animalSelected != null) {
          final updatedAnimalSighting = animalSightingManager.finalizeAnimal(clearSelected: true);
          debugPrint('${greenLog}[AddAnotherAnimalScreen] State after adding to list: ${updatedAnimalSighting.toJson()}$resetLog');
        }

        // Navigate to the AnimalListOverviewScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnimalListOverviewScreen(),
          ),
        );
      } else {
        // Handle gender selection (vrouwelijk, mannelijk, onbekend)
        AnimalGender selectedGender;
        switch (selection.toLowerCase()) {
          case 'vrouwelijk':
            selectedGender = AnimalGender.vrouwelijk;
            break;
          case 'mannelijk':
            selectedGender = AnimalGender.mannelijk;
            break;
          case 'onbekend':
            selectedGender = AnimalGender.onbekend;
            break;
          default:
            throw StateError('Invalid gender selection');
        }

        final currentanimalSighting = animalSightingManager.getCurrentanimalSighting();
        if (currentanimalSighting?.animalSelected != null) {
          // Preserve the existing description when finalizing
          animalSightingManager.finalizeAnimal(clearSelected: false);  // This might be clearing the description
        }

        // Update the gender but keep the existing description
        animalSightingManager.updateGender(selectedGender);

        // Reset only view count for the next gender variation
        animalSightingManager.updateViewCount(ViewCountModel());

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AnimalAmountSelectionScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint('${greenLog}[AddAnotherAnimalScreen] Error processing animal: $e$resetLog');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er is een fout opgetreden bij het verwerken van het dier'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<({String text, String? imagePath, IconData? icon, VoidCallback onPressed})> _getAvailableButtons(
    BuildContext context,
    AnimalGender? existingGender,
  ) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    // Get all genders that are already used in the animals list
    final usedGenders = currentSighting?.animals
        ?.where((animal) => animal.animalName == currentSighting.animalSelected?.animalName)
        .map((animal) => animal.gender)
        .whereType<AnimalGender>()
        .toSet() ?? {};

    // If there's a currently selected animal's gender, add it to used genders
    if (existingGender != null) {
      usedGenders.add(existingGender);
    }

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
      // Only show skip button if not all genders are used
      if (usedGenders.length < 3) (
        text: 'Overslaan',
        imagePath: null,
        icon: Icons.double_arrow,
        onPressed: () => _handleButtonSelection(context, 'overslaan'),
      ),
    ];

    // Filter out buttons for genders that are already used
    return allButtons.where((button) {
      // Always show the "Overslaan" button if it exists
      if (button.text == 'Overslaan') return true;

      // Filter out buttons based on used genders
      switch (button.text) {
        case 'Vrouwelijk':
          return !usedGenders.contains(AnimalGender.vrouwelijk);
        case 'Mannelijk':
          return !usedGenders.contains(AnimalGender.mannelijk);
        case 'Onbekend':
          return !usedGenders.contains(AnimalGender.onbekend);
        default:
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






























