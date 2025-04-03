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
                    icon: Icons.female_outlined,
                    onPressed: () {
                      // Handle female selection
                    },
                  ),
                  (
                    text: 'Mannelijk',
                    icon: Icons.male_rounded,
                    onPressed: () {
                      // Handle male selection
                    },
                  ),
                  (
                    text: 'Onbekend',
                    icon: Icons.question_mark_outlined,
                    onPressed: () {
                      // Handle unknown selection
                    },
                  ),
                ],
                useCircleIcons: false,
                iconSize: 96, // Increased from 72
                verticalPadding: 0,
                horizontalPadding: 0,
                buttonSpacing: 4, // Reduced from 8
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











