class User {
  final String id;
  final String? email;
  String? name;

  User({required this.id, required this.email, this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['userID'],
      name: json['name'],
      email: json['email'],
      // Add any other fields that might be missing
      // If any fields are optional, handle them with null checks:
      // someField: json['someField'] != null ? json['someField'] : defaultValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name};
  }
}

