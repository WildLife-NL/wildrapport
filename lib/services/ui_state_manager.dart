import 'package:flutter/material.dart';

class UIStateManager extends ChangeNotifier {
  static final UIStateManager _instance = UIStateManager._internal();
  factory UIStateManager() => _instance;
  UIStateManager._internal();

  bool _hasWindowFocus = true;
  bool get hasWindowFocus => _hasWindowFocus;

  // Keep track of active screens that need rebuilding
  final Set<BuildContext> _activeContexts = {};

  void setWindowFocus(bool hasFocus) {
    if (_hasWindowFocus != hasFocus) {
      print('UIStateManager: Window focus changed to: $hasFocus');
      _hasWindowFocus = hasFocus;
      if (hasFocus) {
        print('UIStateManager: Rebuilding ${_activeContexts.length} active screens');
        rebuildActiveScreens();
      }
      notifyListeners();
    }
  }

  void registerScreen(BuildContext context) {
    print('UIStateManager: Registering screen: ${context.widget.runtimeType}');
    _activeContexts.add(context);
  }

  void unregisterScreen(BuildContext context) {
    print('UIStateManager: Unregistering screen: ${context.widget.runtimeType}');
    _activeContexts.remove(context);
  }

  void rebuildActiveScreens() {
    for (final context in _activeContexts) {
      if (context.mounted) {
        // Force rebuild of registered screens
        (context as Element).markNeedsBuild();
      }
    }
  }

  // Optional: Add caching mechanism if needed
  final Map<String, dynamic> _uiStateCache = {};

  void cacheUIState(String key, dynamic state) {
    _uiStateCache[key] = state;
  }

  dynamic getCachedUIState(String key) {
    return _uiStateCache[key];
  }

  void clearCache() {
    _uiStateCache.clear();
  }
}
