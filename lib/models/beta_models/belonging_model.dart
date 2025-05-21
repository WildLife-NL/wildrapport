// ignore_for_file: non_constant_identifier_names

class Belonging {
  String? ID;
  String category;
  String name;

  Belonging({this.ID, required this.category, required this.name});

  Map<String, dynamic> toJson() => {
    'ID': ID,
    'category': category,
    'name': name,
  };
  factory Belonging.fromJson(Map<String, dynamic> json) =>
      Belonging(ID: json['ID'], category: json['category'], name: json['name']);
}
  