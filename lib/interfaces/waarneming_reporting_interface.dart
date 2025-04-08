import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/waarneming_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';

abstract class WaarnemingReportingInterface {
  /// Creates a new waarneming model with null fields
  WaarnemingModel createWaarneming();

  /// Updates the waarneming with the selected animal
  WaarnemingModel updateSelectedAnimal(AnimalModel selectedAnimal);

  /// Updates the waarneming with the selected condition
  WaarnemingModel updateCondition(AnimalCondition condition);

  /// Gets the current waarneming model
  WaarnemingModel? getCurrentWaarneming();

  /// Adds a listener for state changes
  void addListener(VoidCallback listener);

  /// Removes a listener
  void removeListener(VoidCallback listener);
}


