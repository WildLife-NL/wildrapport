class Possesion {
  final String? possesionID;
  final String possesionName;
  final String? category;

  Possesion({
    this.possesionID,
    required this.possesionName,
    this.category,
  });

  Map<String, dynamic> toJson() => {
    'possesionID': possesionID,
    'possesionName': possesionName,
    'category': category,
  };
    factory Possesion.fromJson(Map<String, dynamic> json) => Possesion(
      possesionID: json['possesionID'],
      possesionName: json['possesionName'],
      category: json['category'],
    );
}