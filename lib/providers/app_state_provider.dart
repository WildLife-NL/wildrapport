
import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/rapporteren.dart';

class AppStateProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _screenStates = {};
  final List<String> _screenStack = []; // Track screen navigation stack
  bool _hasWindowFocus = true;
  // Add a map to store active reports
  final Map<String, dynamic> _activeReports = {};

  bool get hasWindowFocus => _hasWindowFocus;
  List<String> get screenStack => List.unmodifiable(_screenStack);

  void pushScreen(String screenName) {
    _screenStack.add(screenName);
    notifyListeners();
  }

  void popScreen() {
    if (_screenStack.isNotEmpty) {
      _screenStack.removeLast();
      notifyListeners();
    }
  }

  void setWindowFocus(bool focus) {
    if (_hasWindowFocus != focus) {
      _hasWindowFocus = focus;
      notifyListeners();
    }
  }

  void setScreenState(String screenName, String key, dynamic value) {
    // Validate input
    if (value == null) {
      print('Warning: Null value being set for $screenName.$key');
      return;
    }
    
    // Type checking
    if (_screenStates[screenName]?.containsKey(key) ?? false) {
      final existingType = _screenStates[screenName]![key].runtimeType;
      if (value.runtimeType != existingType) {
        print('Warning: Type mismatch for $screenName.$key. Expected $existingType, got ${value.runtimeType}');
        return;
      }
    }
    
    _screenStates[screenName] ??= {};
    _screenStates[screenName]![key] = value;
    notifyListeners();
  }

  T? getScreenState<T>(String screenName, String key) {
    return _screenStates[screenName]?[key] as T?;
  }

  void clearScreenState(String screenName) {
    _screenStates.remove(screenName);
    notifyListeners();
  }

  void clearAllStatesAndNavigateToRapporteren(BuildContext context) {
    // Clear all states
    _screenStates.clear();
    _screenStack.clear();
    
    // Clear entire navigation stack and push Rapporteren
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Rapporteren()),
      (route) => false, // This removes all routes
    );
    
    notifyListeners();
  }

  void initializeReport(String reportType) {
    // Create initial report object based on type, Create the object models first
    final report = switch(reportType) {
      // 'Waarnemingen' => WaarnemingReport(),
      // 'Diergezondheid' => DiergezondheidReport(),
      // 'Gewasschade' => GewasschadeReport(),
      // 'Verkeersongeval' => VerkeersongevalReport(),
      _ => throw Exception('Unknown report type: $reportType'),
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

  void clearCurrentReport() {
    _activeReports.remove('currentReport');
    notifyListeners();
  }

  @override
  void dispose() {
    _screenStates.clear();
    _screenStack.clear();
    super.dispose();
  }
}



