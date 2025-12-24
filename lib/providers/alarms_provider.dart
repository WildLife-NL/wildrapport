import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/data_apis/alarms_api_interface.dart';
import 'package:wildrapport/models/api_models/alarm.dart';

class AlarmsProvider extends ChangeNotifier {
  final AlarmsApiInterface api;
  AlarmsProvider(this.api);

  List<Alarm> alarms = [];
  bool loading = false;
  String? error;

  Future<void> refresh() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      alarms = await api.getMyAlarms();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
