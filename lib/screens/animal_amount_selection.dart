import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/view_count_model.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/split_row_container.dart';
import 'package:wildrapport/widgets/compact_animal_display.dart';
import 'package:wildrapport/widgets/count_bar.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/waarneming_model.dart';

class AnimalAmountSelectionScreen extends StatefulWidget {
  const AnimalAmountSelectionScreen({super.key});

  @override
  State<AnimalAmountSelectionScreen> createState() => _AnimalAmountSelectionScreenState();
}

class _AnimalAmountSelectionScreenState extends State<AnimalAmountSelectionScreen> {
  late final WaarnemingReportingInterface _waarnemingManager;
  final Map<AnimalAge, int> _counts = {
    for (var age in AnimalAge.values) age: 0
  };
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _waarnemingManager = context.read<WaarnemingReportingInterface>();
    _validateWaarneming();
  }

  void _validateWaarneming() {
    final currentWaarneming = _waarnemingManager.getCurrentWaarneming();
    if (currentWaarneming == null || currentWaarneming.animalSelected == null) {
      debugPrint('[AnimalAmountSelectionScreen] No active waarneming or selected animal found');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen actieve waarneming of geselecteerd dier gevonden'),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleNextPressed() {
    debugPrint('[AnimalAmountSelectionScreen] Next button pressed');
    
    // Create view count from the current counts
    final viewCount = ViewCountModel(
      pasGeborenAmount: _counts[AnimalAge.pasGeboren] ?? 0,
      onvolwassenAmount: _counts[AnimalAge.onvolwassen] ?? 0,
      volwassenAmount: _counts[AnimalAge.volwassen] ?? 0,
      unknownAmount: _counts[AnimalAge.onbekend] ?? 0,
    );
    
    // Update the view count on the currently selected animal
    final currentWaarneming = _waarnemingManager.getCurrentWaarneming();
    if (currentWaarneming?.animalSelected == null) {
      debugPrint('[AnimalAmountSelectionScreen] ERROR: No animal selected to update');
      return;
    }
    
    // Update the view count
    _waarnemingManager.updateViewCount(viewCount);
    
    // Update the description if it's not empty
    if (_descriptionController.text.isNotEmpty) {
      _waarnemingManager.updateDescription(_descriptionController.text);
    }
    
    // Log the waarneming state after updating
    debugPrint('[AnimalAmountSelectionScreen] Waarneming after updating view count and description: ${_waarnemingManager.getCurrentWaarneming()?.toJson()}');
    
    // Navigate to next screen
    Navigator.pop(context);  // or navigate to the next screen
  }

  // New method to determine the most prevalent age based on counts
  AnimalAge? _determinePrevalentAge() {
    if (_counts.values.every((count) => count == 0)) return null;
    
    return _counts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  bool get _hasNonZeroCount => _counts.values.any((count) => count > 0);

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
            setState(() {
              _counts[age] = count;
            });
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
          setState(() {
            _counts[age] = count;
          });
          debugPrint('[$name] Count changed to: $count');
        },
      ),
    );
  }

  String _getGenderIconName(AnimalGender? gender) {
    switch (gender) {
      case AnimalGender.mannelijk:
        return 'male';
      case AnimalGender.vrouwelijk:
        return 'female';
      case AnimalGender.onbekend:
      case null:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentWaarneming = _waarnemingManager.getCurrentWaarneming();
    final selectedAnimal = currentWaarneming?.animalSelected;

    if (selectedAnimal == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: No animal selected'),
        ),
      );
    }

    // Create gender model for display using the animal's gender
    final genderModel = AnimalModel(
      animalImagePath: 'assets/icons/gender/${_getGenderIconName(selectedAnimal.gender)}_gender.png',
      animalName: selectedAnimal.gender?.toString().split('.').last ?? 'Unknown',
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomAppBar(
                  leftIcon: Icons.arrow_back_ios,
                  centerText: 'Selecteer aantal',
                  rightIcon: Icons.menu,
                  onLeftIconPressed: () => Navigator.pop(context),
                  onRightIconPressed: () => debugPrint('[AnimalAmountSelectionScreen] Menu button pressed'),
                ),
                const SizedBox(height: 12),
                SplitRowContainer(
                  rightWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CompactAnimalDisplay(animal: selectedAnimal),
                      const SizedBox(width: 8),
                      CompactAnimalDisplay(animal: genderModel),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                        _buildDescriptionSection(),
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
        onNextPressed: _handleNextPressed,
        showNextButton: _hasNonZeroCount,
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Opmerkingen',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 20,
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
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 120,
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
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.offWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}























