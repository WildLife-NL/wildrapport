class AnimalModel {
  final String? animalImagePath;  // Make nullable
  final String animalName;
  int viewCount;

  AnimalModel({
    this.animalImagePath,  // Make optional
    required this.animalName,
    required this.viewCount,
  });
}

