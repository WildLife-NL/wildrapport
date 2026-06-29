class Species {
  final String id;
  final String category;
  final String commonName;

  Species({required this.id, required this.category, required this.commonName});

  factory Species.fromJson(Map<String, dynamic> json) {
    final id = (json['ID'] ?? json['id'])?.toString().trim() ?? '';
    return Species(
      id: id,
      category: (json['category'] ?? '').toString(),
      commonName: (json['commonName'] ?? json['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'category': category, 'commonName': commonName};
  }
}
