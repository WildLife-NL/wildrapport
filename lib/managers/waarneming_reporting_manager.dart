import 'package:flutter/foundation.dart';
import 'package:wildrapport/interfaces/waarneming_reporting_interface.dart';
import 'package:wildrapport/models/waarneming_model.dart';

class WaarnemingReportingManager implements WaarnemingReportingInterface {
  final List<VoidCallback> _listeners = [];

  @override
  WaarnemingModel createWaarneming() {
    return WaarnemingModel(
      animals: null,
      condition: null,
      category: null,
      gender: null,
      age: null,
      description: null,
      location: null,
      dateTime: null,
      images: null,
    );
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

