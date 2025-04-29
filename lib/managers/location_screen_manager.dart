import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/models/enums/date_time_type.dart';
import 'package:provider/provider.dart';

import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
class LocationScreenManager implements LocationScreenInterface {
  // Private state variables
  bool _isLocationDropdownExpanded = false;
  bool _isDateTimeDropdownExpanded = false;
  String _selectedLocation = LocationType.current.displayText;
  String _selectedDateTime = DateTimeType.current.displayText;
  String _currentLocationText = 'Huidige locatie wordt geladen...';
  DateTime? _customDateTime;

  @override
  bool get isLocationDropdownExpanded => _isLocationDropdownExpanded;

  @override
  bool get isDateTimeDropdownExpanded => _isDateTimeDropdownExpanded;

  @override
  String get selectedLocation => _selectedLocation;

  @override
  String get selectedDateTime => _selectedDateTime;

  @override
  String get currentLocationText => _currentLocationText;

  Future<void> handleNextPressed(BuildContext context) async {
    final locationInfo = await getLocationAndDateTime(context);
    return Future.value();
  }

  @override
  Future<Map<String, dynamic>> getLocationAndDateTime(BuildContext context) async {
    final mapProvider = context.read<MapProvider>();
    final appState = context.read<AppStateProvider>();
    final LocationServiceInterface locationService = LocationMapManager();
    
    Position? currentPosition;
    Map<String, dynamic>? currentGpsLocation;

    // Debug cache status
    debugPrint('\x1B[36m[LocationScreenManager] 📍 Location Source Check:');
    debugPrint('Cache valid: ${appState.isLocationCacheValid}');
    debugPrint('Cached position exists: ${appState.cachedPosition != null}');
    debugPrint('Cached address exists: ${appState.cachedAddress != null}');
    if (appState.cachedPosition != null) {
      debugPrint('Cached coordinates: ${appState.cachedPosition?.latitude}, ${appState.cachedPosition?.longitude}');
    }
    debugPrint('Last cache update: ${appState.lastLocationUpdate}\x1B[0m');

    // Try to use cached location first
    if (appState.isLocationCacheValid) {
      debugPrint('\x1B[32m[LocationScreenManager] ✅ Using CACHED location');
      currentPosition = appState.cachedPosition;
      currentGpsLocation = currentPosition != null 
          ? {
              'latitude': currentPosition.latitude,
              'longitude': currentPosition.longitude,
              'address': appState.cachedAddress,
            }
          : null;
      debugPrint('Cached location data: $currentGpsLocation\x1B[0m');
    } else {
      debugPrint('\x1B[33m[LocationScreenManager] 🔄 Cache invalid/expired, using GPS');
      // If cache is invalid or empty, get new location and update cache
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      ).catchError((error) {
        debugPrint('\x1B[31m[LocationScreenManager] ❌ GPS Error: $error\x1B[0m');
        return null;
      });

      if (currentPosition != null) {
        debugPrint('\x1B[32m[LocationScreenManager] ✅ New GPS location obtained:');
        debugPrint('Coordinates: ${currentPosition.latitude}, ${currentPosition.longitude}\x1B[0m');
        
        final address = await locationService.getAddressFromPosition(currentPosition);
        currentGpsLocation = {
          'latitude': currentPosition.latitude,
          'longitude': currentPosition.longitude,
          'address': address,
        };
        
        debugPrint('\x1B[32m[LocationScreenManager] 🔄 Updating location cache\x1B[0m');
        // Update cache in background
        appState.updateLocationCache();
      }
    }

    // Get user selected location
    final selectedLocation = mapProvider.selectedPosition != null 
        ? {
            'latitude': mapProvider.selectedPosition!.latitude,
            'longitude': mapProvider.selectedPosition!.longitude,
            'address': mapProvider.selectedAddress,
          }
        : null;

    // Get date time information
    final dateTimeInfo = {
      'dateTime': _selectedDateTime == DateTimeType.current.displayText
          ? DateTime.now().toIso8601String()
          : _selectedDateTime == DateTimeType.unknown.displayText
              ? null
              : _customDateTime?.toIso8601String(),
      'type': _selectedDateTime == DateTimeType.current.displayText
          ? 'current'
          : _selectedDateTime == DateTimeType.unknown.displayText
              ? 'unknown'
              : 'custom',
    };

    final result = {
      'currentGpsLocation': currentGpsLocation,
      'selectedLocation': selectedLocation,
      'dateTime': dateTimeInfo,
      'isLocationUnknown': selectedLocation == null || 
          mapProvider.selectedAddress == LocationType.unknown.displayText,
      'isDateTimeUnknown': _selectedDateTime == DateTimeType.unknown.displayText,
    };

    debugPrint('\x1B[36m[LocationScreenManager] 📍 Final location data:');
    debugPrint('Current GPS: ${result['currentGpsLocation']}');
    debugPrint('Selected: ${result['selectedLocation']}');
    debugPrint('DateTime: ${result['dateTime']}\x1B[0m');

    return result;
  }

  Map<String, dynamic> _getDateTimeInfo() {
    if (_selectedDateTime == DateTimeType.current.displayText) {
      final now = DateTime.now();
      return {
        'dateTime': now.toIso8601String(),
        'type': 'current',
      };
    } else if (_selectedDateTime == DateTimeType.unknown.displayText) {
      return {
        'type': 'unknown',
      };
    }
    
    return {
      'type': 'custom',
      // Add any custom date/time logic here if needed
    };
  }

  Future<void> printLocationAndDateTime(BuildContext context) async {
    final info = await getLocationAndDateTime(context);
    
    debugPrint('\x1B[32m[LocationScreen] Location and DateTime Info:');
    debugPrint('Current GPS: ${info['currentGpsLocation']}');
    debugPrint('Selected Location: ${info['selectedLocation']}');
    debugPrint('DateTime Info: ${info['dateTime']}');
    debugPrint('Is Location Unknown: ${info['isLocationUnknown']}');
    debugPrint('Is DateTime Unknown: ${info['isDateTimeUnknown']}\x1B[0m');
  }

  void updateDateTime(String option, {DateTime? date, DateTime? time}) {
    _selectedDateTime = option;
    
    if (option == DateTimeType.current.displayText) {
      _customDateTime = null;
    } else if (option == DateTimeType.unknown.displayText) {
      _customDateTime = null;
    } else if (date != null || time != null) {
      // Combine date and time if both are provided
      final currentCustom = _customDateTime ?? DateTime.now();
      if (date != null && time != null) {
        _customDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      } else if (date != null) {
        _customDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          currentCustom.hour,
          currentCustom.minute,
        );
      } else if (time != null) {
        _customDateTime = DateTime(
          currentCustom.year,
          currentCustom.month,
          currentCustom.day,
          time.hour,
          time.minute,
        );
      }
    }
  }
}





















