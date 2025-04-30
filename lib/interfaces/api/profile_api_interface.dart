import 'package:wildrapport/models/beta_models/profile_model.dart';

abstract class ProfileApiInterface{
  Future<void> setProfileDataInDeviceStorage();
}