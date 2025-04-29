import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/models/enums/date_time_type.dart';
import 'package:provider/provider.dart';

import 'package:wildrapport/providers/map_provider.dart';
class LocationScreenManager implements LocationScreenInterface {
  // Private state variables
  bool _isLocationDropdownExpanded = false;
  bool _isDateTimeDropdownExpanded = false;
  String _selectedLocation = LocationType.current.displayText;
  String _selectedDateTime = DateTimeType.current.displayText;
  String _currentLocationText = 'Huidige locatie wordt geladen...';

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
    final locationInfo = getLocationAndDateTime(context);
    return Future.value();
  }

  Map<String, dynamic> getLocationAndDateTime(BuildContext context) {
    final mapProvider = context.read<MapProvider>();
    
    // Get current GPS location
    final currentGpsLocation = mapProvider.currentPosition != null 
        ? {
            'latitude': mapProvider.currentPosition!.latitude,
            'longitude': mapProvider.currentPosition!.longitude,
            'address': mapProvider.currentAddress,
          }
        : null;

    // Get user selected location
    final selectedLocation = mapProvider.selectedPosition != null 
        ? {
            'latitude': mapProvider.selectedPosition!.latitude,
            'longitude': mapProvider.selectedPosition!.longitude,
            'address': mapProvider.selectedAddress,
          }
        : null;

    // Get date time information
    final dateTimeInfo = _getDateTimeInfo();

    return {
      'currentGpsLocation': currentGpsLocation,
      'selectedLocation': selectedLocation,
      'dateTime': dateTimeInfo,
      'isLocationUnknown': selectedLocation == null || 
          mapProvider.selectedAddress == LocationType.unknown.displayText,
      'isDateTimeUnknown': _selectedDateTime == DateTimeType.unknown.displayText,
    };
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

  // Example usage method
  void printLocationAndDateTime(BuildContext context) {
    final info = getLocationAndDateTime(context);
    
    debugPrint('\x1B[32m[LocationScreen] Location and DateTime Info:');
    debugPrint('Current GPS: ${info['currentGpsLocation']}');
    debugPrint('Selected Location: ${info['selectedLocation']}');
    debugPrint('DateTime Info: ${info['dateTime']}');
    debugPrint('Is Location Unknown: ${info['isLocationUnknown']}');
    debugPrint('Is DateTime Unknown: ${info['isDateTimeUnknown']}\x1B[0m');
  }
}







