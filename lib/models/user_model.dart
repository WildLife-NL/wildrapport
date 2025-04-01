class UserModel{
  final String id;
  final String? email;
  String? name;

  UserModel({
    required this.id,
    required this.email,
    this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userID'] ?? json['ID'],
      email: json['email'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}