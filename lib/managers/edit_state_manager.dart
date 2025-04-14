import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/edit_state_interface.dart';

class EditStateManager implements EditStateInterface {
  bool _isEditMode = false;
  final List<VoidCallback> _listeners = [];

  @override
  bool get isEditMode => _isEditMode;

  @override
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    _notifyListeners();
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
    for (var listener in _listeners) {
      listener();
    }
  }
}