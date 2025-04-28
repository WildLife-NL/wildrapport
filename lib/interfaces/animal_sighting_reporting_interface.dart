import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/managers/animal_sighting_reporting_manager.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/models/date_time_model.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/location_model.dart';
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

  /// Converts a string representation of a category to AnimalCategory enum
  AnimalCategory convertStringToCategory(String status);

  /// Gets the current animalSighting model
  AnimalSightingModel? getCurrentanimalSighting();

  /// Adds a listener for state changes
  void addListener(VoidCallback listener);

  /// Removes a listener
  void removeListener(VoidCallback listener);

  /// Finalizes the currently selected animal by adding it to the animals list
  /// If clearSelected is true (default), the selected animal will be cleared after adding
  AnimalSightingModel finalizeAnimal({bool clearSelected = true});

  /// Clears the current animalSighting
  void clearCurrentanimalSighting();

  /// Updates the description in the animalSighting
  AnimalSightingModel updateDescription(String description);

  AnimalSightingModel updateConditionFromString(String status);
  static const List<({String text, IconData icon, String? imagePath})> conditionButtons = 
    AnimalSightingReportingManager.conditionButtons;

  /// Validates if there is an active animal sighting
  bool validateActiveAnimalSighting();

  /// Processes animal selection by coordinating with animal manager
  AnimalSightingModel processAnimalSelection(
    AnimalModel selectedAnimal,
    AnimalManagerInterface animalManager,
  );

  /// Handles gender selection and validation
  /// Returns true if successful, false if there was an error
  bool handleGenderSelection(AnimalGender selectedGender);

  /// Updates an existing animal in the animals list
  AnimalSightingModel updateAnimal(AnimalModel updatedAnimal);

  /// Updates the location in the animalSighting
  AnimalSightingModel updateLocation(LocationModel location);

  /// Removes a location from the animalSighting
  AnimalSightingModel removeLocation(LocationModel location);

  /// Updates the dateTime in the animalSighting
  AnimalSightingModel updateDateTime(DateTime dateTime);

  /// Updates the dateTime model in the animalSighting
  AnimalSightingModel updateDateTimeModel(DateTimeModel dateTimeModel);
}













