import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/interfaces/data_apis/species_api_interface.dart';
import 'package:wildrapport/interfaces/filters/filter_interface.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';

/// Get the image path for an animal by name
String? getAnimalPhotoPath(String? name) {
  if (name == null || name.trim().isEmpty) return null;

  final nameLower = name.toLowerCase().trim();
  final normalized = nameLower
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
  final compact = normalized.replaceAll(' ', '');

  // Backend names do not always match file names 1:1.
  const Map<String, String> aliases = {
    'konik': 'konikpaard',
    'konik paard': 'konikpaard',
    'wilde kat': 'wild kat',
    'wildkat': 'wild kat',
    'shetlandpony': 'shetland pony',
    'exmoorpony': 'exmoor pony',
  };

  final fileStem = aliases[nameLower] ??
      aliases[normalized] ??
      aliases[compact] ??
      normalized;
  return 'assets/animals/$fileStem.png';
}

class AnimalManager
    implements
        AnimalRepositoryInterface,
        AnimalSelectionInterface,
        AnimalManagerInterface {
  final _listeners = <Function()>[];
  String _selectedFilter = 'Filteren';
  final SpeciesApiInterface _speciesApi;
  final FilterInterface _filterManager;
  List<AnimalModel>? _cachedAnimals;
  String? _currentSearchTerm;

  AnimalManager(this._speciesApi, this._filterManager);

  @override
  Future<List<AnimalModel>> getAnimals({AnimalCategory? category}) async {
    try {
      if (_cachedAnimals != null) {
        return _getFilteredAnimals(_cachedAnimals!);
      }

      final species = await _speciesApi.getAllSpecies();
      debugPrint('[AnimalManager] species fetched: ${species.length}');
      _cachedAnimals = species
          .map(
            (s) {
              final imagePath = getAnimalPhotoPath(s.commonName);
              debugPrint('[AnimalManager] Animal: ${s.commonName} -> Path: $imagePath');
              return AnimalModel(
                animalId: s.id,
                animalImagePath: imagePath,
                animalName: s.commonName,
                category: s.category,
                genderViewCounts: [],
                condition: AnimalCondition.andere,
              );
            },
          )
          .toList();

      return _getFilteredAnimals(_cachedAnimals!);
    } catch (e) {
      debugPrint('[AnimalManager] Error fetching animals: $e');
      return [];
    }
  }

  List<AnimalModel> _getFilteredAnimals(List<AnimalModel> animals) {
    if (_currentSearchTerm?.isNotEmpty == true) {
      // Apply search if there's a search term, regardless of filter
      return _filterManager.searchAnimals(animals, _currentSearchTerm!);
    }

    if (_selectedFilter == FilterType.alphabetical.displayText) {
      return _filterManager.filterAnimalsAlphabetically(animals);
    } else if (_selectedFilter == FilterType.mostViewed.displayText) {
      // Temporarily disabled - return unfiltered list
      return animals;
    }

    return animals;
  }

  @override
  AnimalModel handleAnimalSelection(AnimalModel selectedAnimal) {
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
  void updateSearchTerm(String searchTerm) {
    _currentSearchTerm = searchTerm;
    _notifyListeners(); // Make sure this is called to trigger UI updates
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

  @override
  Future<List<AnimalModel>> getAnimalsByCategory({
    AnimalCategory? category,
  }) async {
    final animals = await getAnimals();
    debugPrint('[AnimalManager] getAnimalsByCategory legacy enum used: $category');
    if (category == null) return animals;
    // Legacy: keep old behavior if enum is provided
    return animals;
  }

  Future<List<String>> getBackendCategories() async {
    // Prefer cached animals to avoid extra API call
    final animals = _cachedAnimals ?? await getAnimals();
    final set = <String>{};
    for (final a in animals) {
      final c = a.category?.trim();
      if (c != null && c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    debugPrint('[AnimalManager] categories fetched: ${list.length}');
    return list;
  }

  Future<List<AnimalModel>> getAnimalsByBackendCategory({String? category}) async {
    final animals = await getAnimals();
    if (category == null || category.isEmpty || category == 'Alle') return animals;
    return animals.where((a) => (a.category ?? '').toLowerCase() == category.toLowerCase()).toList();
  }
}
