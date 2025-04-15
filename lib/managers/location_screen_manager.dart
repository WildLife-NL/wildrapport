import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/models/enums/date_time_type.dart';

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
}