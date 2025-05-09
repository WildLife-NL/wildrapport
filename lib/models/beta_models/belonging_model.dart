class Belonging {
  String? id;
  String category;
  String name;

  Belonging({this.id, required this.category, required this.name});

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'name': name,
  };
  factory Belonging.fromJson(Map<String, dynamic> json) =>
      Belonging(id: json['id'], category: json['category'], name: json['name']);
}
