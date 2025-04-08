import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/models/waarneming_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';

class WaarnemingReportingManager implements WaarnemingReportingInterface {
  final List<VoidCallback> _listeners = [];
  WaarnemingModel? _currentWaarneming;

  @override
  WaarnemingModel createWaarneming() {
    _currentWaarneming = WaarnemingModel(
      animals: null,
      condition: null,
      category: null,
      gender: null,
      age: null,
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
    
    _currentWaarneming = WaarnemingModel(
      animals: [selectedAnimal],
      condition: _currentWaarneming?.condition,
      category: _currentWaarneming?.category,
      gender: _currentWaarneming?.gender,
      age: _currentWaarneming?.age,
      description: _currentWaarneming?.description,
      location: _currentWaarneming?.location,
      dateTime: _currentWaarneming?.dateTime,
      images: _currentWaarneming?.images,
    );
    
    _notifyListeners();
    return _currentWaarneming!;
  }

  @override
  WaarnemingModel updateCondition(AnimalCondition condition) {
    debugPrint('[WaarnemingManager] Updating condition: ${condition.toString()}');
    
    if (_currentWaarneming == null) {
      debugPrint('[WaarnemingManager] ERROR: No current waarneming found when updating condition');
      throw StateError('No current waarneming found');
    }
    
    _currentWaarneming = WaarnemingModel(
      animals: _currentWaarneming?.animals,
      condition: condition,
      category: _currentWaarneming?.category,
      gender: _currentWaarneming?.gender,
      age: _currentWaarneming?.age,
      description: _currentWaarneming?.description,
      location: _currentWaarneming?.location,
      dateTime: _currentWaarneming?.dateTime,
      images: _currentWaarneming?.images,
    );
    
    debugPrint('[WaarnemingManager] Condition updated successfully. New state: ${_currentWaarneming?.toJson()}');
    _notifyListeners();
    return _currentWaarneming!;
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



