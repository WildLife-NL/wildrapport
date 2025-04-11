class SightedAnimal{
  final String? animalID;
  final String animalName;
  final String animalGender;
  final String animalAge;
  final String animalCondition;
  final String? intensity;
  final String? urgency;

  SightedAnimal({
    this.animalID,
    required this.animalName,
    required this.animalGender,
    required this.animalAge,
    required this.animalCondition,
    this.intensity,
    this.urgency,
  });
}