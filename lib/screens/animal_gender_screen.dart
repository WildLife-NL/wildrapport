import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/screens/animal_amount_selection.dart';
import 'package:wildrapport/screens/report_decision_screen.dart';
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
    final orangeLog = '\x1B[38;5;208m';
    final resetLog = '\x1B[0m';
    
    debugPrint('${orangeLog}[AnimalGenderScreen] Gender selected: ${selectedGender.toString()}$resetLog');
    
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final navigationManager = context.read<NavigationStateInterface>();
    
    if (animalSightingManager.handleGenderSelection(selectedGender)) {
      navigationManager.pushReplacementForward(
        context,
        const AnimalAmountSelectionScreen(),
      );
    } else {
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
    final orangeLog = '\x1B[38;5;208m';
    final resetLog = '\x1B[0m';
    
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final navigationManager = context.read<NavigationStateInterface>();
    
    if (!animalSightingManager.validateActiveAnimalSighting()) {
      debugPrint('${orangeLog}[AnimalGenderScreen] ERROR: No valid animal sighting$resetLog');
      return const Scaffold(
        body: Center(
          child: Text('Error: No animal data found'),
        ),
      );
    }

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
                  debugPrint('${orangeLog}[AnimalGenderScreen] Back button pressed$resetLog');
                  navigationManager.pushReplacementBack(
                    context,
                    const ReportDecisionScreen(),
                  );
                },
                onRightIconPressed: () {
                  debugPrint('${orangeLog}[AnimalGenderScreen] Menu button pressed$resetLog');
                },
              ),
              const SizedBox(height: 16),
              SplitRowContainer(
                rightWidget: CompactAnimalDisplay(
                  animal: animalSightingManager.getCurrentanimalSighting()!.animalSelected!,
                ),
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
          debugPrint('${orangeLog}[AnimalGenderScreen] Bottom back button pressed$resetLog');
          navigationManager.pushReplacementBack(
            context,
            const ReportDecisionScreen(),
          );
        },
        showNextButton: false,  // Hide the next button
      ),
    );
  }
}
































