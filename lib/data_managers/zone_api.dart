import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/zone_api_interface.dart';
import 'package:wildrapport/models/api_models/zone.dart';

class ZoneApi implements ZoneApiInterface {
  final ApiClient client;
  ZoneApi(this.client);

  @override
  Future<Zone> addZone(ZoneCreateRequest request) async {
    const path = 'zone/';
    debugPrint('[ZoneApi] POST $path');
    final http.Response res = await client.post(
      path,
      request.toJson(),
      authenticated: true,
    );
    debugPrint('[ZoneApi] Status: ${res.statusCode}');
    if (res.statusCode == HttpStatus.ok ||
        res.statusCode == HttpStatus.created) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return Zone.fromJson(data);
    }
    throw Exception('[ZoneApi] Failed (${res.statusCode}): ${res.body}');
  }

  @override
  Future<Zone> addSpeciesToZone(ZoneSpeciesAssignRequest request) async {
    const path = 'zone/species/';
    debugPrint('[ZoneApi] POST $path speciesID=${request.speciesID} zoneID=${request.zoneID}');
    final http.Response res = await client.post(
      path,
      request.toJson(),
      authenticated: true,
    );
    debugPrint('[ZoneApi] Status: ${res.statusCode}');
    if (res.statusCode == HttpStatus.ok ||
        res.statusCode == HttpStatus.created) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return Zone.fromJson(data);
    }
    throw Exception('[ZoneApi] Failed (${res.statusCode}): ${res.body}');
  }
}
