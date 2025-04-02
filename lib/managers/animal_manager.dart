
import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/models/animal_model.dart';

class AnimalManager implements AnimalRepositoryInterface, AnimalSelectionInterface, AnimalManagerInterface {
  final _listeners = <Function()>[];
  String _selectedFilter = 'Filteren';

  @override
  List<AnimalModel> getAnimals() {
    return [
      AnimalModel(
        animalImagePath: 'assets/wolf.png',
        animalName: 'Grijze Wolf',
      ),
      AnimalModel(
        animalImagePath: 'assets/fox.png',
        animalName: 'Red Fox',
      ),
      AnimalModel(
        animalImagePath: 'assets/marten.png',
        animalName: 'Steenmarter',
      ),
      AnimalModel(
        animalImagePath: 'assets/deer.png',
        animalName: 'Edelhert',
      ),
      AnimalModel(
        animalImagePath: 'assets/tiger.png',
        animalName: 'Tiger',
      ),
      AnimalModel(
        animalImagePath: 'assets/beer.png',
        animalName: 'Grizzlybeer',
      ),
    ];
  }

  @override
  AnimalModel handleAnimalSelection(AnimalModel selectedAnimal) {
    return selectedAnimal;
  }

  @override
  String getSelectedFilter() => _selectedFilter;

  @override
  void updateFilter(String filter) {
    _selectedFilter = filter;
    _notifyListeners();
  }

  @override
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}




