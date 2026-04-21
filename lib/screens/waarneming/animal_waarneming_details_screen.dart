import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/screens/waarneming/animal_waarneming_summary_screen.dart';
import 'package:wildrapport/screens/waarneming/dieraanrijding_details_screen.dart';
import 'package:wildrapport/screens/schademelding/schademelding_details_screen.dart';
import 'package:wildrapport/constants/design_system.dart';

class AnimalWaarnemingDetailsScreen extends StatefulWidget {
  final int animalIndex; // 0-based index (0 = Dier 1, 1 = Dier 2, etc)
  final int totalCount; // Total number of animals

  const AnimalWaarnemingDetailsScreen({
    super.key,
    required this.animalIndex,
    required this.totalCount,
  });

  @override
  State<AnimalWaarnemingDetailsScreen> createState() =>
      _AnimalWaarnemingDetailsScreenState();
}

class _AnimalWaarnemingDetailsScreenState
    extends State<AnimalWaarnemingDetailsScreen> {
  AnimalAge selectedAge = AnimalAge.onbekend;
  AnimalGender selectedGender = AnimalGender.onbekend;

  @override
  void initState() {
    super.initState();
    _hydrateSelectionFromSavedAnimal();
  }

  void _hydrateSelectionFromSavedAnimal() {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    final animals = sighting?.animals;

    if (animals == null || widget.animalIndex >= animals.length) return;

    final savedAnimal = animals[widget.animalIndex];
    if (savedAnimal.genderViewCounts.isEmpty) return;

    final firstGenderViewCount = savedAnimal.genderViewCounts.first;
    selectedGender = firstGenderViewCount.gender;
    selectedAge = _extractAgeFromViewCount(firstGenderViewCount.viewCount);
  }

  AnimalAge _extractAgeFromViewCount(ViewCountModel viewCount) {
    if (viewCount.pasGeborenAmount > 0) return AnimalAge.pasGeboren;
    if (viewCount.onvolwassenAmount > 0) return AnimalAge.onvolwassen;
    if (viewCount.volwassenAmount > 0) return AnimalAge.volwassen;
    return AnimalAge.onbekend;
  }

  AnimalModel? _getTemplateAnimal() {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();

    if (sighting == null) return null;

    final existingAnimals = sighting.animals;
    if (existingAnimals != null && widget.animalIndex < existingAnimals.length) {
      return existingAnimals[widget.animalIndex];
    }

    return sighting.animalSelected;
  }

  AnimalModel _buildAnimalWithSelection({
    required AnimalModel template,
    required AnimalAge age,
    required AnimalGender gender,
  }) {
    final viewCount = ViewCountModel();
    if (age == AnimalAge.pasGeboren) {
      viewCount.pasGeborenAmount = 1;
    } else if (age == AnimalAge.onvolwassen) {
      viewCount.onvolwassenAmount = 1;
    } else if (age == AnimalAge.volwassen) {
      viewCount.volwassenAmount = 1;
    } else {
      viewCount.unknownAmount = 1;
    }

    return AnimalModel(
      animalId: template.animalId,
      animalImagePath: template.animalImagePath,
      animalName: template.animalName,
      category: template.category,
      genderViewCounts: [
        AnimalGenderViewCount(
          gender: gender,
          viewCount: viewCount,
        ),
      ],
      condition: template.condition,
    );
  }

  void _upsertAnimalAtIndex({
    required int index,
    required AnimalModel animal,
  }) {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    if (sighting == null) return;

    final updatedAnimals = List<AnimalModel>.from(sighting.animals ?? []);

    if (index < updatedAnimals.length) {
      updatedAnimals[index] = animal;
    } else {
      updatedAnimals.add(animal);
    }

    final normalizedAnimals = updatedAnimals.length > widget.totalCount
        ? updatedAnimals.sublist(0, widget.totalCount)
        : updatedAnimals;

    sightingManager.updateCurrentanimalSighting(
      sighting.copyWith(
        animals: normalizedAnimals,
        animalSelected: animal,
      ),
    );
  }

  void _handleBackNavigation() {
    _saveDraftBeforeBackNavigation();

    if (widget.animalIndex > 0) {
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AnimalWaarnemingDetailsScreen(
              animalIndex: widget.animalIndex - 1,
              totalCount: widget.totalCount,
            ),
          ),
        );
      }
    } else {
      // Go back to animal_aantal_screen
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
    }
  }

  void _saveDraftBeforeBackNavigation() {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    if (sighting == null) return;

    final hasExistingEntry =
        sighting.animals != null && widget.animalIndex < sighting.animals!.length;
    final hasExplicitSelection =
        selectedAge != AnimalAge.onbekend || selectedGender != AnimalGender.onbekend;

    if (!hasExistingEntry && !hasExplicitSelection) {
      return;
    }

    final templateAnimal = _getTemplateAnimal();
    if (templateAnimal == null) return;

    final draftAnimal = _buildAnimalWithSelection(
      template: templateAnimal,
      age: selectedAge,
      gender: selectedGender,
    );

    _upsertAnimalAtIndex(
      index: widget.animalIndex,
      animal: draftAnimal,
    );
  }

  AnimalModel? _saveCurrentAnimalDetails({
    AnimalAge? age,
    AnimalGender? gender,
    bool prepareNextSelection = true,
  }) {
    final templateAnimal = _getTemplateAnimal();
    if (templateAnimal == null) return null;

    final chosenAge = age ?? selectedAge;
    final chosenGender = gender ?? selectedGender;

    final updatedAnimal = _buildAnimalWithSelection(
      template: templateAnimal,
      age: chosenAge,
      gender: chosenGender,
    );

    _upsertAnimalAtIndex(
      index: widget.animalIndex,
      animal: updatedAnimal,
    );

    if (!prepareNextSelection) {
      return templateAnimal;
    }

    return templateAnimal;
  }

  void _navigateAfterAnimalDetails() {
    final sightingManager = context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    final reportType = sighting?.reportType;

    if (reportType == 'verkeersongeval') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DieraanrijdingDetailsScreen(totalCount: widget.totalCount),
        ),
      );
    } else if (reportType == 'gewasschade') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SchademeldingDetailsScreen(),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimalWaarnemingSummaryScreen(totalCount: widget.totalCount),
        ),
      );
    }
  }

  AnimalModel _buildUnknownAnimalFromTemplate(AnimalModel templateAnimal) {
    final unknownViewCount = ViewCountModel()..unknownAmount = 1;
    return AnimalModel(
      animalId: templateAnimal.animalId,
      animalImagePath: templateAnimal.animalImagePath,
      animalName: templateAnimal.animalName,
      category: templateAnimal.category,
      genderViewCounts: [
        AnimalGenderViewCount(
          gender: AnimalGender.onbekend,
          viewCount: unknownViewCount,
        ),
      ],
      condition: templateAnimal.condition,
    );
  }

  void _handleNextAnimal() {
    final savedTemplate = _saveCurrentAnimalDetails(prepareNextSelection: true);
    if (savedTemplate == null) return;

    if (widget.animalIndex < widget.totalCount - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnimalWaarnemingDetailsScreen(
            animalIndex: widget.animalIndex + 1,
            totalCount: widget.totalCount,
          ),
        ),
      );
    } else {
      _navigateAfterAnimalDetails();
    }
  }

  void _handleFinishAnimals() {
    final templateAnimal =
        _saveCurrentAnimalDetails(prepareNextSelection: false);
    if (templateAnimal == null) return;

    final remainingAnimals = widget.totalCount - (widget.animalIndex + 1);
    for (int i = 0; i < remainingAnimals; i++) {
      final targetIndex = widget.animalIndex + 1 + i;
      final unknownAnimal = _buildUnknownAnimalFromTemplate(templateAnimal);
      _upsertAnimalAtIndex(
        index: targetIndex,
        animal: unknownAnimal,
      );
    }

    _navigateAfterAnimalDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sightingManager =
        context.read<AnimalSightingReportingInterface>();
    final sighting = sightingManager.getCurrentanimalSighting();
    final selectedAnimal = sighting?.animalSelected;

    if (selectedAnimal == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F6F4),
        body: const Center(
          child: Text('No animal selected'),
        ),
      );
    }

    String appBarTitle = 'Waarneming'; // default
    if (sighting != null && sighting.reportType != null) {
      if (sighting.reportType == 'gewasschade') {
        appBarTitle = 'Schademelding';
      } else if (sighting.reportType == 'waarneming') {
        appBarTitle = 'Waarneming';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Bar
            CustomAppBar(
              centerText: appBarTitle,
              rightIcon: null,
              showUserIcon: false,
              useFixedText: true,
              onLeftIconPressed: _handleBackNavigation,
              textColor: AppColors.textPrimary,
              fontScale: 1.4,
              iconScale: 1.15,
              userIconScale: 1.15,
            ),
            // Main card container
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Heading
                          Center(
                            child: Text(
                              'Dier ${widget.animalIndex + 1} Details',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Animal card with image
                          Center(
                            child: SizedBox(
                              width: 180,
                              child: Card(
                                shadowColor: const Color.fromARGB(133, 0, 0, 0).withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: const Color(0xFF999999),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Image area
                                    Center(
                                      child: SizedBox(
                                        width: 180,
                                        height: 150,
                                        child: AspectRatio(
                                          aspectRatio: 1.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(14),
                                                topRight: Radius.circular(14),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(14),
                                                topRight: Radius.circular(14),
                                              ),
                                              child: SizedBox.expand(
                                                child: selectedAnimal.animalImagePath !=
                                                        null
                                                    ? Image(
                                                        image: AssetImage(
                                                          selectedAnimal.animalImagePath!,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Center(
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported_outlined,
                                                          size: 50,
                                                          color: Colors.grey[400],
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Divider line
                                    Container(
                                      height: 1,
                                      color: const Color(0xFF999999),
                                      width: 180,
                                    ),
                                    // Name area
                                    Container(
                                      width: 180,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(14),
                                          bottomRight: Radius.circular(14),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        selectedAnimal.animalName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Age selector
                          _buildSelectorSection('Leeftijd:', [
                            AnimalAge.onbekend,
                            AnimalAge.pasGeboren,
                            AnimalAge.onvolwassen,
                            AnimalAge.volwassen,
                          ], (age) {
                            setState(() => selectedAge = age as AnimalAge);
                          }, selectedAge),
                          const SizedBox(height: 16),
                          // Gender selector
                          _buildSelectorSection('Geslacht:', [
                            AnimalGender.onbekend,
                            AnimalGender.mannelijk,
                            AnimalGender.vrouwelijk,
                          ], (gender) {
                            setState(() =>
                                selectedGender = gender as AnimalGender);
                          }, selectedGender),
                          const SizedBox(height: 20),
                          // Next animal button - only show if not the final animal
                          if (widget.animalIndex < widget.totalCount - 1)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  side: BorderSide(
                                    color: const Color(0xFF999999),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                onPressed: _handleNextAnimal,
                                child: const Text(
                                  '+ Volgende Dier',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Bottom buttons
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleBackNavigation,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: Colors.black.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                          backgroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Vorige',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.animalIndex == widget.totalCount - 1
                          ? _handleNextAnimal
                          : _handleFinishAnimals,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF37A904),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          widget.animalIndex == widget.totalCount - 1
                              ? 'Volgende'
                              : 'Klaar met dieren',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox.shrink(),
    );
  }

  Widget _buildSelectorSection(
    String label,
    List<dynamic> options,
    Function(dynamic) onSelected,
    dynamic selectedValue,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            final label = _getEnumLabel(option);
            return OutlinedButton(
              onPressed: () => onSelected(option),
              style: isSelected
                  ? AppComponentStyles.selectionButtonSelected()
                  : AppComponentStyles.selectionButtonUnselected(),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getEnumLabel(dynamic value) {
    if (value is AnimalAge) {
      switch (value) {
        case AnimalAge.pasGeboren:
          return 'Pas geboren';
        case AnimalAge.onvolwassen:
          return 'Onvolwassen';
        case AnimalAge.volwassen:
          return 'Volwassen';
        case AnimalAge.onbekend:
          return 'Onbekend';
      }
    } else if (value is AnimalGender) {
      switch (value) {
        case AnimalGender.mannelijk:
          return 'Mannelijk';
        case AnimalGender.vrouwelijk:
          return 'Vrouwelijk';
        case AnimalGender.onbekend:
          return 'Onbekend';
      }
    } else if (value is AnimalCondition) {
      switch (value) {
        case AnimalCondition.gezond:
          return 'Gezond';
        case AnimalCondition.ziek:
          return 'Gewond/Ziek';
        case AnimalCondition.dood:
          return 'Dood';
        case AnimalCondition.levend:
          return 'Levend';
        case AnimalCondition.andere:
          return 'Anders';
      }
    }
    return 'Onbekend';
  }
}
