import 'package:wildrapport/models/beta_models/profile_model.dart';

abstract class ProfileApiInterface {
  Future<void> setProfileDataInDeviceStorage();

  Future<Profile> fetchMyProfile();

  Future<Profile> updateReportAppTerms(bool accepted);

  Future<void> deleteMyProfile();

  Future<Profile> updateMyProfile(Profile updatedProfile);

  /// Sends [token] (or `null` when push is disabled) via `PUT /profile/me/`.
  Future<Profile> updateFirebaseCloudMessagingToken(String? token);
}
