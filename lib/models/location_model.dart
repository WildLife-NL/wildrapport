

import 'package:wildrapport/models/enums/location_source.dart';

class LocationModel {
  final double? coordinate1;
  final double? coordinate2;
  final String? cityName;
  final String? streetName;
  final String? houseNumber;
  final LocationSource source;

  LocationModel({
    this.coordinate1,
    this.coordinate2,
    this.cityName,
    this.streetName,
    this.houseNumber,
    this.source = LocationSource.unknown,
  });

  Map<String, dynamic> toJson() => {
    'coordinate1': coordinate1,
    'coordinate2': coordinate2,
    'cityName': cityName,
    'streetName': streetName,
    'houseNumber': houseNumber,
    'source': source.toString(),
  };

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    coordinate1: json['coordinate1'],
    coordinate2: json['coordinate2'],
    cityName: json['cityName'],
    streetName: json['streetName'],
    houseNumber: json['houseNumber'],
    source: LocationSource.values.firstWhere(
      (e) => e.toString() == json['source'],
      orElse: () => LocationSource.unknown,
    ),
  );
}