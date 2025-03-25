import 'package:flutter/material.dart';
import 'package:wildrapport/services/ui_state_manager.dart';

mixin UIStateAware<T extends StatefulWidget> on State<T> {
  final UIStateManager _uiStateManager = UIStateManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uiStateManager.registerScreen(context);
    });
  }

  @override
  void dispose() {
    _uiStateManager.unregisterScreen(context);
    super.dispose();
  }

  // Optional: Helper methods for caching
  void cacheUIState(String key, dynamic state) {
    _uiStateManager.cacheUIState('${widget.runtimeType}_$key', state);
  }

  dynamic getCachedUIState(String key) {
    return _uiStateManager.getCachedUIState('${widget.runtimeType}_$key');
  }
}