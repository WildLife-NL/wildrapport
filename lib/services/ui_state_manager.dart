import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/ui_state_interface.dart';

class UIStateManager implements UIStateInterface {
  static final UIStateManager _instance = UIStateManager._internal();
  factory UIStateManager() => _instance;
  UIStateManager._internal();

  @override
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

  @override
  void registerScreen(BuildContext context) {
    print('UIStateManager: Registering screen: ${context.widget.runtimeType}');
    _activeContexts.add(context);
  }

  @override
  void unregisterScreen(BuildContext context) {
    print('UIStateManager: Unregistering screen: ${context.widget.runtimeType}');
    _activeContexts.remove(context);
  }


  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  @override
  bool get hasWindowFocus => _hasWindowFocus;
  bool _hasWindowFocus = true;

  final Set<BuildContext> _activeContexts = {};
  final Map<String, Map<String, dynamic>> _screenStates = {};

  @override
  void setScreenState(String screenName, String key, dynamic value) {
    _screenStates[screenName] ??= {};
    _screenStates[screenName]![key] = value;
    notifyListeners();
  }

  @override
  T? getScreenState<T>(String screenName, String key) {
    return _screenStates[screenName]?[key] as T?;
  }

  void clearScreenState(String screenName) {
    _screenStates.remove(screenName);
    notifyListeners();
  }

  void clearAllScreenStates() {
    _screenStates.clear();
    notifyListeners();
  }

  void rebuildActiveScreens() {
    for (final context in _activeContexts) {
      if (context.mounted) {
        (context as Element).markNeedsBuild();
      }
    }
  }

  // Optional: Keep the existing cache methods for backward compatibility
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



