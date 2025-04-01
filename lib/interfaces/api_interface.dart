import 'package:wildrapport/models/user_model.dart';

abstract class ApiInterface {
  Future<Map<String, dynamic>> authenticate(
      String displayNameApp, String email);
  Future<UserModel> authorize(String email, String code);
}