import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/ui_models/date_time_model.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/beta_models/location_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/observed_animal_entry.dart';

abstract class AnimalSightingReportingInterface {
  AnimalSightingModel createanimalSighting();

  AnimalSightingModel updateSelectedAnimal(AnimalModel selectedAnimal);

  AnimalSightingModel updateCurrentanimalSighting(AnimalSightingModel sighting);

  AnimalSightingModel updateGender(AnimalGender gender);

  AnimalSightingModel updateAge(AnimalAge age);

  AnimalSightingModel updateViewCount(ViewCountModel viewCount);

  AnimalSightingModel updateCategory(AnimalCategory category);

  AnimalCategory convertStringToCategory(String status);

  AnimalSightingModel? getCurrentanimalSighting();

  void addListener(VoidCallback listener);

  void removeListener(VoidCallback listener);

  AnimalSightingModel finalizeAnimal({bool clearSelected = true});

  void clearCurrentanimalSighting();

  AnimalSightingModel updateDescription(String description);

  bool validateActiveAnimalSighting();

  AnimalSightingModel processAnimalSelection(
    AnimalModel selectedAnimal,
    AnimalManagerInterface animalManager,
  );

  bool handleGenderSelection(AnimalGender selectedGender);

  AnimalSightingModel updateAnimal(AnimalModel updatedAnimal);

  AnimalSightingModel updateLocation(LocationModel location);

  AnimalSightingModel removeLocation(LocationModel location);

  AnimalSightingModel updateDateTime(DateTime dateTime);

  AnimalSightingModel updateDateTimeModel(DateTimeModel dateTimeModel);

  void addObservedAnimal(ObservedAnimalEntry entry);

  List<ObservedAnimalEntry> getObservedAnimals();

  void syncObservedAnimalsToSighting();
}
