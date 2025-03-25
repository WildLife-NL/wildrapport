import 'package:flutter/material.dart';
import 'package:wildrapport/services/ui_state_manager.dart';

mixin UIStateAware<T extends StatefulWidget> on State<T> {
  final UIStateManager _uiStateManager = UIStateManager();
  
  // Override these in your state class to specify what to save/load
  Map<String, dynamic> saveState() => {};
  void loadState(Map<String, dynamic> state) {}

  void setScreenState(String key, dynamic value) {
    _uiStateManager.setScreenState(widget.runtimeType.toString(), key, value);
  }

  T? getScreenState<T>(String key) {
    return _uiStateManager.getScreenState<T>(widget.runtimeType.toString(), key);
  }

  void saveAllState() {
    final state = saveState();
    for (final entry in state.entries) {
      setScreenState(entry.key, entry.value);
    }
  }

  void loadAllState() {
    final state = Map<String, dynamic>.fromEntries(
      saveState().keys.map((key) => MapEntry(key, getScreenState(key)))
    );
    loadState(state);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uiStateManager.registerScreen(context);
      loadAllState();
    });
  }

  @override
  void dispose() {
    saveAllState();
    _uiStateManager.unregisterScreen(context);
    super.dispose();
  }
}

