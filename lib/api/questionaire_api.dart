import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/interfaces/api/questionnaire_api_interface.dart';
import 'package:wildrapport/models/api_models/questionaire.dart';

class QuestionaireApi implements QuestionnaireApiInterface{
  final ApiClient client;
  QuestionaireApi(this.client);

  @override
  Future<Questionnaire> getQuestionnaireByID(String id) {
    // TODO: implement getQuestionnaireByID
    throw UnimplementedError();
  }
}