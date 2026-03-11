import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildlifenl_alarms_components/wildlifenl_alarms_components.dart';

class AlarmsApiClientAdapter implements AlarmsApiClientInterface {
  AlarmsApiClientAdapter(this._client);

  final ApiClient _client;

  @override
  Future<AlarmsHttpResponse> get(String path) async {
    final res = await _client.get(path, authenticated: true);
    return AlarmsHttpResponse(statusCode: res.statusCode, body: res.body);
  }
}
