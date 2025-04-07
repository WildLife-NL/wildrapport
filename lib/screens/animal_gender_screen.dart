import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/split_row_container.dart';
import 'package:wildrapport/widgets/compact_animal_display.dart';
import 'package:wildrapport/widgets/overzicht/action_buttons.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';

class AnimalGenderScreen extends StatelessWidget {
  final AnimalModel animal;

  const AnimalGenderScreen({
    super.key,
    required this.animal,
  });

  @override
  Widget build(BuildContext context) {
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
                onLeftIconPressed: () => Navigator.pop(context),
                onRightIconPressed: () {/* Handle menu */},
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
              const SizedBox(height: 16), // Reduced from 24 to 16
              ActionButtons(
                buttons: [
                  (
                    text: 'Vrouwelijk',
                    imagePath: 'assets/icons/gender/female_gender.png',
                    icon: null,
                    onPressed: () {
                      // Handle female selection
                    },
                  ),
                  (
                    text: 'Mannelijk',
                     imagePath: 'assets/icons/gender/male_gender.png',
                    icon: null,
                    onPressed: () {
                      // Handle male selection
                    },
                  ),
                  (
                    text: 'Onbekend',
                     imagePath: 'assets/icons/gender/unknown_gender.png',
                    icon: null,
                    onPressed: () {
                      // Handle unknown selection
                    },
                  ),
                ],
                useCircleIcons: false,
                iconSize: 76,  // Reduced from 96 to 76 (20px smaller)
                verticalPadding: 0,
                horizontalPadding: 0,
                buttonSpacing: 14,  // Increased from 4 to 14 (10px more spacing)
                buttonHeight: 120,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => Navigator.pop(context),
        onNextPressed: () {
          // Handle next screen navigation
        },
      ),
    );
  }
}














