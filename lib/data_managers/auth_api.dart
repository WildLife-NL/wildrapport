import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/auth_api_interface.dart';
import 'package:wildrapport/models/api_models/user.dart';

class AuthApi implements AuthApiInterface {
  final ApiClient client;
  AuthApi(this.client);

  @override
  Future<Map<String, dynamic>> authenticate(
    String displayNameApp,
    String email,
  ) async {
    http.Response response = await client.post('auth/', {
      "displayNameApp": displayNameApp,
      "email": email,
    }, authenticated: false);

    Map<String, dynamic>? json;
    try {
      json = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      debugPrint('Auth api: $json');
    } catch (_) {}
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == HttpStatus.ok) {
      return json ?? {};
    } else {
      throw Exception(json ?? "Failed to login");
    }
  }

  @override
  Future<User> authorize(String email, String code) async {
    debugPrint("Starting Authorization");
    http.Response response = await client.put('auth/', {
      "code": code,
      "email": email,
    }, authenticated: false);
    debugPrint("Response code: ${response.statusCode}");

    Map<String, dynamic>? json;
    try {
      json = jsonDecode(response.body);
      debugPrint('V1 Auth api: $json');
    } catch (error) {
      debugPrint("Error: $error");
    }

    if (response.statusCode == HttpStatus.ok) {
      debugPrint("Code Succesfully Verified!");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Persist bearer token
      await prefs.setString('bearer_token', json!["token"]);

      // Persist scopes if provided by backend
      try {
        final scopesRaw = json["scopes"];
        if (scopesRaw is List) {
          final scopes = scopesRaw
              .whereType<String>()
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(growable: false);
          await prefs.setStringList('scopes', scopes);
          debugPrint("Stored scopes in shared preferences: $scopes");
        } else {
          // Clear any stale scopes if the backend didn't return them
          await prefs.remove('scopes');
        }
      } catch (e) {
        debugPrint("Failed to parse/store scopes: $e");
      }
      debugPrint("Code stored in shared prefrences");
      debugPrint(json.toString());
      User user = User.fromJson(json);
      return user;
    } else {
      debugPrint("Could not verify code!");
      throw Exception(json!["detail"]);
    }
  }
}
