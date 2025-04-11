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
    Map<String, dynamic> toJson() => {
    'animalID': animalID,
    'animalName': animalName,
    'animalGender': animalGender,
    'animalAge': animalAge,
    'animalCondition': animalCondition,
    'intensity': intensity,
    'urgency': urgency,
  };
    factory SightedAnimal.fromJson(Map<String, dynamic> json) => SightedAnimal(
      animalID: json['animalID'],
      animalName: json['animalName'],
      animalGender: json['animalGender'],
      animalAge: json['animalAge'],
      animalCondition: json['animalCondition'],
      intensity: json['intensity'],
      urgency: json['urgency'],
    );
}