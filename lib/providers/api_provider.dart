import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:wildrapport/interfaces/api_interface.dart';
import 'package:wildrapport/providers/api_client.dart';

/* Api Models */
import 'package:wildrapport/models/api_models/user.dart';
import 'package:wildrapport/models/api_models/species.dart';


class ApiProvider implements ApiInterface{
  final ApiClient client;
  ApiProvider(this.client);
  
  /* Authentication & Authorization */

  @override
  Future<Map<String, dynamic>> authenticate(String displayNameApp, String email) async {
    http.Response response = await client.post(
      'auth/',
      {
        "displayNameApp": displayNameApp,
        "email": email,
      },
      authenticated: false,
    );

    Map<String, dynamic>? json;
    try {
      json = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      debugPrint('Auth api: $json');
    } catch (_) {}

    if (response.statusCode == HttpStatus.ok) {
      return json ?? {};
    } else {
      throw Exception(json ?? "Failed to login");
    }
  }
  
  @override
  Future<User> authorize(String email, String code) async {
    http.Response response = await client.put(
      'auth/',
      {
        "code": code,
        "email": email,
      },
      authenticated: false,
    );

    Map<String, dynamic>? json;
    try {
      json = jsonDecode(response.body);
      debugPrint('V1 Auth api: $json');
    } catch (_) {}

    if (response.statusCode == HttpStatus.ok) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('bearer_token', json!["token"]);
      User user = User.fromJson(json);
      return user;
    } else {
      throw Exception(json!["detail"]);
    }
  }

  /* Species */

  @override
  Future<List<Species>> getAllSpecies() async {
    http.Response response = await client.get(
        'species/',
        authenticated: true,
      );

      List<dynamic>? json;

      if (response.statusCode == HttpStatus.ok) {
        json = jsonDecode(response.body);
        List<Species> species =
        (json as List).map((e) => Species.fromJson(e)).toList();
        return species;
    } 
    else {
      throw Exception(json ?? "Failed to get all species");
    }
  }

  @override
  Future<Species> getSpecies(String id) async {
    http.Response response = await client.get(
      'species/$id/',
      authenticated: true,
    );

    Map<String, dynamic>? json;

    if (response.statusCode == HttpStatus.ok) {
      json = jsonDecode(response.body);
      Species species = Species.fromJson(json!);
      return species;
    } 
    else {
      throw Exception(json ?? "Failed to get species");
    }
  }  
}