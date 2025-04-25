import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/view_count_model.dart';
import 'package:wildrapport/screens/animal_list_overview_screen.dart';
import 'package:wildrapport/widgets/counter_widget.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/count_bar.dart';
import 'package:wildrapport/widgets/validation_overlay.dart';

class AnimalCounting extends StatefulWidget {
  final Function(String)? onAgeSelected;
  final VoidCallback? onAddToList;

  const AnimalCounting({
    super.key,
    this.onAgeSelected,
    this.onAddToList,
  });

  @override
  State<AnimalCounting> createState() => _AnimalCountingState();
}

class _AnimalCountingState extends State<AnimalCounting> {
  String? selectedAge;
  String? selectedGender;
  int currentCount = 0;
  final GlobalKey<AnimalCounterState> _counterKey = GlobalKey<AnimalCounterState>();

  AnimalAge _convertStringToAnimalAge(String ageString) {
    switch (ageString) {
      case "<6 maanden":
        return AnimalAge.pasGeboren;
      case "Onvolwassen":
        return AnimalAge.onvolwassen;
      case "Volwassen":
        return AnimalAge.volwassen;
      case "Onbekend":
      default:
        return AnimalAge.onbekend;
    }
  }

  AnimalGender _convertStringToAnimalGender(String genderString) {
    switch (genderString) {
      case "Mannelijk":
        return AnimalGender.mannelijk;
      case "Vrouwelijk":
        return AnimalGender.vrouwelijk;
      case "Onbekend":
      default:
        return AnimalGender.onbekend;
    }
  }

  // Add this method to check if a gender is already in use
  bool _isGenderInUse(String gender) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    final animalGender = _convertStringToAnimalGender(gender);
    
