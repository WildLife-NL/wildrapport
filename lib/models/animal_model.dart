import 'package:wildrapport/models/view_count_model.dart';

class AnimalModel {
  final String? animalImagePath;
  final String animalName;
  final ViewCountModel viewCount;

  AnimalModel({
    this.animalImagePath,
    required this.animalName,
    ViewCountModel? viewCount,
  }) : viewCount = viewCount ?? ViewCountModel();
}



