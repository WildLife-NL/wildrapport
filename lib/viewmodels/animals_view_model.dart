import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/models/reports/waarneming_report.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';

class AnimalsViewModel extends ChangeNotifier {
  bool isExpanded = false;
  String selectedFilter;
  List<AnimalModel> animals;
  
  AnimalsViewModel({
    this.selectedFilter = 'Filter',
  }) : animals = AnimalService.getAnimals();

  void toggleExpanded() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  void updateFilter(String filter) {
    selectedFilter = filter;
    notifyListeners();
  }

  void handleAnimalSelection(BuildContext context, AnimalModel animal, String screenTitle) {
    final selectedAnimal = AnimalService.handleAnimalSelection(animal);
    
    // Update report
    final provider = Provider.of<AppStateProvider>(context, listen: false);
    final report = provider.getCurrentReport<WaarnemingReport>();
    if (report != null) {
      provider.updateCurrentReport('selectedAnimal', selectedAnimal.animalName);
      
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
}
