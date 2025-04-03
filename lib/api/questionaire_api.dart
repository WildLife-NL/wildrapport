import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/interfaces/api/questionnaire_api_interface.dart';

class QuestionaireApi implements QuestionnaireApiInterface{
  final ApiClient client;
  QuestionaireApi(this.client);


}