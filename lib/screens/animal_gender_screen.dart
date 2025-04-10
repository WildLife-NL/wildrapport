import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/models/waarneming_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/screens/animal_amount_selection.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/split_row_container.dart';
import 'package:wildrapport/widgets/compact_animal_display.dart';
import 'package:wildrapport/widgets/overzicht/action_buttons.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';

class AnimalGenderScreen extends StatelessWidget {
  const AnimalGenderScreen({super.key});

  void _handleGenderSelection(BuildContext context, AnimalGender selectedGender) {
    debugPrint('[AnimalGenderScreen] Gender selected: ${selectedGender.toString()}');
    
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    
    try {
      // Update the gender using the manager
      waarnemingManager.updateGender(selectedGender);
      
      debugPrint('[AnimalGenderScreen] Successfully updated gender');

      // Navigate to the amount selection screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AnimalAmountSelectionScreen(),
        ),
      );
    } catch (e) {
      debugPrint('[AnimalGenderScreen] Error updating gender: $e');
      // Show error dialog or snackbar to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Er is een fout opgetreden bij het bijwerken van het geslacht'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[AnimalGenderScreen] Building screen');
    
    final waarnemingManager = context.read<WaarnemingReportingInterface>();
    final waarneming = waarnemingManager.getCurrentWaarneming();
    
    if (waarneming == null) {
      debugPrint('[AnimalGenderScreen] ERROR: No waarneming found');
      return const Scaffold(
        body: Center(
          child: Text('Error: No waarneming found'),
        ),
      );
    }

    debugPrint('[AnimalGenderScreen] Current waarneming state: ${waarneming.toJson()}');

    final animal = waarneming.animalSelected;
    
    if (animal == null) {
      debugPrint('[AnimalGenderScreen] ERROR: No selected animal found in waarneming model');
      return const Scaffold(
        body: Center(
          child: Text('Error: No animal data found'),
        ),
      );
    }

    debugPrint('[AnimalGenderScreen] Using animal: {animalName: ${animal.animalName}, animalImagePath: ${animal.animalImagePath}}');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: 'Geslacht',
                rightIcon: Icons.menu,
                onLeftIconPressed: () {
                  debugPrint('[AnimalGenderScreen] Back button pressed');
                  Navigator.pop(context);
                },
                onRightIconPressed: () {
                  debugPrint('[AnimalGenderScreen] Menu button pressed');
                  /* Handle menu */
                },
              ),
              const SizedBox(height: 16),
              SplitRowContainer(
                rightWidget: CompactAnimalDisplay(animal: animal),
              ),
              const SizedBox(height: 24),
              Text(
                'Selecteer geslacht',
                style: AppTextTheme.textTheme.titleLarge?.copyWith(
                  color: AppColors.brown,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ActionButtons(
                buttons: [
                  (
                    text: 'Vrouwelijk',
                    imagePath: 'assets/icons/gender/female_gender.png',
                    icon: null,
                    onPressed: () {
                      debugPrint('[AnimalGenderScreen] Female gender selected');
                      _handleGenderSelection(context, AnimalGender.vrouwelijk);
                    },
                  ),
                  (
                    text: 'Mannelijk',
                    imagePath: 'assets/icons/gender/male_gender.png',
                    icon: null,
                    onPressed: () {
                      debugPrint('[AnimalGenderScreen] Male gender selected');
                      _handleGenderSelection(context, AnimalGender.mannelijk);
                    },
                  ),
                  (
                    text: 'Onbekend',
                    imagePath: 'assets/icons/gender/unknown_gender.png',
                    icon: null,
                    onPressed: () {
                      debugPrint('[AnimalGenderScreen] Unknown gender selected');
                      _handleGenderSelection(context, AnimalGender.onbekend);
                    },
                  ),
                ],
                useCircleIcons: false,
                iconSize: 76,
                verticalPadding: 0,
                horizontalPadding: 0,
                buttonSpacing: 14,
                buttonHeight: 120,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () {
          debugPrint('[AnimalGenderScreen] Bottom back button pressed');
          Navigator.pop(context);
        },
        onNextPressed: () {
          debugPrint('[AnimalGenderScreen] Next button pressed');
        },
        showNextButton: false,  // Hide the next button
      ),
    );
  }
}



























