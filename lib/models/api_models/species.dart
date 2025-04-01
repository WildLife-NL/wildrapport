class Species {
  final String id;
  final String name;
  final String commonName;

  Species({
    required this.id,
    required this.name,
    required this.commonName,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      id: json['ID'],
      name: json['name'],
      commonName: json['commonName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'commonName': commonName,
    };
  }
}