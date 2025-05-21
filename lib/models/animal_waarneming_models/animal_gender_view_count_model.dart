import 'package:wildrapport/models/animal_waarneming_models/view_count_model.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';

class AnimalGenderViewCount {
  final AnimalGender gender;
  final ViewCountModel viewCount;

  AnimalGenderViewCount({required this.gender, required this.viewCount});

  Map<String, dynamic> toJson() => {
    'gender': gender.toString(),
    'viewCount': viewCount.toJson(),
  };

  factory AnimalGenderViewCount.fromJson(Map<String, dynamic> json) {
    return AnimalGenderViewCount(
      gender: AnimalGender.values.firstWhere(
        (e) => e.toString() == json['gender'],
        orElse: () => AnimalGender.onbekend,
      ),
      viewCount: ViewCountModel.fromJson(json['viewCount']),
    );
  }
}
