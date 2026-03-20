class InteractionType {
  final int id;
  final String name;
  final String description;

  InteractionType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory InteractionType.fromJson(Map<String, dynamic> json) {
    return InteractionType(
      id: (json['ID'] ?? json['id']) is int ? (json['ID'] ?? json['id']) as int : 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    // Use API-consistent keys so saved drafts can round-trip via fromJson
    return {'ID': id, 'name': name, 'description': description};
  }
}