    return currentSighting?.animals?.any(
      (animal) => animal.gender == animalGender
    ) ?? false;
  }

  // Add this method to check if all genders are in use
  bool _areAllGendersInUse() {
    // Check all possible genders except 'Onbekend' (Unknown) which can be used multiple times
    return _isGenderInUse('Mannelijk') && _isGenderInUse('Vrouwelijk');
  }

  @override
  void initState() {
    super.initState();
    // Remove log from initState
  }

  void _handleCountChanged(String name, int count) {
    setState(() {
      currentCount = count;
    });
    
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final viewCount = ViewCountModel(
      pasGeborenAmount: selectedAge == "<6 maanden" ? count : 0,
      onvolwassenAmount: selectedAge == "Onvolwassen" ? count : 0,
      volwassenAmount: selectedAge == "Volwassen" ? count : 0,
      unknownAmount: selectedAge == "Onbekend" ? count : 0,
    );
    
    animalSightingManager.updateViewCount(viewCount);
    // Remove or comment out this log since it's redundant
    // debugPrint('[AnimalCounting] Count changed to: $count');
  }

  void _validateAndAddToList(BuildContext context) {
    debugPrint('[AnimalCounting] Validating before adding to list');
    List<String> errors = [];

    if (selectedAge == null) {
      errors.add('Selecteer een leeftijd');
    }

    if (selectedGender == null) {
      errors.add('Selecteer een geslacht');
    }

    if (currentCount <= 0) {
      errors.add('Voer een aantal groter dan 0 in');
    }

    if (errors.isNotEmpty) {
      debugPrint('[AnimalCounting] Validation failed: ${errors.join(", ")}');
      showDialog(
        context: context,
        builder: (context) => ValidationOverlay(messages: errors),
      );
      return;
    }

    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    if (currentSighting?.animalSelected != null) {
      final updatedAnimal = AnimalModel(
        animalId: currentSighting!.animalSelected!.animalId,
        animalImagePath: currentSighting.animalSelected!.animalImagePath,
        animalName: currentSighting.animalSelected!.animalName,
        genderViewCounts: [
          AnimalGenderViewCount(
            gender: _convertStringToAnimalGender(selectedGender!),
            viewCount: ViewCountModel(
              pasGeborenAmount: selectedAge == "<6 maanden" ? currentCount : 0,
              onvolwassenAmount: selectedAge == "Onvolwassen" ? currentCount : 0,
              volwassenAmount: selectedAge == "Volwassen" ? currentCount : 0,
              unknownAmount: selectedAge == "Onbekend" ? currentCount : 0,
            ),
          ),
        ],
        condition: currentSighting.animalSelected!.condition,
      );

      animalSightingManager.updateAnimal(updatedAnimal);
      
      final updatedSighting = animalSightingManager.getCurrentanimalSighting();
      debugPrint('[AnimalCounting] Added to list successfully:\n${updatedSighting?.toJson()}');

      widget.onAddToList?.call();
      
      // Reset selections after adding to list
      setState(() {
        selectedAge = null;
        selectedGender = null;
        _counterKey.currentState?.reset();
      });

      // Check if all genders are in use and navigate if true
      if (_areAllGendersInUse()) {
        final navigationManager = context.read<NavigationStateInterface>();
        navigationManager.pushReplacementForward(
          context,
          const AnimalListOverviewScreen(),
        );
      }
    }
  }

  void _handleAgeSelection(String age) {
    debugPrint('[AnimalCounting] Selected age: $age');
    setState(() {
      if (selectedAge == age) {
        selectedAge = null;
      } else {
        selectedAge = age;
        final animalAge = _convertStringToAnimalAge(age);
        final animalSightingManager = context.read<AnimalSightingReportingInterface>();
        animalSightingManager.updateAge(animalAge);
      }
    });
  }

  void _handleGenderSelection(String gender) {
    debugPrint('[AnimalCounting] Selected gender: $gender');
    setState(() {
      if (selectedGender == gender) {
        selectedGender = null;
      } else {
        selectedGender = gender;
        final animalGender = _convertStringToAnimalGender(gender);
        final animalSightingManager = context.read<AnimalSightingReportingInterface>();
        animalSightingManager.handleGenderSelection(animalGender);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Add this to make the widget rebuild when the animal sighting changes
    context.watch<AnimalSightingReportingInterface>();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24), // Added horizontal padding
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader('Leeftijd'),
                          _buildAgeButton(
                            "Onbekend",
                            icon: Icons.cancel_outlined,
                          ),
                          const SizedBox(height: 8),
                          _buildAgeButton("<6 maanden"),
                          const SizedBox(height: 8),
                          _buildAgeButton("Onvolwassen"),
                          const SizedBox(height: 8),
                          _buildAgeButton("Volwassen"),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader('Geslacht'),
                          _buildGenderButton(
                            "Onbekend",
                            icon: Icons.cancel_outlined,
                          ),
                          const SizedBox(height: 8),
                          _buildGenderButton(
                            "Mannelijk",
                            icon: Icons.male,
                            tintColor: AppColors.brown,
                          ),
                          const SizedBox(height: 8),
                          _buildGenderButton(
                            "Vrouwelijk",
                            icon: Icons.female,
                            tintColor: AppColors.brown,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 24), // Updated padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader('Aantal'),
                  const SizedBox(height: 8),
                  AnimalCounter(
                    key: _counterKey,
                    name: "Example",
                    height: 49,
                    onCountChanged: _handleCountChanged,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 350,
                    child: WhiteBulkButton(
                      text: "Voeg toe aan de lijst",
                      showIcon: false,
                      height: 85,
                      onPressed: () => _validateAndAddToList(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildAgeButton(String text, {IconData? icon, Color? tintColor}) {
    final bool isSelected = text == selectedAge;
    
    Widget? leftWidget;
    if (icon != null) {
      leftWidget = Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Icon(
          icon,
          size: 36,
          color: tintColor ?? AppColors.brown,
        ),
      );
    }

    return WhiteBulkButton(
      text: text,
      height: 64.5,
      showIcon: false,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      textAlign: icon != null ? TextAlign.left : TextAlign.center,
      leftWidget: leftWidget,
      backgroundColor: isSelected ? AppColors.lightGreen : null,
      onPressed: () => _handleAgeSelection(text),
    );
  }

  Widget _buildGenderButton(String text, {IconData? icon, Color? tintColor}) {
    // If gender is already in use, don't show the button
    if (_isGenderInUse(text)) {
      return const SizedBox.shrink(); // Returns an empty widget
    }

    final bool isSelected = text == selectedGender;
    
    Widget? leftWidget;
    if (icon != null) {
      leftWidget = Padding(
        padding: const EdgeInsets.only(right: 14),
        child: Icon(
          icon,
          size: 36,
          color: tintColor ?? AppColors.brown,
        ),
      );
    }

    return WhiteBulkButton(
      text: text,
      height: 64.5,
      showIcon: false,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      textAlign: icon != null ? TextAlign.left : TextAlign.center,
      leftWidget: leftWidget,
      backgroundColor: isSelected ? AppColors.lightGreen : null,
      onPressed: () => _handleGenderSelection(text),
    );
  }
}





