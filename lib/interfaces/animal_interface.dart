import 'package:wildrapport/models/animal_model.dart';

abstract class AnimalRepositoryInterface {
  List<AnimalModel> getAnimals();
}

abstract class AnimalSelectionInterface {
  AnimalModel handleAnimalSelection(AnimalModel selectedAnimal);
}

abstract class AnimalManagerInterface {
  List<AnimalModel> getAnimals();
  AnimalModel handleAnimalSelection(AnimalModel selectedAnimal);
  String getSelectedFilter();
  void updateFilter(String filter);
  void addListener(Function() listener);
  void removeListener(Function() listener);
}

