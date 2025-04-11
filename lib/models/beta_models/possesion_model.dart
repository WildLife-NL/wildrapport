class Possesion {
  final String? possesionID;
  final String possesionName;

  Possesion({
    this.possesionID,
    required this.possesionName,
  });

  Map<String, dynamic> toJson() => {
    'possesionID': possesionID,
    'possesionName': possesionName,
  };
    factory Possesion.fromJson(Map<String, dynamic> json) => Possesion(
      possesionID: json['possesionID'],
      possesionName: json['possesionName'],
    );
}