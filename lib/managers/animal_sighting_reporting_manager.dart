import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/models/date_time_model.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/location_model.dart';
import 'package:wildrapport/models/view_count_model.dart';

class AnimalSightingReportingManager implements AnimalSightingReportingInterface {
  final List<VoidCallback> _listeners = [];
  AnimalSightingModel? _currentanimalSighting;

  AnimalCondition _mapStringToCondition(String status) {
    switch (status.toLowerCase()) {
      case 'gezond':
        return AnimalCondition.gezond;
      case 'ziek':
        return AnimalCondition.ziek;
      case 'dood':
        return AnimalCondition.dood;
      default:
        return AnimalCondition.andere;
    }
  }

  AnimalCategory convertStringToCategory(String status) {
    switch (status.toLowerCase()) {
      case 'evenhoevigen':
        return AnimalCategory.evenhoevigen;
      case 'knaagdieren':
        return AnimalCategory.knaagdieren;
      case 'roofdieren':
        return AnimalCategory.roofdieren;
      case 'andere':
        return AnimalCategory.andere;
      default:
        throw StateError('Invalid category: $status');
    }
  }

  static const List<({String text, IconData icon, String? imagePath})> conditionButtons = [
    (text: 'Gezond', icon: Icons.check_circle, imagePath: null),
    (text: 'Ziek', icon: Icons.sick, imagePath: null),
    (text: 'Dood', icon: Icons.dangerous, imagePath: null),
    (text: 'Andere', icon: Icons.more_horiz, imagePath: null),
  ];

  @override
  AnimalSightingModel createanimalSighting() {
    _currentanimalSighting = AnimalSightingModel(
      animals: [],
      animalSelected: null,
      category: null,
      description: null,
      locations: [],  // Initialize as empty list
      dateTime: null,
      images: null,
    );
    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateSelectedAnimal(AnimalModel selectedAnimal) {
    final oldJson = _currentanimalSighting?.toJson();
    
    // Preserve the condition from the current animalSighting if it exists
    final updatedAnimal = AnimalModel(
      animalId: selectedAnimal.animalId,  // Add this line to preserve the ID
      animalImagePath: selectedAnimal.animalImagePath,
      animalName: selectedAnimal.animalName,
      genderViewCounts: selectedAnimal.genderViewCounts,
      condition: _currentanimalSighting?.animalSelected?.condition ?? selectedAnimal.condition,
    );
    
    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,  // Use the updated animal that preserves the condition
      category: _currentanimalSighting?.category,
      description: _currentanimalSighting?.description,
      locations: _currentanimalSighting?.locations,  // Preserve the locations
      dateTime: _currentanimalSighting?.dateTime,
      images: _currentanimalSighting?.images,
    );
    
    debugPrint('[animalSightingManager] Updating selected animal. Previous state: $oldJson');
    debugPrint('[animalSightingManager] New state: ${_currentanimalSighting!.toJson()}');
    
    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateCondition(AnimalCondition condition) {
    // Create a new sighting if none exists
    _currentanimalSighting ??= createanimalSighting();

    // Get the current animal or create a new empty one
    final currentAnimal = _currentanimalSighting!.animalSelected ?? AnimalModel(
      animalId: null,
      animalImagePath: null,
      animalName: '',
      genderViewCounts: [],
      condition: condition,
    );
    
    // Create updated animal with new condition
    final updatedAnimal = AnimalModel(
      animalId: currentAnimal.animalId,
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      genderViewCounts: currentAnimal.genderViewCounts,
      condition: condition,
    );

    // Update the current sighting with the new animal
    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      locations: _currentanimalSighting?.locations,  // Preserve the locations
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );
    
    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateConditionFromString(String status) {
    final condition = _mapStringToCondition(status);
    return updateCondition(condition);
  }

  @override
  AnimalSightingModel updateGender(AnimalGender gender) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    final currentAnimal = _currentanimalSighting!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current animalSighting');
    }

