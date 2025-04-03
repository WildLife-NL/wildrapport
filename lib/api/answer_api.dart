import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/interfaces/api/answer_api_interface.dart';

class AnswerApi implements AnswerApiInterface{
  final ApiClient client;
  AnswerApi(this.client);
  
  @override
  void addReponse(String interactionID, String questionID, String answerID, String text) async {
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
    if(response.statusCode == HttpStatus.ok){
      debugPrint("Answer submitted succesfully");
    }
    else{
      debugPrint("Answer could NOT be submitted, status code: ${response.statusCode}");
      throw Exception("Error: ${response.statusCode} | Something went wrong");
    }
  }
}