class ProfileModel {
  String userID;
  String email;
  String? gender;
  String userName;
  String? postcode;

  ProfileModel({
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
    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
      userID: json['ID'],
      email: json['email'],
      gender: json['gender'],
      userName: json['name'],
      postcode: json['postcode'],
    );
}