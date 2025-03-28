class AnimalModel {
  String _animalImagePath;
  String _animalName;
  int _viewCount;

  AnimalModel({
    required String animalImagePath,
    required String animalName,
    int viewCount = 0,
  })  : _animalImagePath = animalImagePath,
        _animalName = animalName,
        _viewCount = viewCount;

  // Getters
  String get animalImagePath => _animalImagePath;
  String get animalName => _animalName;
  int get viewCount => _viewCount;

  // Setters
  set animalImagePath(String value) => _animalImagePath = value;
  set animalName(String value) => _animalName = value;
  set viewCount(int value) => _viewCount = value;
}
