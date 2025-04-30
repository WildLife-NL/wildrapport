import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/models/beta_models/accident_report_model.dart';
import 'package:wildrapport/models/beta_models/possesion_damage_report_model.dart';
import 'package:wildrapport/models/beta_models/possesion_model.dart';
import 'package:wildrapport/models/beta_models/sighting_report_model.dart';
import 'package:wildrapport/models/enums/report_type.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:geolocator/geolocator.dart';


class AppStateProvider with ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final Map<String, Map<String, dynamic>> _screenStates = {};
  final Map<String, dynamic> _activeReports = {};
  ReportType? _currentReportType;
  Position? _cachedPosition;
  String? _cachedAddress;
  DateTime? _lastLocationUpdate;
  static const Duration locationCacheTimeout = Duration(minutes: 15);

  ReportType? get currentReportType => _currentReportType;
  Position? get cachedPosition => _cachedPosition;
  String? get cachedAddress => _cachedAddress;
  DateTime? get lastLocationUpdate => _lastLocationUpdate;

  bool get isLocationCacheValid {
    if (_lastLocationUpdate == null || _cachedPosition == null) {
      debugPrint('\x1B[33m[AppStateProvider] Cache invalid: No cached data\x1B[0m');
      return false;
    }
    
    final isValid = DateTime.now().difference(_lastLocationUpdate!) < locationCacheTimeout;
    debugPrint('\x1B[36m[AppStateProvider] Cache status: ${isValid ? "valid" : "expired"}'
        ' (Age: ${DateTime.now().difference(_lastLocationUpdate!).inMinutes}m)\x1B[0m');
    return isValid;
  }

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

  Future<void> updateLocationCache() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      
      final locationService = LocationMapManager();
      final address = await locationService.getAddressFromPosition(position);

      _cachedPosition = position;
      _cachedAddress = address;
      _lastLocationUpdate = DateTime.now();
      
      debugPrint('\x1B[32m[AppStateProvider] Location cache updated successfully:'
          ' ${position.latitude}, ${position.longitude}\x1B[0m');
      notifyListeners();
    } catch (e) {
      debugPrint('\x1B[31m[AppStateProvider] Error updating location cache: $e\x1B[0m');
    }
  }

  void startLocationUpdates() {
    Timer.periodic(locationCacheTimeout, (_) => updateLocationCache());
  }
}





