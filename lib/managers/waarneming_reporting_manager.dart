import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/waarneming_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/view_count_model.dart';

class WaarnemingReportingManager implements WaarnemingReportingInterface {
  final List<VoidCallback> _listeners = [];
  WaarnemingModel? _currentWaarneming;

  @override
  WaarnemingModel createWaarneming() {
    _currentWaarneming = WaarnemingModel(
      animals: [],
      animalSelected: null,
      category: null,
      description: null,
      location: null,
      dateTime: null,
      images: null,
    );
    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateSelectedAnimal(AnimalModel selectedAnimal) {
    final oldJson = _currentWaarneming?.toJson();
    
    // Preserve the condition from the current waarneming if it exists
    final updatedAnimal = AnimalModel(
      animalImagePath: selectedAnimal.animalImagePath,
      animalName: selectedAnimal.animalName,
      condition: _currentWaarneming?.animalSelected?.condition ?? selectedAnimal.condition,
      gender: selectedAnimal.gender,
      viewCount: selectedAnimal.viewCount,
    );
    
    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming?.animals ?? [],
      animalSelected: updatedAnimal,  // Use the updated animal that preserves the condition
      category: _currentWaarneming?.category,
      description: _currentWaarneming?.description,
      location: _currentWaarneming?.location,
      dateTime: _currentWaarneming?.dateTime,
      images: _currentWaarneming?.images,
    );
    
    debugPrint('[WaarnemingManager] Updating selected animal. Previous state: $oldJson');
    debugPrint('[WaarnemingManager] New state: ${_currentWaarneming!.toJson()}');
    
    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateCondition(AnimalCondition condition) {
    if (_currentWaarneming == null) {
      _currentWaarneming = createWaarneming();
    }

    final oldJson = _currentWaarneming!.toJson();
    final currentAnimal = _currentWaarneming!.animalSelected;
    
    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal?.animalImagePath,
      animalName: currentAnimal?.animalName ?? '',
      condition: condition,
      gender: currentAnimal?.gender,
      viewCount: currentAnimal?.viewCount,
    );

    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateGender(AnimalGender gender) {
    if (_currentWaarneming == null) {
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    final currentAnimal = _currentWaarneming!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current waarneming');
    }

    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      condition: currentAnimal.condition,
      gender: gender,
      viewCount: currentAnimal.viewCount ?? ViewCountModel(),
    );

    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateAge(AnimalAge age) {
    if (_currentWaarneming == null) {
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    final currentAnimal = _currentWaarneming!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current waarneming');
    }

    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      condition: currentAnimal.condition,
      gender: currentAnimal.gender,
      viewCount: currentAnimal.viewCount,
    );

    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateViewCount(ViewCountModel viewCount) {
    if (_currentWaarneming == null) {
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    final currentAnimal = _currentWaarneming!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current waarneming');
    }

    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      condition: currentAnimal.condition,
      gender: currentAnimal.gender,
      viewCount: viewCount,
    );

    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateCategory(AnimalCategory category) {
    if (_currentWaarneming == null) {
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming!.animals,
      animalSelected: _currentWaarneming!.animalSelected,  // Add this line to preserve the selected animal and its condition
      category: category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    debugPrint('[WaarnemingManager] Updating category. Previous state: $oldJson');
    debugPrint('[WaarnemingManager] New state: ${_currentWaarneming!.toJson()}');
    
    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel finalizeAnimal() {
    if (_currentWaarneming?.animalSelected == null) {
      throw StateError('No animal selected to finalize');
    }

    final oldJson = _currentWaarneming!.toJson();
    final currentAnimals = List<AnimalModel>.from(_currentWaarneming!.animals ?? []);
    currentAnimals.add(_currentWaarneming!.animalSelected!);

    _currentWaarneming = WaarnemingModel(
      animals: currentAnimals,
      animalSelected: null, // Clear the selected animal
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );

    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateDescription(String description) {
    if (_currentWaarneming == null) {
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming!.animals,
      animalSelected: _currentWaarneming!.animalSelected,
      category: _currentWaarneming!.category,
      description: description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _notifyListeners();
    return _currentWaarneming!;
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  WaarnemingModel? getCurrentWaarneming() => _currentWaarneming;

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  @override
  void clearCurrentWaarneming() {
    _currentWaarneming = null;
    _notifyListeners();
  }
}



















