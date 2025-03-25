class AnimalModel {
  String _animalImagePath;
  String _animalName;

  AnimalModel({
    required String animalImagePath,
    required String animalName,
  })  : _animalImagePath = animalImagePath,
        _animalName = animalName;

  // Getters
  String get animalImagePath => _animalImagePath;
  String get animalName => _animalName;

  // Setters
  set animalImagePath(String value) => _animalImagePath = value;
  set animalName(String value) => _animalName = value;
}