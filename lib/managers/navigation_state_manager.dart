import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/screens/rapporteren.dart';

class NavigationStateManager implements NavigationStateInterface {
  final List<TextEditingController> _controllers = [];
  final greenLog = '\x1B[32m';
  final resetLog = '\x1B[0m';

  @override
  void dispose() {
    debugPrint('${greenLog}[NavigationStateManager] Disposing controllers: ${_controllers.length} controllers$resetLog');
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
  }

  @override
  void resetToHome(BuildContext context) {
    // First, navigate to new screen and clear the navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const Rapporteren(),
      ),
      (route) => false,
    );

    // Then, clear all state after navigation is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearApplicationState(context);
    });
  }

  @override
  void clearApplicationState(BuildContext context) {
    // Clear animal-specific state
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    animalSightingManager.clearCurrentanimalSighting();

    // Clear global app state
    final appStateProvider = context.read<AppStateProvider>();
    appStateProvider.resetApplicationState(context);
  }

  @override
  void pushAndRemoveUntil(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  @override
  void pushReplacementForward(BuildContext context, Widget screen) {
    dispose(); // Clean up before navigation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  void pushReplacementBack(BuildContext context, Widget screen) {
    dispose(); // Clean up before navigation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }
}

