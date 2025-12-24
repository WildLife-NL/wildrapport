import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/alarms_api_interface.dart';
import 'package:wildrapport/models/api_models/alarm.dart';

class AlarmsApi implements AlarmsApiInterface {
  final ApiClient client;
  AlarmsApi(this.client);

  @override
  Future<List<Alarm>> getMyAlarms() async {
    const path = 'alarms/me/';
    debugPrint('[AlarmsApi] GET $path');
    final http.Response res = await client.get(path, authenticated: true);
    debugPrint('[AlarmsApi] Status: ${res.statusCode}');
    if (res.statusCode == HttpStatus.ok) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((e) => Alarm.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('[AlarmsApi] Failed (${res.statusCode}): ${res.body}');
  }
}
