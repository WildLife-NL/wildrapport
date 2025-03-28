import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/app_state_provider.dart';

abstract class ScreenStateManager<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      loadScreenState();
    });
  }

  @override
  void dispose() {
    saveScreenState();
    super.dispose();
  }

  // Abstract methods that screens must implement
  Map<String, dynamic> getInitialState();
  String get screenName;

  void loadScreenState() {
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

  void saveScreenState() {
    final provider = context.read<AppStateProvider>();
    final currentState = getCurrentState();
    
    currentState.forEach((key, value) {
      provider.setScreenState(screenName, key, value);
    });
  }

  void updateState(String key, dynamic value);
  Map<String, dynamic> getCurrentState();

  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // Report handling methods
  void initializeReportFlow(String reportType) {
    context.read<AppStateProvider>().initializeReport(reportType);
  }

  T? getCurrentReport<T>() {
    return context.read<AppStateProvider>().getCurrentReport<T>();
  }

  void updateReport(String property, dynamic value) {
    context.read<AppStateProvider>().updateCurrentReport(property, value);
  }

  void clearAllConfirmation(BuildContext context) {
    context.read<AppStateProvider>().clearCurrentReport();
    Navigator.of(context).pop();
    context.read<AppStateProvider>().resetApplicationState(context);
  }

  void resetApplication({Widget? destination}) {
    context.read<AppStateProvider>().resetApplicationState(
      context,
      destination: destination,
    );
  }
}



