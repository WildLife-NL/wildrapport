import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/location_model.dart';
import 'package:wildrapport/models/image_list_model.dart';
import 'package:wildrapport/models/date_time_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/view_count_model.dart';

class AnimalSightingModel {
  final List<AnimalModel>? animals;
  final AnimalModel? animalSelected;
  final AnimalCategory? category;
  final String? description;
  final LocationModel? location;
  final DateTimeModel? dateTime;
  final ImageListModel? images;

  AnimalSightingModel({
    this.animals,
    this.category,
    this.description,
    this.location,
    this.dateTime,
    this.images,
    this.animalSelected,
  });

  Map<String, dynamic> toJson() {
    return {
      'animals': animals?.map((animal) => {
        'animalImagePath': animal.animalImagePath,
        'animalName': animal.animalName,
        'viewCount': animal.viewCount.toJson(),
        'condition': animal.condition?.toString(),
        'gender': animal.gender?.toString(),
      }).toList(),
      'animalSelected': animalSelected != null ? {
        'animalImagePath': animalSelected!.animalImagePath,
        'animalName': animalSelected!.animalName,
        'viewCount': animalSelected!.viewCount?.toJson(),
        'condition': animalSelected!.condition?.toString(),
        'gender': animalSelected!.gender?.toString(),
      } : null,
      'category': category?.toString(),
      'description': description,
      'location': location?.toJson(),
      'dateTime': dateTime?.toJson(),
      'images': images?.toJson(),
    };
  }

  factory AnimalSightingModel.fromJson(Map<String, dynamic> json) => AnimalSightingModel(
    animals: json['animals'] != null 
      ? List<AnimalModel>.from(
          json['animals'].map((x) => AnimalModel(
            animalImagePath: x['animalImagePath'],
            animalName: x['animalName'],
            viewCount: x['viewCount'] != null 
              ? ViewCountModel.fromJson(x['viewCount'])
              : null,
            condition: x['condition'] != null 
              ? AnimalCondition.values.firstWhere(
                  (e) => e.toString() == x['condition'],
                  orElse: () => AnimalCondition.andere,
                )
              : null,
            gender: x['gender'] != null 
              ? AnimalGender.values.firstWhere(
                  (e) => e.toString() == x['gender'],
                  orElse: () => AnimalGender.onbekend,
                )
              : null,
          ))
        )
      : null,
    category: json['category'] != null
      ? AnimalCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
          orElse: () => AnimalCategory.andere,
        )
      : null,
    description: json['description'],
    location: json['location'] != null 
      ? LocationModel.fromJson(json['location'])
      : null,
    dateTime: json['dateTime'] != null 
      ? DateTimeModel.fromJson(json['dateTime'])
      : null,
    images: json['images'] != null 
      ? ImageListModel.fromJson(json['images'])
      : null,
  );
}




