import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_type_api_interface.dart';
import 'package:wildrapport/models/api_models/interaction_type.dart';

class InteractionTypeApi implements InteractionTypeApiInterface {
  final ApiClient client;
  
  InteractionTypeApi(this.client);

  @override
  Future<List<InteractionType>> getAllInteractionTypes() async {
    try {
      final response = await client.get('interaction-type/', authenticated: true);
      
      if (response.statusCode == HttpStatus.ok) {
        final json = jsonDecode(response.body) as List;
        return json.map((e) => InteractionType.fromJson(e)).toList();
      }
      
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    } catch (e) {
      debugPrint('[InteractionTypeApi] Error fetching interaction types: $e');
      throw Exception('Failed to fetch interaction types: $e');
    }
  }
}
