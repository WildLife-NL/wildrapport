import 'package:flutter/material.dart';

abstract class LocationScreenInterface {
  // Existing state getters
  bool get isLocationDropdownExpanded;
  bool get isDateTimeDropdownExpanded;
  String get selectedLocation;
  String get selectedDateTime;
  String get currentLocationText;
  Map<String, dynamic> getLocationAndDateTime(BuildContext context);

  // Add the new method
  Future<void> handleNextPressed(BuildContext context);
}
