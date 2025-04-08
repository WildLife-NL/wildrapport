import 'package:flutter/foundation.dart';
import 'package:wildrapport/models/waarneming_model.dart';

abstract class WaarnemingReportingInterface {
  /// Returns a new waarneming model with null fields
  WaarnemingModel createWaarneming();

  /// Adds a listener for state changes
  void addListener(VoidCallback listener);

  /// Removes a listener
  void removeListener(VoidCallback listener);
}

