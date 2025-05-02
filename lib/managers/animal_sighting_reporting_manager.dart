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

  // Predefined list of condition options
  static const List<({String text, IconData icon, String? imagePath})> conditionButtons = [
    (text: 'Gezond', icon: Icons.check_circle, imagePath: null),
    (text: 'Ziek', icon: Icons.sick, imagePath: null),
    (text: 'Dood', icon: Icons.dangerous, imagePath: null),
    (text: 'Andere', icon: Icons.more_horiz, imagePath: null),
  ];

  // Mapping functions
  AnimalCondition _mapStringToCondition(String status) {
    switch (status.toLowerCase()) {
      case 'gezond': return AnimalCondition.gezond;
      case 'ziek': return AnimalCondition.ziek;
      case 'dood': return AnimalCondition.dood;
      default: return AnimalCondition.andere;
    }
  }

  @override
  AnimalCategory convertStringToCategory(String status) {
    switch (status.toLowerCase()) {
      case 'evenhoevigen': return AnimalCategory.evenhoevigen;
      case 'knaagdieren': return AnimalCategory.knaagdieren;
      case 'roofdieren': return AnimalCategory.roofdieren;
      case 'andere': return AnimalCategory.andere;
      default: throw StateError('Invalid category: $status');
    }
  }

  // Core update method
  AnimalSightingModel _updateSighting({
    List<AnimalModel>? animals,
    AnimalModel? animalSelected,
    AnimalCategory? category,
    String? description,
    List<LocationModel>? locations,
    DateTimeModel? dateTime,
    dynamic images,
    bool logChanges = false,
    String logPrefix = '',
  }) {
    _currentanimalSighting ??= createanimalSighting();
    
    if (logChanges) {
      debugPrint('$logPrefix Previous state: ${_currentanimalSighting?.toJson()}');
    }
    
    _currentanimalSighting = AnimalSightingModel(
      animals: animals ?? _currentanimalSighting!.animals ?? [],
      animalSelected: animalSelected ?? _currentanimalSighting!.animalSelected,
      category: category ?? _currentanimalSighting!.category,
      description: description ?? _currentanimalSighting!.description,
      locations: locations ?? _currentanimalSighting!.locations ?? [],
      dateTime: dateTime ?? _currentanimalSighting!.dateTime,
      images: images ?? _currentanimalSighting!.images,
    );
    
    if (logChanges) {
      debugPrint('$logPrefix New state: ${_currentanimalSighting!.toJson()}');
    }
    
    _notifyListeners();
    return _currentanimalSighting!;
  }

  // Helper to create animal model with preserved properties
  AnimalModel _createAnimalModel({
    required AnimalModel source,
    String? animalId,
    String? animalImagePath,
    String? animalName,
    List<AnimalGenderViewCount>? genderViewCounts,
    AnimalCondition? condition,
  }) {
    return AnimalModel(
      animalId: animalId ?? source.animalId,
      animalImagePath: animalImagePath ?? source.animalImagePath,
      animalName: animalName ?? source.animalName,
      genderViewCounts: genderViewCounts ?? source.genderViewCounts,
      condition: condition ?? source.condition,
    );
  }

  // Helper to validate current sighting exists
  void _validateCurrentSighting() {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }
  }

  // Helper to validate current animal exists
  void _validateCurrentAnimal() {
    _validateCurrentSighting();
    if (_currentanimalSighting!.animalSelected == null) {
      throw StateError('No animal found in current animalSighting');
    }
  }

  // Interface implementations
  @override
  AnimalSightingModel createanimalSighting() {
    _currentanimalSighting = AnimalSightingModel(
      animals: [],
      animalSelected: null,
      category: null,
      description: null,
      locations: [],
      dateTime: null,
      images: null,
    );
    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateSelectedAnimal(AnimalModel selectedAnimal) {
    final updatedAnimal = _createAnimalModel(
      source: selectedAnimal,
      condition: _currentanimalSighting?.animalSelected?.condition ?? selectedAnimal.condition,
    );
    
    return _updateSighting(
      animalSelected: updatedAnimal,
      logChanges: true,
      logPrefix: '[animalSightingManager] Updating selected animal. '
    );
  }

  @override
  AnimalSightingModel updateCondition(AnimalCondition condition) {
    _currentanimalSighting ??= createanimalSighting();

    final currentAnimal = _currentanimalSighting!.animalSelected ?? AnimalModel(
      animalId: null,
      animalImagePath: null,
      animalName: '',
      genderViewCounts: [],
      condition: condition,
    );
    
    final updatedAnimal = _createAnimalModel(
      source: currentAnimal,
      condition: condition,
    );

    return _updateSighting(animalSelected: updatedAnimal);
  }

  @override
  AnimalSightingModel updateConditionFromString(String status) {
    return updateCondition(_mapStringToCondition(status));
  }

  @override
  AnimalSightingModel updateGender(AnimalGender gender) {
    _validateCurrentAnimal();
    final currentAnimal = _currentanimalSighting!.animalSelected!;

    final existingAnimal = _currentanimalSighting!.animals?.firstWhere(
      (a) => a.genderViewCounts.any((gvc) => gvc.gender == gender),
      orElse: () => _createAnimalModel(
        source: currentAnimal,
        genderViewCounts: [],
      ),
    );

    final genderViewCounts = existingAnimal?.genderViewCounts ?? 
      [AnimalGenderViewCount(gender: gender, viewCount: ViewCountModel())];

    final updatedAnimal = _createAnimalModel(
      source: currentAnimal,
      genderViewCounts: genderViewCounts,
    );

    return _updateSighting(animalSelected: updatedAnimal);
  }

  @override
  AnimalSightingModel updateAge(AnimalAge age) {
    _validateCurrentAnimal();
    return _updateSighting(animalSelected: _currentanimalSighting!.animalSelected);
  }

  @override
  AnimalSightingModel updateViewCount(ViewCountModel viewCount) {
    _validateCurrentAnimal();
    return _updateSighting(animalSelected: _currentanimalSighting!.animalSelected);
  }

  @override
  AnimalSightingModel updateCategory(AnimalCategory category) {
    _validateCurrentSighting();
    return _updateSighting(
      category: category,
      logChanges: true,
      logPrefix: '[AnimalSightingManager] Updating category. '
    );
  }

  @override
  AnimalSightingModel finalizeAnimal({bool clearSelected = true}) {
    _validateCurrentAnimal();

    final currentAnimals = List<AnimalModel>.from(_currentanimalSighting!.animals ?? []);
    currentAnimals.add(_currentanimalSighting!.animalSelected!);

    return _updateSighting(
      animals: currentAnimals,
      animalSelected: clearSelected ? null : _currentanimalSighting!.animalSelected
    );
  }

  @override
  AnimalSightingModel updateDescription(String description) {
    _validateCurrentSighting();
    return _updateSighting(description: description);
  }

  @override
  AnimalSightingModel? getCurrentanimalSighting() => _currentanimalSighting;

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  void clearCurrentanimalSighting() {
    final greenLog = '\x1B[32m';
    final resetLog = '\x1B[0m';
    
    debugPrint('$greenLog[AnimalSightingReportingManager] Current state before clearing: ${_currentanimalSighting?.toJson()}$resetLog');
    _currentanimalSighting = null;
    debugPrint('$greenLog[AnimalSightingReportingManager] State after clearing: $_currentanimalSighting$resetLog');
    
    _notifyListeners();
  }

  @override
  bool validateActiveAnimalSighting() {
    if (_currentanimalSighting == null) {
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
    return updateSelectedAnimal(animalManager.handleAnimalSelection(selectedAnimal));
  }

  @override
  bool handleGenderSelection(AnimalGender selectedGender) {
    final orangeLog = '\x1B[38;5;208m';
    final resetLog = '\x1B[0m';
    
    debugPrint('$orangeLog[AnimalSightingManager] Handling gender selection: $selectedGender$resetLog');

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
    _validateCurrentSighting();

    debugPrint('[AnimalSightingManager] Updating animal: {id: ${animalToUpdate.animalId}, name: ${animalToUpdate.animalName}}');

    List<AnimalModel> updatedAnimals = List.from(_currentanimalSighting!.animals ?? []);
    final existingIndex = updatedAnimals.indexWhere((a) => a.animalId == animalToUpdate.animalId);

    if (existingIndex != -1) {
      debugPrint('[AnimalSightingManager] Updating existing animal at index: $existingIndex');
      updatedAnimals[existingIndex] = animalToUpdate;
    } else {
      debugPrint('[AnimalSightingManager] Adding new animal to the list');
      updatedAnimals.add(animalToUpdate);
    }

    return _updateSighting(
      animals: updatedAnimals,
      animalSelected: animalToUpdate,
      logChanges: true,
      logPrefix: '[AnimalSightingManager] Updated sighting state: '
    );
  }

  AnimalSightingModel updateAnimalData(
    String animalName,
    AnimalGender gender, {
    ViewCountModel? viewCount,
    AnimalCondition? condition,
    String? description,
  }) {
    _validateCurrentSighting();

    final updatedAnimals = List<AnimalModel>.from(_currentanimalSighting!.animals ?? []);
    final animalIndex = updatedAnimals.indexWhere(
      (animal) => animal.animalName == animalName && 
                  animal.genderViewCounts.any((gvc) => gvc.gender == gender)
    );

    if (animalIndex != -1) {
      final currentAnimal = updatedAnimals[animalIndex];
      updatedAnimals[animalIndex] = _createAnimalModel(
        source: currentAnimal,
        genderViewCounts: viewCount != null 
            ? [AnimalGenderViewCount(gender: gender, viewCount: viewCount)]
            : currentAnimal.genderViewCounts,
        condition: condition,
      );
    }

    return _updateSighting(
      animals: updatedAnimals,
      description: description ?? _currentanimalSighting!.description ?? '',
      logChanges: true,
      logPrefix: '[AnimalSightingManager] Updated sighting with description: '
    );
  }

  @override
  AnimalSightingModel updateLocation(LocationModel location) {
    List<LocationModel> updatedLocations = List.from(_currentanimalSighting?.locations ?? []);
    updatedLocations.add(location);
    return _updateSighting(locations: updatedLocations);
  }

  @override
  AnimalSightingModel removeLocation(LocationModel location) {
    List<LocationModel> updatedLocations = List.from(_currentanimalSighting?.locations ?? []);
    updatedLocations.removeWhere((loc) => loc.source == location.source);
    return _updateSighting(locations: updatedLocations);
  }

  @override
  AnimalSightingModel updateDateTimeModel(DateTimeModel dateTimeModel) {
    return _updateSighting(
      dateTime: dateTimeModel,
      logChanges: true,
      logPrefix: '[AnimalSightingManager] Updating datetime model. '
    );
  }
  
  @override
  AnimalSightingModel updateDateTime(DateTime dateTime) {
    return updateDateTimeModel(DateTimeModel(dateTime: dateTime, isUnknown: false));
  }
}






























