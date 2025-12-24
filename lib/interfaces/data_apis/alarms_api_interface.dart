import 'package:wildrapport/models/api_models/alarm.dart';

abstract class AlarmsApiInterface {
  Future<List<Alarm>> getMyAlarms();
}
