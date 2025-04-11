class ReportLocation {
  final double? coordinate1;
  final double? coordinate2;
  final String? cityName;
  final String? streetName;
  final String? houseNumber;

  ReportLocation({
    this.coordinate1,
    this.coordinate2,
    this.cityName,
    this.streetName,
    this.houseNumber,
  });

  Map<String, dynamic> toJson() => {
    'coordinate1': coordinate1,
    'coordinate2': coordinate2,
    'cityName': cityName,
    'streetName': streetName,
    'houseNumber': houseNumber,
  };

  factory ReportLocation.fromJson(Map<String, dynamic> json) => ReportLocation(
    coordinate1: json['coordinate1'],
    coordinate2: json['coordinate2'],
    cityName: json['cityName'],
    streetName: json['streetName'],
    houseNumber: json['houseNumber'],
  );
}