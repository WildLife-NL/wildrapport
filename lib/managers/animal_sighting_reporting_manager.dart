import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/view_count_model.dart';

class AnimalSightingReportingManager implements AnimalSightingReportingInterface {
  final List<VoidCallback> _listeners = [];
  AnimalSightingModel? _currentanimalSighting;

  @override
  AnimalSightingModel createanimalSighting() {
    _currentanimalSighting = AnimalSightingModel(
      animals: [],
      animalSelected: null,
      category: null,
      description: null,
      location: null,
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
      animalImagePath: selectedAnimal.animalImagePath,
      animalName: selectedAnimal.animalName,
      condition: _currentanimalSighting?.animalSelected?.condition ?? selectedAnimal.condition,
      gender: selectedAnimal.gender,
      viewCount: selectedAnimal.viewCount,
    );
    
    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,  // Use the updated animal that preserves the condition
      category: _currentanimalSighting?.category,
      description: _currentanimalSighting?.description,
      location: _currentanimalSighting?.location,
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
    if (_currentanimalSighting == null) {
      _currentanimalSighting = createanimalSighting();
    }

    final oldJson = _currentanimalSighting!.toJson();
    final currentAnimal = _currentanimalSighting!.animalSelected;
    
    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal?.animalImagePath,
      animalName: currentAnimal?.animalName ?? '',
      condition: condition,
      gender: currentAnimal?.gender,
      viewCount: currentAnimal?.viewCount,
    );

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      location: _currentanimalSighting!.location,
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );
    
    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateGender(AnimalGender gender) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    final oldJson = _currentanimalSighting!.toJson();
    
    final currentAnimal = _currentanimalSighting!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current animalSighting');
    }

    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      condition: currentAnimal.condition,
      gender: gender,
      viewCount: currentAnimal.viewCount ?? ViewCountModel(),
    );

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      location: _currentanimalSighting!.location,
      dateTime: _currentanimalSighting!.dateTime,
      images: _currentanimalSighting!.images,
    );
    
    _notifyListeners();
    return _currentanimalSighting!;
  }

  @override
  AnimalSightingModel updateAge(AnimalAge age) {
    if (_currentanimalSighting == null) {
      throw StateError('No current animalSighting found');
    }

    final oldJson = _currentanimalSighting!.toJson();
    
    final currentAnimal = _currentanimalSighting!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current animalSighting');
    }

    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      condition: currentAnimal.condition,
      gender: currentAnimal.gender,
      viewCount: currentAnimal.viewCount,
    );

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      location: _currentanimalSighting!.location,
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

    final oldJson = _currentanimalSighting!.toJson();
    
    final currentAnimal = _currentanimalSighting!.animalSelected;
    if (currentAnimal == null) {
      throw StateError('No animal found in current animalSighting');
    }

    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      condition: currentAnimal.condition,
      gender: currentAnimal.gender,
      viewCount: viewCount,
    );

    _currentanimalSighting = AnimalSightingModel(
      animals: _currentanimalSighting?.animals ?? [],
      animalSelected: updatedAnimal,
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      location: _currentanimalSighting!.location,
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
      location: _currentanimalSighting!.location,
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
    currentAnimals.add(_currentanimalSighting!.animalSelected!);

    _currentanimalSighting = AnimalSightingModel(
      animals: currentAnimals,
      animalSelected: clearSelected ? null : _currentanimalSighting!.animalSelected, // Only clear if specified
      category: _currentanimalSighting!.category,
      description: _currentanimalSighting!.description,
      location: _currentanimalSighting!.location,
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
      location: _currentanimalSighting!.location,
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
    _currentanimalSighting = null;
    _notifyListeners();
  }
}




















