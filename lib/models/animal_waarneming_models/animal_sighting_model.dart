import 'package:wildrapport/models/enums/animal_condition.dart';
import 'package:wildrapport/models/enums/animal_category.dart';
import 'package:wildrapport/models/beta_models/location_model.dart';
import 'package:wildrapport/models/ui_models/image_list_model.dart';
import 'package:wildrapport/models/ui_models/date_time_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_model.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_gender_view_count_model.dart';

class AnimalSightingModel {
  final List<AnimalModel>? animals;
  final AnimalModel? animalSelected;
  final String? reportType;
  final int? animalCount;
  final String? cropType;
  final String? expectedLoss;
    final bool? preventiveMeasures;
    final String? preventiveMeasuresDescription;
  final String? accidentSeverity;
  final String? animalConditionDieraanrijding;
  final String? additionalInfo;
  final AnimalCategory? category;
  final String? description;
  final List<LocationModel>? locations; 
  final DateTimeModel? dateTime;
  final ImageListModel? images;

  AnimalSightingModel({
    this.animals,
    this.reportType,
    this.animalCount,
    this.cropType,
    this.expectedLoss,
      this.preventiveMeasures,
      this.preventiveMeasuresDescription,
    this.accidentSeverity,
    this.animalConditionDieraanrijding,
    this.additionalInfo,
    this.category,
    this.description,
    this.locations, 
    this.dateTime,
    this.images,
    this.animalSelected,
  });

  AnimalSightingModel copyWith({
    List<AnimalModel>? animals,
    AnimalModel? animalSelected,
    String? reportType,
    int? animalCount,
    String? cropType,
    String? expectedLoss,
      bool? preventiveMeasures,
      String? preventiveMeasuresDescription,
    String? accidentSeverity,
    String? animalConditionDieraanrijding,
    String? additionalInfo,
    AnimalCategory? category,
    String? description,
    List<LocationModel>? locations,
    DateTimeModel? dateTime,
    ImageListModel? images,
  }) {
    return AnimalSightingModel(
      animals: animals ?? this.animals,
      animalSelected: animalSelected ?? this.animalSelected,
      reportType: reportType ?? this.reportType,
      animalCount: animalCount ?? this.animalCount,
      cropType: cropType ?? this.cropType,
      expectedLoss: expectedLoss ?? this.expectedLoss,
      preventiveMeasures: preventiveMeasures ?? this.preventiveMeasures,
        preventiveMeasuresDescription: preventiveMeasuresDescription ?? this.preventiveMeasuresDescription,
      accidentSeverity: accidentSeverity ?? this.accidentSeverity,
      animalConditionDieraanrijding:
          animalConditionDieraanrijding ?? this.animalConditionDieraanrijding,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      category: category ?? this.category,
      description: description ?? this.description,
      locations: locations ?? this.locations,
      dateTime: dateTime ?? this.dateTime,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animals':
          animals
              ?.map(
                (animal) => {
                  'animalId': animal.animalId,
                  'animalImagePath': animal.animalImagePath,
                  'animalName': animal.animalName,
                  'condition': animal.condition?.toString(),
                  'genderViewCounts':
                      animal.genderViewCounts
                          .map((gvc) => gvc.toJson())
                          .toList(),
                },
              )
              .toList(),
      'animalSelected':
          animalSelected != null
              ? {
                'animalId': animalSelected!.animalId,
                'animalImagePath': animalSelected!.animalImagePath,
                'animalName': animalSelected!.animalName,
                'condition': animalSelected!.condition?.toString(),
                'genderViewCounts':
                    animalSelected!.genderViewCounts
                        .map((gvc) => gvc.toJson())
                        .toList(),
              }
              : null,
      'category': category?.toString(),
      'description': description,
        'preventiveMeasuresDescription': preventiveMeasuresDescription,
      'locations': locations?.map((loc) => loc.toJson()).toList(),
      'dateTime': dateTime?.toJson(),
      'images': images?.toJson(),
    };
  }

  factory AnimalSightingModel.fromJson(
    Map<String, dynamic> json,
  ) => AnimalSightingModel(
    animals:
        json['animals'] != null
            ? List<AnimalModel>.from(
              json['animals'].map(
                (x) => AnimalModel(
                  animalId: x['animalId'],
                  animalImagePath: x['animalImagePath'],
                  animalName: x['animalName'],
                  condition:
                      x['condition'] != null
                          ? AnimalCondition.values.firstWhere(
                            (e) => e.toString() == x['condition'],
                            orElse: () => AnimalCondition.onbekend,
                          )
                          : null,
                  genderViewCounts:
                      x['genderViewCounts'] != null
                          ? List<AnimalGenderViewCount>.from(
                            x['genderViewCounts'].map(
                              (gvc) => AnimalGenderViewCount.fromJson(gvc),
                            ),
                          )
                          : [],
                ),
              ),
            )
            : null,
    animalSelected:
        json['animalSelected'] != null
            ? AnimalModel(
              animalId: json['animalSelected']['animalId'],
              animalImagePath: json['animalSelected']['animalImagePath'],
              animalName: json['animalSelected']['animalName'],
              condition:
                  json['animalSelected']['condition'] != null
                      ? AnimalCondition.values.firstWhere(
                        (e) =>
                            e.toString() == json['animalSelected']['condition'],
                        orElse: () => AnimalCondition.onbekend,
                      )
                      : null,
              genderViewCounts:
                  json['animalSelected']['genderViewCounts'] != null
                      ? List<AnimalGenderViewCount>.from(
                        json['animalSelected']['genderViewCounts'].map(
                          (gvc) => AnimalGenderViewCount.fromJson(gvc),
                        ),
                      )
                      : [],
            )
            : null,
    reportType: json['reportType'],
    animalCount: json['animalCount'],
    cropType: json['cropType'],
    expectedLoss: json['expectedLoss'],
    preventiveMeasures: json['preventiveMeasures'],
      preventiveMeasuresDescription: json['preventiveMeasuresDescription'],
    accidentSeverity: json['accidentSeverity'],
    animalConditionDieraanrijding: json['animalConditionDieraanrijding'],
    additionalInfo: json['additionalInfo'],
    category:
        json['category'] != null
            ? AnimalCategory.values.firstWhere(
              (e) => e.toString() == json['category'],
              orElse: () => AnimalCategory.andere,
            )
            : null,
    description: json['description'],
    locations:
        json['locations'] !=
                null // Updated to handle list of locations
            ? List<LocationModel>.from(
              json['locations'].map((x) => LocationModel.fromJson(x)),
            )
            : null,
    dateTime:
        json['dateTime'] != null
            ? DateTimeModel.fromJson(json['dateTime'])
            : null,
    images:
        json['images'] != null ? ImageListModel.fromJson(json['images']) : null,
  );
}