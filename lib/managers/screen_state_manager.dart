import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/screen_state_interface.dart';
import 'package:wildrapport/providers/app_state_provider.dart';

abstract class ScreenStateManager<T extends StatefulWidget> extends State<T> implements ScreenStateInterface {
  @override
  void initState() {
    super.initState();
    // Schedule loading screen state after the first frame to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      loadScreenState();
    });
  }

  @override
  void dispose() {
    // Save screen state before disposing to persist user's settings
    saveScreenState();
    super.dispose();
  }

  // Abstract methods that screens must implement
  // Returns the default state values for this screen
  Map<String, dynamic> getInitialState();
  // Returns the unique identifier for this screen
  String get screenName;

  @override
  void loadScreenState() {
    // Loads saved state from AppStateProvider and updates the current screen state
    final provider = context.read<AppStateProvider>();
    final initialState = getInitialState();
    final currentState = getCurrentState();

    initialState.forEach((key, defaultValue) {
      final savedValue = provider.getScreenState<dynamic>(screenName, key);
      final value = savedValue ?? defaultValue;
      if (currentState[key] != value) {
        updateState(key, value);
      }
    });
  }

  @override
  void saveScreenState() {
    // Persists the current screen state to AppStateProvider
    final provider = context.read<AppStateProvider>();
    final currentState = getCurrentState();
    
    currentState.forEach((key, value) {
      provider.setScreenState(screenName, key, value);
    });
  }

  @override
  // Updates a specific state key with a new value
  void updateState(String key, dynamic value);
  
  @override
  // Returns the current state map for this screen
  Map<String, dynamic> getCurrentState();

  @override
  void safeSetState(VoidCallback fn) {
    // Safely calls setState only if the widget is still mounted
    if (mounted) {
      setState(fn);
    }
  }
}



