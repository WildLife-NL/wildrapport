import 'package:mockito/mockito.dart';
import 'package:wildrapport/config/app_config.dart';

class MockAppConfig extends Mock implements AppConfig {
  String get apiUrl => 'http://mock-api.test';

  String get apiKey => 'mock-api-key';

  static void setupMock() {
    AppConfig.shared = MockAppConfig();
  }
}
