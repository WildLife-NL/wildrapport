import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wildlife_api_connection/api_client.dart';

class ApiUrl{
  static ApiClient apiClient = ApiClient(dotenv.get('DEV_BASE_URL'));
}