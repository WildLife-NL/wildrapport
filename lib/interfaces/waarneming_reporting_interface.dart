import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/waarneming_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/view_count_model.dart';

abstract class WaarnemingReportingInterface {
  /// Creates a new waarneming model with empty fields
  WaarnemingModel createWaarneming();

  /// Updates the waarneming with the selected animal
  WaarnemingModel updateSelectedAnimal(AnimalModel selectedAnimal);

  /// Updates the animal's condition in the waarneming
  WaarnemingModel updateCondition(AnimalCondition condition);

  /// Updates the animal's gender in the waarneming
  WaarnemingModel updateGender(AnimalGender gender);

  /// Updates the animal's age in the waarneming
  WaarnemingModel updateAge(AnimalAge age);

  /// Updates the animal's view count in the waarneming
  WaarnemingModel updateViewCount(ViewCountModel viewCount);

  /// Updates the category in the waarneming
  WaarnemingModel updateCategory(AnimalCategory category);

  /// Gets the current waarneming model
  WaarnemingModel? getCurrentWaarneming();

  /// Adds a listener for state changes
  void addListener(VoidCallback listener);

  /// Removes a listener
  void removeListener(VoidCallback listener);

  /// Finalizes the currently selected animal by adding it to the animals list
  WaarnemingModel finalizeAnimal();

  /// Clears the current waarneming
  void clearCurrentWaarneming();

  /// Updates the description in the waarneming
  WaarnemingModel updateDescription(String description);
}



