import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/location_model.dart';
import 'package:wildrapport/models/image_list_model.dart';
import 'package:wildrapport/models/date_time_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/view_count_model.dart';

class WaarnemingModel {
  final List<AnimalModel>? animals;
  final AnimalCondition? condition;
  final AnimalCategory? category;
  final AnimalGender? gender;
  final AnimalAge? age;
  final String? description;
  final LocationModel? location;
  final DateTimeModel? dateTime;
  final ImageListModel? images;

  WaarnemingModel({
    this.animals,
    this.condition,
    this.category,
    this.gender,
    this.age,
    this.description,
    this.location,
    this.dateTime,
    this.images,
  });

  Map<String, dynamic> toJson() => {
    'animals': animals?.map((animal) => {
      'animalImagePath': animal.animalImagePath,
      'animalName': animal.animalName,
      'viewCount': animal.viewCount.toJson(),
    }).toList(),
    'condition': condition?.toString(),
    'category': category?.toString(),
    'gender': gender?.toString(),
    'age': age?.toString(),
    'description': description,
    'location': location?.toJson(),
    'dateTime': dateTime?.toJson(),
    'images': images?.toJson(),
  };

  factory WaarnemingModel.fromJson(Map<String, dynamic> json) => WaarnemingModel(
    animals: json['animals'] != null 
      ? List<AnimalModel>.from(
          json['animals'].map((x) => AnimalModel(
            animalImagePath: x['animalImagePath'],
            animalName: x['animalName'],
            viewCount: x['viewCount'] != null 
              ? ViewCountModel.fromJson(x['viewCount'])
              : null,
          ))
        )
      : null,
    condition: json['condition'] != null 
      ? AnimalCondition.values.firstWhere(
          (e) => e.toString() == json['condition'],
          orElse: () => AnimalCondition.andere,
        )
      : null,
    category: json['category'] != null 
      ? AnimalCategory.values.firstWhere(
          (e) => e.toString() == json['category'],
          orElse: () => AnimalCategory.andere,
        )
      : null,
    gender: json['gender'] != null 
      ? AnimalGender.values.firstWhere(
          (e) => e.toString() == json['gender'],
          orElse: () => AnimalGender.onbekend,
        )
      : null,
    age: json['age'] != null 
      ? AnimalAge.values.firstWhere(
          (e) => e.toString() == json['age'],
          orElse: () => AnimalAge.onbekend,
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

