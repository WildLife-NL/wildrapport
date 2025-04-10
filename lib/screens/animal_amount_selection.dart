import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/view_count_model.dart';
import 'package:wildrapport/screens/add_another_animal_screen.dart';
import 'package:wildrapport/screens/animal_list_overview_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/split_row_container.dart';
import 'package:wildrapport/widgets/compact_animal_display.dart';
import 'package:wildrapport/widgets/count_bar.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_age.dart';

class AnimalAmountSelectionScreen extends StatefulWidget {
  const AnimalAmountSelectionScreen({super.key});

  @override
  State<AnimalAmountSelectionScreen> createState() => _AnimalAmountSelectionScreenState();
}

class _AnimalAmountSelectionScreenState extends State<AnimalAmountSelectionScreen> {
  late final AnimalSightingReportingInterface _animalSightingManager;
  final Map<AnimalAge, int> _counts = {
    for (var age in AnimalAge.values) age: 0
  };
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animalSightingManager = context.read<AnimalSightingReportingInterface>();
    _validateanimalSighting();
  }

  void _validateanimalSighting() {
    final currentanimalSighting = _animalSightingManager.getCurrentanimalSighting();
    if (currentanimalSighting == null || currentanimalSighting.animalSelected == null) {
      debugPrint('[AnimalAmountSelectionScreen] No active animalSighting or selected animal found');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen actieve animalSighting of geselecteerd dier gevonden'),
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
    final currentanimalSighting = _animalSightingManager.getCurrentanimalSighting();
    if (currentanimalSighting?.animalSelected == null) {
      debugPrint('[AnimalAmountSelectionScreen] ERROR: No animal selected to update');
      return;
    }

    _animalSightingManager.updateViewCount(viewCount);
    
    // Update description if provided
    if (_descriptionController.text.isNotEmpty) {
      final currentDescription = currentanimalSighting?.description ?? '';
      final selectedGender = currentanimalSighting?.animalSelected?.gender;
      
      String newDescription = '';
      if (currentDescription.isNotEmpty) {
        newDescription = '$currentDescription\n\n';  // Add double newline for spacing
      }
      newDescription += '${_getGenderText(selectedGender)}: ${_descriptionController.text}';
      
      _animalSightingManager.updateDescription(newDescription);
    }

    // Check if all genders are used for the current animal
    final usedGenders = currentanimalSighting?.animals
        ?.where((animal) => animal.animalName == currentanimalSighting.animalSelected?.animalName)
        .map((animal) => animal.gender)
        .whereType<AnimalGender>()
        .toSet() ?? {};
    
    // Add the current gender to the used genders
    if (currentanimalSighting?.animalSelected?.gender != null) {
      usedGenders.add(currentanimalSighting!.animalSelected!.gender!);
    }

    final bool allGendersUsed = usedGenders.length >= 3;

    if (allGendersUsed) {
      // Make sure the current animal's data is saved before finalizing
      _animalSightingManager.finalizeAnimal(clearSelected: true);
      
      // Add debug print
      debugPrint('Final description before navigation: ${_animalSightingManager.getCurrentanimalSighting()?.description}');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AnimalListOverviewScreen(),
        ),
      );
    } else {
      // Navigate to AddAnotherAnimalScreen for more gender selections
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddAnotherAnimalScreen(),
        ),
      );
    }
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

  String _getGenderText(AnimalGender? gender) {
    switch (gender) {
      case AnimalGender.vrouwelijk:
        return 'Vrouwelijk';
      case AnimalGender.mannelijk:
        return 'Mannelijk';
      case AnimalGender.onbekend:
        return 'Onbekend';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentanimalSighting = _animalSightingManager.getCurrentanimalSighting();
    final selectedAnimal = currentanimalSighting?.animalSelected;

    if (selectedAnimal == null) {
      return const Scaffold(
        body: Center(
          child: Text('Error: No animal selected'),
        ),
      );
    }

    // Create gender model for display using the animal's gender
    final genderModel = AnimalModel(
      animalImagePath: selectedAnimal.gender != null 
          ? 'assets/icons/gender/${_getGenderIconName(selectedAnimal.gender)}_gender.png'
          : null,
      animalName: selectedAnimal.gender?.toString().split('.').last ?? 'Onbekend',
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.03), // Added padding
                SplitRowContainer(
                  rightWidget: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CompactAnimalDisplay(
                        animal: selectedAnimal,
                        height: MediaQuery.of(context).size.height * 0.12,
                      ),
                      const SizedBox(width: 8),
                      CompactAnimalDisplay(
                        animal: genderModel,
                        height: MediaQuery.of(context).size.height * 0.12,
                      ),
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































