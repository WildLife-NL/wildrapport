import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wildrapport/api/api_client.dart';

class AppConfig {
  ApiClient apiClient = ApiClient('');

  static AppConfig shared = AppConfig.create();

  factory AppConfig.create() {
    return shared = AppConfig(ApiClient(dotenv.get('DEV_BASE_URL')));
  }
  AppConfig(this.apiClient);
}
