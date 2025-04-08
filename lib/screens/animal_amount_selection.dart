import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/split_row_container.dart';
import 'package:wildrapport/widgets/compact_animal_display.dart';
import 'package:wildrapport/widgets/count_bar.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_age.dart';

class AnimalAmountSelectionScreen extends StatelessWidget {
  const AnimalAmountSelectionScreen({super.key});

  String _formatAnimalAgeName(AnimalAge age) {
    switch (age) {
      case AnimalAge.pasGeboren:
        return 'Pas geboren';
      case AnimalAge.onvolwassen:
        return 'Onvolwassen';
      case AnimalAge.volwassen:
        return 'Volwassen';
      case AnimalAge.onbekend:
        return 'Onbekend';
    }
  }

  double _getIconSize(AnimalAge age) {
    switch (age) {
      case AnimalAge.pasGeboren:
        return 38.0;  // Smallest
      case AnimalAge.onvolwassen:
        return 44.0;  // Medium
      case AnimalAge.volwassen:
        return 50.0;  // Large
      case AnimalAge.onbekend:
        return 56.0;  // Largest
    }
  }

  double _getIconScale(AnimalAge age) {
    switch (age) {
      case AnimalAge.pasGeboren:
        return 0.5;  // Smallest
      case AnimalAge.onvolwassen:
        return 0.6;  // Medium
      case AnimalAge.volwassen:
        return 0.7;  // Large
      case AnimalAge.onbekend:
        return 0.8;  // Largest
    }
  }

  Widget _buildCountBar(AnimalAge age) {
    final iconSize = _getIconSize(age);
    final iconScale = _getIconScale(age);
    final name = _formatAnimalAgeName(age);

    if (age == AnimalAge.onbekend) {
      return SizedBox(
        height: iconSize + 12,
        child: CountBar(
          name: name,
          imagePath: 'assets/icons/gender/unknown_gender.png',
          iconSize: iconSize,
          iconScale: iconScale,
          onCountChanged: (name, count) {
            debugPrint('[$name] Count changed to: $count');
          },
        ),
      );
    }

    // Define icon color based on age
    Color iconColor;
    switch (age) {
      case AnimalAge.onvolwassen:
        iconColor = const Color(0xFF549537); // New specific green color
      case AnimalAge.volwassen:
        iconColor = Colors.orange;
      default:
        iconColor = AppColors.brown; // Default color for pas geboren
    }

    return SizedBox(
      height: iconSize + 12,
      child: CountBar(
        name: name,
        rightIcon: Icons.pets,
        iconSize: iconSize,
        iconScale: iconScale,
        iconColor: iconColor,
        onCountChanged: (name, count) {
          debugPrint('[$name] Count changed to: $count');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animal = AnimalModel(
      animalImagePath: 'assets/wolf.png',
      animalName: 'Wolf',
    );

    final gender = AnimalModel(
      animalImagePath: 'assets/icons/gender/female_gender.png',
      animalName: 'Vrouwelijk',
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(  // Added ScrollView
            child: Column(
              children: [
                CustomAppBar(
                  leftIcon: Icons.arrow_back_ios,
                  centerText: 'Selecteer aantal',  // Changed from 'Aantal'
                  rightIcon: Icons.menu,
                  onLeftIconPressed: () => Navigator.pop(context),
                  onRightIconPressed: () => debugPrint('[AnimalAmountSelectionScreen] Menu button pressed'),
                ),
                const SizedBox(height: 12),
                SplitRowContainer(
                  rightWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CompactAnimalDisplay(animal: animal),
                      const SizedBox(width: 8),
                      CompactAnimalDisplay(animal: gender),
                    ],
                  ),
                ),
                const SizedBox(height: 24), // Added spacing here
                Container(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        ...AnimalAge.values.map((age) {
                          return Column(
                            children: [
                              _buildCountBar(age),
                              if (age != AnimalAge.values.last)
                                const SizedBox(height: 6),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              'Opmerkingen',
                              style: TextStyle(
                                color: AppColors.brown,
                                fontSize: 20, // Increased from 16 to 20
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.25),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          height: 120, // Increased height
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                spreadRadius: 0,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            maxLines: 3, // Increased to 3 lines
                            decoration: InputDecoration(
                              hintText: 'Typ hier ...',
                              hintStyle: TextStyle(
                                color: AppColors.brown.withOpacity(0.5),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.brown,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => Navigator.pop(context),
        onNextPressed: () => debugPrint('[AnimalAmountSelectionScreen] Next button pressed'),
      ),
    );
  }
}





