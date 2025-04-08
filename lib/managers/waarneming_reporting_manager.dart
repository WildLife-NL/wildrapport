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
      category: null,
      description: null,
      location: null,
      dateTime: null,
      images: null,
    );
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateSelectedAnimal(AnimalModel selectedAnimal) {
    debugPrint('[WaarnemingManager] Updating selected animal: ${selectedAnimal.animalName}');
    
    final oldJson = _currentWaarneming?.toJson() ?? {};
    
    // Preserve the existing condition when updating the animal
    final existingCondition = _currentWaarneming?.animals?.firstOrNull?.condition;
    debugPrint('[WaarnemingManager] Existing condition: $existingCondition');
    
    final updatedAnimal = AnimalModel(
      animalImagePath: selectedAnimal.animalImagePath,
      animalName: selectedAnimal.animalName,
      condition: existingCondition,  // Preserve the existing condition
      gender: selectedAnimal.gender,
      viewCount: selectedAnimal.viewCount,
    );

    _currentWaarneming = WaarnemingModel(
      animals: [updatedAnimal],
      category: _currentWaarneming?.category,
      description: _currentWaarneming?.description,
      location: _currentWaarneming?.location,
      dateTime: _currentWaarneming?.dateTime,
      images: _currentWaarneming?.images,
    );
    
    debugPrint('[WaarnemingManager] Updated waarneming state: ${_currentWaarneming!.toJson()}');
    _logStateChange(oldJson);
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateCondition(AnimalCondition condition) {
    debugPrint('[WaarnemingManager] Updating condition: ${condition.toString()}');
    
    if (_currentWaarneming == null) {
      debugPrint('[WaarnemingManager] Creating new waarneming as none exists');
      _currentWaarneming = createWaarneming();
    }

    final oldJson = _currentWaarneming!.toJson();
    
    // Get the current animal or create a new one with the condition
    final currentAnimal = _currentWaarneming!.animals?.firstOrNull ?? AnimalModel(
      animalImagePath: null,
      animalName: '',
      condition: condition,  // Set the condition here for new animals
      gender: null,
      viewCount: null,
    );

    // Create updated animal with the new condition while preserving other properties
    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      condition: condition,  // Set the new condition here
      gender: currentAnimal.gender,
      viewCount: currentAnimal.viewCount,
    );

    // Update the waarneming with the updated animal
    _currentWaarneming = WaarnemingModel(
      animals: [updatedAnimal],
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _logStateChange(oldJson);
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateGender(AnimalGender gender) {
    debugPrint('[WaarnemingManager] Updating gender: ${gender.toString()}');
    
    if (_currentWaarneming == null) {
      debugPrint('[WaarnemingManager] ERROR: No current waarneming found when updating gender');
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    // Get the current animal and update its gender
    final currentAnimal = _currentWaarneming!.animals?.firstOrNull;
    if (currentAnimal == null) {
      debugPrint('[WaarnemingManager] ERROR: No animal found when updating gender');
      throw StateError('No animal found in current waarneming');
    }

    // Create updated animal while preserving all existing properties including condition
    final updatedAnimal = AnimalModel(
      animalImagePath: currentAnimal.animalImagePath,
      animalName: currentAnimal.animalName,
      condition: currentAnimal.condition,  // Ensure we keep the existing condition
      gender: gender,  // Update the gender
      viewCount: currentAnimal.viewCount ?? ViewCountModel(),  // Ensure viewCount is never null
    );

    debugPrint('[WaarnemingManager] Updated animal condition: ${updatedAnimal.condition}');

    _currentWaarneming = WaarnemingModel(
      animals: [updatedAnimal],
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _logStateChange(oldJson);
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateAge(AnimalAge age) {
    debugPrint('[WaarnemingManager] Updating age: ${age.toString()}');
    
    if (_currentWaarneming == null) {
      debugPrint('[WaarnemingManager] ERROR: No current waarneming found when updating age');
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    // Get the current animal and update its age
    final currentAnimal = _currentWaarneming!.animals?.firstOrNull;
    if (currentAnimal == null) {
      debugPrint('[WaarnemingManager] ERROR: No animal found when updating age');
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
      animals: [updatedAnimal],
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _logStateChange(oldJson);
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateViewCount(ViewCountModel viewCount) {
    debugPrint('[WaarnemingManager] Updating view count');
    
    if (_currentWaarneming == null) {
      debugPrint('[WaarnemingManager] ERROR: No current waarneming found when updating view count');
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    // Get the current animal and update its view count
    final currentAnimal = _currentWaarneming!.animals?.firstOrNull;
    if (currentAnimal == null) {
      debugPrint('[WaarnemingManager] ERROR: No animal found when updating view count');
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
      animals: [updatedAnimal],
      category: _currentWaarneming!.category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _logStateChange(oldJson);
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateCategory(AnimalCategory category) {
    debugPrint('[WaarnemingManager] Updating category: ${category.toString()}');
    
    if (_currentWaarneming == null) {
      debugPrint('[WaarnemingManager] ERROR: No current waarneming found when updating category');
      throw StateError('No current waarneming found');
    }

    final oldJson = _currentWaarneming!.toJson();
    
    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming!.animals,
      category: category,
      description: _currentWaarneming!.description,
      location: _currentWaarneming!.location,
      dateTime: _currentWaarneming!.dateTime,
      images: _currentWaarneming!.images,
    );
    
    _logStateChange(oldJson);
    return _currentWaarneming!;
  }

  void _logStateChange(Map<String, dynamic> oldJson) {
    final newJson = _currentWaarneming!.toJson();
    final greenStart = '\x1B[32m';
    final colorEnd = '\x1B[0m';
    
    final prettyJson = newJson.map((key, value) {
      final oldValue = oldJson[key];
      final isChanged = oldValue != value;
      final prettyValue = isChanged ? '$greenStart$value$colorEnd' : value;
      return MapEntry(key, prettyValue);
    });
    
    debugPrint('[WaarnemingManager] Waarneming state after update: $prettyJson');
    _notifyListeners();
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

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}











