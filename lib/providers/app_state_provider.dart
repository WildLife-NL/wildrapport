import 'package:flutter/material.dart';
import 'package:wildrapport/screens/rapporteren.dart';

class AppStateProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _screenStates = {};
  final Map<String, dynamic> _activeReports = {};

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


  void initializeReport(String reportType) {
    final report = switch (reportType) {
      _ => throw Exception('Unknown report type: $reportType'),
    };
    
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

  void clearCurrentReport() {
    _activeReports.remove('currentReport');
    notifyListeners();
  }

  void resetApplicationState(BuildContext context, {Widget? destination}) {
    _screenStates.clear();
    _activeReports.clear();
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => destination ?? const Rapporteren(),
      ),
    );
    
    notifyListeners();
  }

  @override
  void dispose() {
    _screenStates.clear();
    super.dispose();
  }
}



