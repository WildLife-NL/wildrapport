import 'package:wildrapport/models/view_count_model.dart';
import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';

class AnimalModel {
  final String? animalImagePath;
  final String animalName;
  final ViewCountModel viewCount;
  final AnimalCondition? condition;
  final AnimalGender? gender;

  AnimalModel({
    this.animalImagePath,
    required this.animalName,
    ViewCountModel? viewCount,
    this.condition,
    this.gender,
  }) : viewCount = viewCount ?? ViewCountModel();
}





