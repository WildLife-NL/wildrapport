class Profile {
  String userID;
  String email;
  String? gender;
  String userName;
  String? postcode;

  Profile({
    required this.userID,
    required this.email,
    this.gender,
    required this.userName,
    this.postcode,
  });
  Map<String, dynamic> toJson() => {
    'ID': userID,
    'email': email,
    'gender': gender,
    'name': userName,
    'postcode': postcode,
  };
  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    userID: json['ID'],
    email: json['email'],
    gender: json['gender'],
    userName: json['name'],
    postcode: json['postcode'],
  );
}
