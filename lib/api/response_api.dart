import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/interfaces/api/response_api_interface.dart';

class ResponseApi implements ResponseApiInterface {
  final ApiClient client;
  ResponseApi(this.client);

  @override
  Future<bool> addReponse(String interactionID, String questionID, String? answerID, String? text) async {
    http.Response response = await client.post(
      'response/',
      {
        "interactionID": interactionID,
        "questionID": questionID,
        "answerID": answerID,
        "text": text,
      },
      authenticated: true,
    );
    
    if (response.statusCode == HttpStatus.ok) {
      debugPrint("Answer submitted successfully");
      return true;
    } else {
      debugPrint("Answer could NOT be submitted, status code: ${response.statusCode}");
      return false;
    }
  }
}