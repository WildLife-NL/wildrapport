import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
import 'package:wildrapport/models/reports/waarneming_report.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';

class AnimalsViewModel extends ChangeNotifier {
  bool isExpanded = false;
  String selectedFilter;
  List<AnimalModel> animals;
  final AnimalManager _animalService;
  
  AnimalsViewModel({
    String? selectedFilter,
    AnimalManager? animalService,
  }) : _animalService = animalService ?? AnimalManager(),
       selectedFilter = FilterType.none.displayText,  // Set this to none instead of 'Filteren'
       animals = (animalService ?? AnimalManager()).getAnimals();

  void toggleExpanded() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  void updateFilter(String filter) {
    selectedFilter = filter;
    // Apply the actual filtering logic here based on the selected filter
    _applyFilter();
    notifyListeners();
  }

  void resetFilter() {
    selectedFilter = FilterType.none.displayText;  // Change from 'Filteren' to FilterType.none.displayText
    isExpanded = false;
    // Reset the animals list to original state
    animals = _animalService.getAnimals();
    notifyListeners();
  }

  void _applyFilter() {
    if (selectedFilter == FilterType.alphabetical.displayText) {
      animals.sort((a, b) => a.animalName.compareTo(b.animalName));
    } else if (selectedFilter == FilterType.mostViewed.displayText) {

    }
    // Add other filter implementations as needed
  }

  void handleAnimalSelection(BuildContext context, AnimalModel animal, String screenTitle) {
    final selectedAnimal = _animalService.handleAnimalSelection(animal);
    
    // Navigate based on report type
    if (screenTitle == 'Waarnemingen' || screenTitle == 'Diergezondheid') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OverzichtScreen(),
        ),
      );
    }
  }
}






















