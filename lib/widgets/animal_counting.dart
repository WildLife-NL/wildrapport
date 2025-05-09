import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/view_count_model.dart';
import 'package:wildrapport/widgets/counter_widget.dart';
import 'package:wildrapport/widgets/error_overlay.dart';
import 'package:wildrapport/widgets/snack_bar_with_progress.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/constants/app_colors.dart';

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

  @override
  void initState() {
    super.initState();
  }

  void _handleCountChanged(String name, int count) {
    setState(() {
      currentCount = count;
    });
  }

  void _validateAndAddToList(BuildContext context) {
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
      showDialog(
        context: context,
        builder: (context) => ErrorOverlay(messages: errors),
      );
      return;
    }

    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    final currentAnimal = currentSighting?.animalSelected;

    if (currentAnimal == null) return;

    final selectedAnimalGender = _convertStringToAnimalGender(selectedGender!);
    final selectedAnimalAge = _convertStringToAnimalAge(selectedAge!);

    List<AnimalGenderViewCount> updatedGenderViewCounts = List.from(currentAnimal.genderViewCounts);

    final genderIndex = updatedGenderViewCounts.indexWhere((gvc) => gvc.gender == selectedAnimalGender);

    if (genderIndex != -1) {
      // Existing gender found - preserve other age values
      final existingGVC = updatedGenderViewCounts[genderIndex];
      final viewCount = existingGVC.viewCount;

      // Create updated view count preserving other age values
      final updatedViewCount = ViewCountModel(
        pasGeborenAmount: selectedAnimalAge == AnimalAge.pasGeboren ? currentCount : viewCount.pasGeborenAmount,
        onvolwassenAmount: selectedAnimalAge == AnimalAge.onvolwassen ? currentCount : viewCount.onvolwassenAmount,
        volwassenAmount: selectedAnimalAge == AnimalAge.volwassen ? currentCount : viewCount.volwassenAmount,
        unknownAmount: selectedAnimalAge == AnimalAge.onbekend ? currentCount : viewCount.unknownAmount,
      );

      updatedGenderViewCounts[genderIndex] = AnimalGenderViewCount(
        gender: selectedAnimalGender,
        viewCount: updatedViewCount,
      );
    } else {
      // New gender - create new entry
      final newViewCount = ViewCountModel(
        pasGeborenAmount: selectedAnimalAge == AnimalAge.pasGeboren ? currentCount : 0,
        onvolwassenAmount: selectedAnimalAge == AnimalAge.onvolwassen ? currentCount : 0,
        volwassenAmount: selectedAnimalAge == AnimalAge.volwassen ? currentCount : 0,
        unknownAmount: selectedAnimalAge == AnimalAge.onbekend ? currentCount : 0,
      );

      updatedGenderViewCounts.add(
        AnimalGenderViewCount(
          gender: selectedAnimalGender,
          viewCount: newViewCount,
        ),
      );
    }
    
    // Reset selections after adding
    setState(() {
      selectedAge = null;
      selectedGender = null;
    });

    final updatedAnimal = AnimalModel(
      animalId: currentAnimal.animalId,
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      genderViewCounts: updatedGenderViewCounts,
      condition: currentAnimal.condition,
    );

    animalSightingManager.updateAnimal(updatedAnimal);
    (_counterKey.currentState as AnimalCounterState).reset();

    widget.onAddToList?.call();
    
    // Show success snackbar
    SnackBarWithProgress.show(
      context: context,
      message: 'Dier toegevoegd aan de lijst',
    );
  }

  void _handleAgeSelection(String age) {
    setState(() {
      if (selectedAge == age) {
        selectedAge = null;
      } else {
        selectedAge = age;
      }
    });
  }

  void _handleGenderSelection(String gender) {
    setState(() {
      if (selectedGender == gender) {
        selectedGender = null;
      } else {
        selectedGender = gender;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AnimalSightingReportingInterface>();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top section with age/gender buttons that can change
                  SizedBox(
                    height: 300, // Fixed height for the top section
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Keep this as min
                                crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure buttons stretch
                                children: [
                                  _buildHeader('Leeftijd'),
                                  Flexible(child: _buildAgeButton("<6 maanden")),
                                  const SizedBox(height: 8),
                                  Flexible(child: _buildAgeButton("Onvolwassen")),
                                  const SizedBox(height: 8),
                                  Flexible(child: _buildAgeButton("Volwassen")),
                                  const SizedBox(height: 8),
                                  Flexible(child: _buildAgeButton("Onbekend")),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Keep this as min
                                crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure buttons stretch
                                children: [
                                  _buildHeader('Geslacht'),
                                  Flexible(child: _buildGenderButton("Mannelijk")),
                                  const SizedBox(height: 8),
                                  Flexible(child: _buildGenderButton("Vrouwelijk")),
                                  const SizedBox(height: 8),
                                  Flexible(child: _buildGenderButton("Onbekend")),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Add extra space here to move the Aantal section lower
                  const SizedBox(height: 30),
                  // Fixed position "Aantal" section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
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
                        // Add extra padding at the bottom to ensure the button is visible
                        SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.brown,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeButton(String text) {
    final bool isSelected = text == selectedAge;
    final bool disable = selectedGender != null && _isAgeAlreadyAdded(selectedGender!, text);

    if (disable) return const SizedBox.shrink();

    return WhiteBulkButton(
      text: text,
      height: 64.5,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      textAlign: TextAlign.center,
      showIcon: false,
      backgroundColor: isSelected ? AppColors.lightGreen : null,
      onPressed: () => _handleAgeSelection(text),
    );
  }

  Widget _buildGenderButton(String text) {
    final bool isSelected = text == selectedGender;
    final bool disable = _areAllAgesFilledForGender(text);

    if (disable) return const SizedBox.shrink();

    return WhiteBulkButton(
      text: text,
      height: 64.5,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      textAlign: TextAlign.center,
      showIcon: false,
      backgroundColor: isSelected ? AppColors.lightGreen : null,
      onPressed: () => _handleGenderSelection(text),
    );
  }

  bool _isAgeAlreadyAdded(String genderText, String ageText) {
    final manager = context.read<AnimalSightingReportingInterface>();
    final sighting = manager.getCurrentanimalSighting();
    final selectedGender = _convertStringToAnimalGender(genderText);
    final selectedAge = _convertStringToAnimalAge(ageText);

    final genderVC = sighting?.animalSelected?.genderViewCounts.firstWhere(
      (gvc) => gvc.gender == selectedGender,
      orElse: () => AnimalGenderViewCount(gender: selectedGender, viewCount: ViewCountModel()),
    );

    switch (selectedAge) {
      case AnimalAge.pasGeboren:
        return (genderVC?.viewCount.pasGeborenAmount ?? 0) > 0;
      case AnimalAge.onvolwassen:
        return (genderVC?.viewCount.onvolwassenAmount ?? 0) > 0;
      case AnimalAge.volwassen:
        return (genderVC?.viewCount.volwassenAmount ?? 0) > 0;
      case AnimalAge.onbekend:
        return (genderVC?.viewCount.unknownAmount ?? 0) > 0;
    }
  }

  bool _areAllAgesFilledForGender(String genderText) {
    final manager = context.read<AnimalSightingReportingInterface>();
    final sighting = manager.getCurrentanimalSighting();
    final selectedGender = _convertStringToAnimalGender(genderText);

    final genderVC = sighting?.animalSelected?.genderViewCounts.firstWhere(
      (gvc) => gvc.gender == selectedGender,
      orElse: () => AnimalGenderViewCount(gender: selectedGender, viewCount: ViewCountModel()),
    );

    if (genderVC == null) return false;

    return (genderVC.viewCount.pasGeborenAmount > 0) &&
           (genderVC.viewCount.onvolwassenAmount > 0) &&
           (genderVC.viewCount.volwassenAmount > 0) &&
           (genderVC.viewCount.unknownAmount > 0);
  }
}