    // Find the existing animal in the list with this gender
    final existingAnimal = _currentanimalSighting!.animals?.firstWhere(
      (a) => a.genderViewCounts.any((gvc) => gvc.gender == gender),
      orElse: () => AnimalModel(
        animalId: currentAnimal.animalId,
        animalImagePath: currentAnimal.animalImagePath,
        animalName: currentAnimal.animalName,
        genderViewCounts: [],
        condition: currentAnimal.condition,
      ),
    );

    // If we found an existing animal with this gender, use its view counts
    final genderViewCounts = existingAnimal?.genderViewCounts ?? 
      [AnimalGenderViewCount(gender: gender, viewCount: ViewCountModel())];

    final updatedAnimal = AnimalModel(
      animalId: currentAnimal.animalId,
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      genderViewCounts: genderViewCounts,
      condition: currentAnimal.condition,
    );

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting!.animals,
      animalSelected: updatedAnimal,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      locations: _currentanimalSighting!.locations,
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );

    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateAge(AnimalAge age) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    final currentAnimal = _currentanimalSighting!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current animalSighting');
    }

    final updatedAnimal = AnimalModel(
      animalId: currentAnimal.animalId,  // Preserve ID
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      genderViewCounts: currentAnimal.genderViewCounts,
      condition: currentAnimal.condition,
    );

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      locations: _currentanimalSighting?.locations,  // Preserve the locations
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );

    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateViewCount(ViewCountModel viewCount) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    final currentAnimal = _currentanimalSighting!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current animalSighting');
    }

    final updatedAnimal = AnimalModel(
      animalId: currentAnimal.animalId,  // Preserve ID
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      genderViewCounts: currentAnimal.genderViewCounts,
      condition: currentAnimal.condition,

    );

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      locations: _currentanimalSighting?.locations,  // Preserve the locations
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );

    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateCategory(AnimalCategory category) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    final oldJson = _currentanimalSighting!.toJson();
    
    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting!.animals,
      animalSelected: _currentanimalSighting!.animalSelected,  // Add this line to preserve the selected animal and its condition
      category: category,
      description: _currentanimalSighting!.description,
      locations: _currentanimalSighting?.locations,  // Preserve the locations
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );
    
    debugPrint('[animalSightingManager] Updating category. Previous state: $oldJson');
    debugPrint('[animalSightingManager] New state: ${_currentanimalSighting!.toJson()}');
    
    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel finalizeAnimal({bool clearSelected = true}) {
    if (_currentanimalSighting?.animalSelected == null) {
      throw StateError('No animal selected to finalize');
    }

    final oldJson = _currentanimalSighting!.toJson();
    final currentAnimals = List<AnimalModel>.from(_currentanimalSighting!.animals ?? []);
    
    // Ensure we preserve the ID when adding to the list
    final animalToAdd = AnimalModel(
      animalId: _currentanimalSighting!.animalSelected!.animalId,  // Preserve ID
      animalImagePath: _currentanimalSighting!.animalSelected!.animalImagePath,
      animalName: _currentanimalSighting!.animalSelected!.animalName,
      genderViewCounts: _currentanimalSighting!.animalSelected!.genderViewCounts,
      condition: _currentanimalSighting!.animalSelected!.condition,
    );
    
    currentAnimals.add(animalToAdd);

    _currentanimalSighting = AnimalSightingModel(
      animals: currentAnimals,
      animalSelected: clearSelected ? null : _currentanimalSighting!.animalSelected,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      locations: _currentanimalSighting?.locations,  // Preserve the locations
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );

    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateDescription(String description) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    final oldJson = _currentanimalSighting!.toJson();
    
    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting!.animals,
      animalSelected: _currentanimalSighting!.animalSelected,
      category: _currentanimalSighting!.category,
      description: description,
      locations: _currentanimalSighting?.locations,  // Preserve the locations
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );
    
    _notifyListeners();
    return _currentanimalSighting!;
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  AnimalSightingModel? getCurrentanimalSighting() => _currentanimalSighting;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void clearCurrentanimalSighting() {
    final greenLog = '\x1B[32m';
    final resetLog = '\x1B[0m';
    
    debugPrint('${greenLog}[AnimalSightingReportingManager] Current state before clearing: ${_currentanimalSighting?.toJson()}$resetLog');
    _currentanimalSighting = null;
    debugPrint('${greenLog}[AnimalSightingReportingManager] State after clearing: $_currentanimalSighting$resetLog');
    
    _notifyListeners();
  }

  @override
  bool validateActiveAnimalSighting() {
    final currentSighting = getCurrentanimalSighting();
    if (currentSighting == null) {
      debugPrint('[AnimalSightingManager] No active animal sighting found');
      return false;
    }
    return true;
  }

  @override
  AnimalSightingModel processAnimalSelection(
    AnimalModel selectedAnimal,
    AnimalManagerInterface animalManager,
  ) {
    final processedAnimal = animalManager.handleAnimalSelection(selectedAnimal);
    return updateSelectedAnimal(processedAnimal);
  }

  @override
  bool handleGenderSelection(AnimalGender selectedGender) {
    final orangeLog = '\x1B[38;5;208m';
    final resetLog = '\x1B[0m';
    
    debugPrint('${orangeLog}[AnimalSightingManager] Handling gender selection: $selectedGender$resetLog');

    try {
      updateGender(selectedGender);
      debugPrint('[AnimalSightingManager] Successfully updated gender');
      return true;
    } catch (e) {
      debugPrint('[AnimalSightingManager] Failed to update gender: $e');
      return false;
    }
  }

  @override
  AnimalSightingModel updateAnimal(AnimalModel animalToUpdate) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    debugPrint('[AnimalSightingManager] Updating animal with new data...');
    debugPrint('[AnimalSightingManager] Animal to update: {animalId: ${animalToUpdate.animalId}, animalName: ${animalToUpdate.animalName}, condition: ${animalToUpdate.condition}}');

    List<AnimalModel> updatedAnimals = List.from(_currentanimalSighting!.animals ?? []);

    // Try to find if this animalId already exists
    final existingAnimalIndex = updatedAnimals.indexWhere(
      (a) => a.animalId == animalToUpdate.animalId
    );

    if (existingAnimalIndex != -1) {
      debugPrint('[AnimalSightingManager] Updating existing animal at index: $existingAnimalIndex');
      debugPrint('[AnimalSightingManager] Old animal data: {animalId: ${updatedAnimals[existingAnimalIndex].animalId}, animalName: ${updatedAnimals[existingAnimalIndex].animalName}, condition: ${updatedAnimals[existingAnimalIndex].condition}}');
      updatedAnimals[existingAnimalIndex] = animalToUpdate;
    } else {
      debugPrint('[AnimalSightingManager] Adding new animal to the list');
      updatedAnimals.add(animalToUpdate);
    }

    _currentanimalSighting = AnimalSightingModel(
      animals: updatedAnimals,
      animalSelected: animalToUpdate,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      locations: _currentanimalSighting?.locations,
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );

    debugPrint('[AnimalSightingManager] Updated sighting state: ${_currentanimalSighting!.toJson()}');
    _notifyListeners();
    return _currentanimalSighting!;
  }

  // Single source of truth for updating animal data
  AnimalSightingModel updateAnimalData(
    String animalName,
    AnimalGender gender, {
    ViewCountModel? viewCount,
    AnimalCondition? condition,
    String? description,
  }) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    final updatedAnimals = List<AnimalModel>.from(_currentanimalSighting!.animals ?? []);
    final animalIndex = updatedAnimals.indexWhere(
      (animal) => animal.animalName == animalName && animal.gender == gender
    );

    if (animalIndex != -1) {
      final currentAnimal = updatedAnimals[animalIndex];
      updatedAnimals[animalIndex] = AnimalModel(
        animalId: currentAnimal.animalId,  // Preserve ID
        animalImagePath: currentAnimal.animalImagePath,
        animalName: currentAnimal.animalName,
        genderViewCounts: viewCount != null 
            ? [AnimalGenderViewCount(gender: currentAnimal.gender ?? AnimalGender.onbekend, viewCount: viewCount)]
            : currentAnimal.genderViewCounts,
        condition: condition ?? currentAnimal.condition,
    
      );
    }

    _currentanimalSighting = AnimalSightingModel(
      animals: updatedAnimals,
      animalSelected: _currentanimalSighting!.animalSelected,
      category: _currentanimalSighting!.category,
      description: description ?? _currentanimalSighting!.description,
      locations: _currentanimalSighting?.locations,  // Preserve the locations
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );

    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateLocation(LocationModel location) {
    List<LocationModel> updatedLocations = List.from(_currentanimalSighting?.locations ?? []);
    updatedLocations.add(location);

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: _currentanimalSighting?.animalSelected,
      category: _currentanimalSighting?.category,
      description: _currentanimalSighting?.description,
      locations: updatedLocations,  // Use the updated list
      dateTime: _currentanimalSighting?.dateTime,
      images: _currentanimalSighting?.images,
    );
    _notifyListeners();
    return _currentanimalSighting!;
  }

  // Add method to remove location if needed
  @override
  AnimalSightingModel removeLocation(LocationModel location) {
    List<LocationModel> updatedLocations = List.from(_currentanimalSighting?.locations ?? []);
    updatedLocations.removeWhere((loc) => loc.source == location.source);  // Assuming LocationModel has an id

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: _currentanimalSighting?.animalSelected,
      category: _currentanimalSighting?.category,
      description: _currentanimalSighting?.description,
      locations: updatedLocations,
      dateTime: _currentanimalSighting?.dateTime,
      images: _currentanimalSighting?.images,
    );
    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateDateTimeModel(DateTimeModel dateTimeModel) {
    // Create a new sighting if none exists
    if (_currentanimalSighting == null) {
      _currentanimalSighting = createanimalSighting();
    }

    final oldJson = _currentanimalSighting?.toJson();
    debugPrint('[AnimalSightingManager] Updating datetime model. Old state: $oldJson');
    debugPrint('[AnimalSightingManager] New datetime model: ${dateTimeModel.toJson()}');
    
    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: _currentanimalSighting?.animalSelected,
      category: _currentanimalSighting?.category,
      description: _currentanimalSighting?.description,
      locations: _currentanimalSighting?.locations,
      dateTime: dateTimeModel,
      images: _currentanimalSighting?.images,
    );

    debugPrint('[AnimalSightingManager] New state: ${_currentanimalSighting?.toJson()}');
    _notifyListeners();
    return _currentanimalSighting!;
  }
  
  @override
  AnimalSightingModel updateDateTime(DateTime dateTime) {
    // Create a new sighting if none exists
    if (_currentanimalSighting == null) {
      _currentanimalSighting = createanimalSighting();
    }

    final oldJson = _currentanimalSighting?.toJson();
    debugPrint('[AnimalSightingManager] Updating datetime. Old state: $oldJson');
    debugPrint('[AnimalSightingManager] New datetime: $dateTime');
    
    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: _currentanimalSighting?.animalSelected,
      category: _currentanimalSighting?.category,
      description: _currentanimalSighting?.description,
      locations: _currentanimalSighting?.locations,
      dateTime: DateTimeModel(dateTime: dateTime, isUnknown: false),
      images: _currentanimalSighting?.images,
    );

    debugPrint('[AnimalSightingManager] New state: ${_currentanimalSighting?.toJson()}');
    _notifyListeners();
    return _currentanimalSighting!;
  }
}
























