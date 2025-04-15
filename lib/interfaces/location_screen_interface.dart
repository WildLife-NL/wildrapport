import 'package:flutter/material.dart';

abstract class LocationScreenInterface {
  // State getters
  bool get isLocationDropdownExpanded;
  bool get isDateTimeDropdownExpanded;
  String get selectedLocation;
  String get selectedDateTime;
  String get currentLocationText;
}