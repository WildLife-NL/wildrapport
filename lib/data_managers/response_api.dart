import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/api/response_api_interface.dart';

class ResponseApi implements ResponseApiInterface {
  final ApiClient client;
  ResponseApi(this.client);

  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';

  @override
  Future<bool> addReponse(
    String interactionID,
    String questionID,
    String? answerID,
    String? text,
  ) async {
    http.Response response = await client.post('response/', {
      "answerID": answerID,
      "interactionID": interactionID,
      "questionID": questionID,
      "text": text,
    }, authenticated: true);

    if (response.statusCode == HttpStatus.ok) {
      debugPrint("$greenLog [ResponseApi]: Answer submitted successfully");
      return true;
    } else {
      debugPrint(
        "$redLog [ResponseApi]: Answer could NOT be submitted, status code: ${response.statusCode}",
      );
      debugPrint("$redLog [ResponseApi]: Response body: ${response.body}");
      return false;
    }
  }
}
