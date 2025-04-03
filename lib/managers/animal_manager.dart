
import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/interfaces/api/species_api_interface.dart';

class AnimalManager implements AnimalRepositoryInterface, AnimalSelectionInterface, AnimalManagerInterface {
  final _listeners = <Function()>[];
  String _selectedFilter = 'Filteren';
  final SpeciesApiInterface _speciesApi;
  List<AnimalModel>? _cachedAnimals;
  
  AnimalManager(this._speciesApi);

  @override
  Future<List<AnimalModel>> getAnimals() async {
    try {
      if (_cachedAnimals != null) {
        return _cachedAnimals!;
      }

      final species = await _speciesApi.getAllSpecies();
      _cachedAnimals = species.map((s) => AnimalModel(
        animalImagePath: 'assets/wolf.png',
        animalName: s.commonName,
        viewCount: 0,
      )).toList();

      // Add the "Unknown" option with no image
      _cachedAnimals!.add(AnimalModel(
        animalImagePath:null,  // No image path for unknown
        animalName: 'Onbekend',
        viewCount: 0,
      ));
      
      return _cachedAnimals!;
    } catch (e) {
      debugPrint('Error fetching animals: $e');
      throw Exception('Failed to load animals: $e');
    }
  }

  @override
  AnimalModel handleAnimalSelection(AnimalModel selectedAnimal) {
    // Empty implementation for now, just logging the selected animal
    debugPrint('Selected animal: ${selectedAnimal.animalName}');
    return selectedAnimal;
  }

  @override
  String getSelectedFilter() => _selectedFilter;

  @override
  void updateFilter(String filter) {
    _selectedFilter = filter;
    _notifyListeners();
  }

  @override
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}













