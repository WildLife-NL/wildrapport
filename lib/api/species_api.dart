import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/interfaces/api/species_api_interface.dart';
import 'package:wildrapport/models/api_models/species.dart';

class SpeciesApi implements SpeciesApiInterface{
  final ApiClient client;
  SpeciesApi(this.client);

  @override
  Future<List<Species>> getAllSpecies() async {
    try {
      final response = await client.get(
        'species/',
        authenticated: true,
      );

      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as List;
        return json.map((e) => Species.fromJson(e)).toList();
      } 
      
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('[SpeciesApi] Error fetching species: $e');
      throw Exception('Failed to fetch species: $e');
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
      debugPrint('[SpeciesApi] Response status: ${response.statusCode}');
      debugPrint('[SpeciesApi] Response body: ${response.body}');
      throw Exception(json ?? "Failed to get species");
    }
  }
  
  @override
  Future<Species> getSpeciesByCategory(String category) {
    // TODO: implement getSpeciesByCategory
    throw UnimplementedError();
  }
}

