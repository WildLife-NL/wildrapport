import 'package:flutter/material.dart';
import 'package:wildrapport/models/beta_models/accident_report_model.dart';
import 'package:wildrapport/models/beta_models/possesion_damage_report_model.dart';
import 'package:wildrapport/models/beta_models/possesion_model.dart';
import 'package:wildrapport/models/beta_models/sighting_report_model.dart';
import 'package:wildrapport/models/enums/report_type.dart';
import 'package:wildrapport/screens/rapporteren.dart';

class AppStateProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _screenStates = {};
  final Map<String, dynamic> _activeReports = {};
  ReportType? _currentReportType;

  ReportType? get currentReportType => _currentReportType;

  void setScreenState(String screenName, String key, dynamic value) {
    if (value == null) {
      print('Warning: Null value being set for $screenName.$key');
      return;
    }
    
    if (_screenStates[screenName]?.containsKey(key) ?? false) {
      final existingType = _screenStates[screenName]![key].runtimeType;
      if (value.runtimeType != existingType) {
        print('Warning: Type mismatch for $screenName.$key. Expected $existingType, got ${value.runtimeType}');
        return;
      }
      
      // Only notify if the value actually changed
      if (_screenStates[screenName]![key] != value) {
        _screenStates[screenName]![key] = value;
        notifyListeners();
      }
    } else {
      _screenStates[screenName] ??= {};
      _screenStates[screenName]![key] = value;
      notifyListeners();
    }
  }

  T? getScreenState<T>(String screenName, String key) {
    return _screenStates[screenName]?[key] as T?;
  }

  void clearScreenState(String screenName) {
    _screenStates.remove(screenName);
    notifyListeners();
  }


  void initializeReport(ReportType reportType) {
    _currentReportType = reportType;
    final report = switch (reportType) {
      ReportType.waarneming => SightingReport(animals: [], systemDateTime: DateTime.now()),
      ReportType.gewasschade => PossesionDamageReport(
        possesion: Possesion(possesionName: ''),
        impactedAreaType: 'hectare',
        impactedArea: 0.0,
        currentImpactDamages: '0',
        estimatedTotalDamages: '0',
        systemDateTime: DateTime.now(),
      ),
      ReportType.verkeersongeval => AccidentReport(
        damages: '0',
        systemDateTime: DateTime.now(),
        intensity: '0',
        urgency: '0',
      ),
    };
    
    _activeReports['currentReport'] = report;
    notifyListeners();
  }

  T? getCurrentReport<T>() {
    return _activeReports['currentReport'] as T?;
  }

  void updateCurrentReport(String property, dynamic value) {
    final report = _activeReports['currentReport'];
    if (report != null) {
      report.updateProperty(property, value);
      notifyListeners();
    }
  }

  void resetApplicationState(BuildContext context, {Widget? destination}) {
    _screenStates.clear();
    _activeReports.clear();
    _currentReportType = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _screenStates.clear();
    super.dispose();
  }
}









