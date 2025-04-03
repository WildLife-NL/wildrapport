import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/interfaces/api/species_api_interface.dart';
import 'package:wildrapport/models/api_models/species.dart';

class SpeciesApi implements SpeciesApiInterface{
  final ApiClient client;
  SpeciesApi(this.client);

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
  
  @override
  Future<Species> getSpeciesByCategory(String category) {
    // TODO: implement getSpeciesByCategory
    throw UnimplementedError();
  }
}