import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/view_count_model.dart';

abstract class AnimalSightingReportingInterface {
  /// Creates a new animalSighting model with empty fields
  AnimalSightingModel createanimalSighting();

  /// Updates the animalSighting with the selected animal
  AnimalSightingModel updateSelectedAnimal(AnimalModel selectedAnimal);

  /// Updates the animal's condition in the animalSighting
  AnimalSightingModel updateCondition(AnimalCondition condition);

  /// Updates the animal's gender in the animalSighting
  AnimalSightingModel updateGender(AnimalGender gender);

  /// Updates the animal's age in the animalSighting
  AnimalSightingModel updateAge(AnimalAge age);

  /// Updates the animal's view count in the animalSighting
  AnimalSightingModel updateViewCount(ViewCountModel viewCount);

  /// Updates the category in the animalSighting
  AnimalSightingModel updateCategory(AnimalCategory category);

  /// Gets the current animalSighting model
  AnimalSightingModel? getCurrentanimalSighting();

  /// Adds a listener for state changes
  void addListener(VoidCallback listener);

  /// Removes a listener
  void removeListener(VoidCallback listener);

  /// Finalizes the currently selected animal by adding it to the animals list
  AnimalSightingModel finalizeAnimal();

  /// Clears the current animalSighting
  void clearCurrentanimalSighting();

  /// Updates the description in the animalSighting
  AnimalSightingModel updateDescription(String description);
}



