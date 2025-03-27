import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/app_state_provider.dart';

abstract class ScreenStateManager<T extends StatefulWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppStateProvider>().pushScreen(screenName);
      loadScreenState();
    });
  }

  @override
  void dispose() {
    saveScreenState();  // Save state before disposal
    context.read<AppStateProvider>().popScreen();  // Just remove from stack, keep state
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Add any common dependencies handling
  }

  // Abstract methods that screens must implement
  Map<String, dynamic> getInitialState();
  String get screenName;

  // Common state loading logic
  void loadScreenState() {
    final provider = context.read<AppStateProvider>();
    final initialState = getInitialState();
    
    initialState.forEach((key, defaultValue) {
      final value = provider.getScreenState<dynamic>(screenName, key) ?? defaultValue;
      setState(() {
        updateState(key, value);
      });
    });
  }

  // Common state saving logic
  void saveScreenState() {
    final provider = context.read<AppStateProvider>();
    final currentState = getCurrentState();
    
    currentState.forEach((key, value) {
      provider.setScreenState(screenName, key, value);
    });
  }

  // Abstract method to update state values
  void updateState(String key, dynamic value);

  // Abstract method to get current state values
  Map<String, dynamic> getCurrentState();

  // Helper method to safely update state
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // Add report handling methods
  void initializeReportFlow(String reportType) {
    context.read<AppStateProvider>().initializeReport(reportType);
  }

  T? getCurrentReport<T>() {
    return context.read<AppStateProvider>().getCurrentReport<T>();
  }

  void updateReport(String property, dynamic value) {
    context.read<AppStateProvider>().updateCurrentReport(property, value);
  }

  // Modify clearAllConfirmation to also clear current report
  void clearAllConfirmation(BuildContext context) {
    context.read<AppStateProvider>().clearCurrentReport();
    Navigator.of(context).pop();
    context.read<AppStateProvider>()
        .clearAllStatesAndNavigateToRapporteren(context);
  }
}


