import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wildrapport/data_managers/api_client.dart';

class AppConfig {
  ApiClient apiClient = ApiClient('');

  static AppConfig shared = AppConfig.create();

  factory AppConfig.create() {
    final baseUrl = (dotenv.env['DEV_BASE_URL'] ?? '').trim();
    if (baseUrl.isEmpty) {
      throw StateError(
        'DEV_BASE_URL ontbreekt in .env. Zorg dat dotenv.load() is aangeroepen en DEV_BASE_URL is gezet.',
      );
    }
    return shared = AppConfig(ApiClient(baseUrl));
  }
  AppConfig(this.apiClient);
}
