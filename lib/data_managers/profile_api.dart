import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';
import 'package:wildrapport/models/beta_models/profile_model.dart';

class ProfileApi implements ProfileApiInterface {
  final ApiClient client;
  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';
  ProfileApi(this.client);

  @override
  Future<void> setProfileDataInDeviceStorage() async {
    http.Response response = await client.get(
      '/profile/me/',
      authenticated: true,
    );

    Map<String, dynamic>? json;

    if (response.statusCode == HttpStatus.ok) {
      json = jsonDecode(response.body);
      await _setTheProfileData(Profile.fromJson(json!));
    } else {
      throw Exception(json ?? "$redLog Failed to get profile data!");
    }
  }

  Future<void> _setTheProfileData(Profile profile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("userID", profile.userID);
    await prefs.setString("email", profile.email);
    if (profile.gender != null) {
      await prefs.setString("gender", profile.gender!);
    }
    await prefs.setString("userName", profile.userName);
    if (profile.postcode != null) {
      await prefs.setString("postcode", profile.postcode!);
    }
  }
}
