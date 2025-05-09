import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/interfaces/api/questionnaire_api_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';

class QuestionaireApi implements QuestionnaireApiInterface {
  final ApiClient client;
  QuestionaireApi(this.client);

  @override
  Future<Questionnaire> getQuestionnaireByID(String id) async {
    http.Response response = await client.get(
      '/questionnaire/$id',
      authenticated: true,
    );

    Map<String, dynamic>? json;

    if (response.statusCode == HttpStatus.ok) {
      json = jsonDecode(response.body);
      Questionnaire questionnaire = Questionnaire.fromJson(json!);
      return questionnaire;
    } else {
      throw Exception(json ?? "Failed to get questionnaire");
    }
  }
}
