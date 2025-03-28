import 'package:flutter/material.dart';

abstract class ScreenStateInterface {
  void loadScreenState();
  void saveScreenState();
  void updateState(String key, dynamic value);
  Map<String, dynamic> getCurrentState();
  void safeSetState(VoidCallback fn);
}

abstract class ReportManagerInterface {
  void initializeReportFlow(String reportType);
  T? getCurrentReport<T>();
  void updateReport(String property, dynamic value);
  void clearAllConfirmation(BuildContext context);
  void resetApplication({Widget? destination});
}
