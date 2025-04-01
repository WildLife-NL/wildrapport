import 'package:wildrapport/models/api_models/user.dart';
import 'package:wildrapport/models/api_models/species.dart';

abstract class ApiInterface {
  Future<Map<String, dynamic>> authenticate(
      String displayNameApp, String email);
  Future<User> authorize(String email, String code);
  Future<List<Species>> getAllSpecies();
  Future<Species> getSpecies(String id);
}