import 'package:wildrapport/models/animal_model.dart';

abstract class AnimalRepositoryInterface {
  List<AnimalModel> getAnimals();
}

abstract class AnimalSelectionInterface {
  AnimalModel handleAnimalSelection(AnimalModel selectedAnimal);
}
