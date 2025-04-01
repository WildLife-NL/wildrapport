import 'package:wildrapport/models/user_model.dart';
import 'package:wildrapport/models/animal_model.dart';

abstract class ApiInterface {
  Future<Map<String, dynamic>> authenticate(
      String displayNameApp, String email);
  Future<UserModel> authorize(String email, String code);
  Future<List<AnimalModel>> getAllSpecies();
  Future<AnimalModel> getSpecies(String id);
}