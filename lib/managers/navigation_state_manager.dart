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

  void addController(TextEditingController controller) {
    _controllers.add(controller);
  }

  @override
  void dispose() {
    debugPrint('${greenLog}[NavigationStateManager] Disposing controllers: ${_controllers.length} controllers$resetLog');
    for (var controller in _controllers) {
      controller.dispose();
    }
    _controllers.clear();
    debugPrint('${greenLog}[NavigationStateManager] All controllers disposed and cleared$resetLog');
  }

  @override
  void resetToHome(BuildContext context) {
    // Clear animal sighting state
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    animalSightingManager.clearCurrentanimalSighting();

    // Navigate to home screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const Rapporteren(),
      ),
      (route) => false,
    );
  }

  @override
  void clearApplicationState(BuildContext context) {
    // Clear animal sighting state
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    animalSightingManager.clearCurrentanimalSighting();

    // Clear app state
    final appStateProvider = context.read<AppStateProvider>();
    appStateProvider.clearCurrentReport();
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
    debugPrint('${greenLog}[NavigationStateManager] Replacing current screen with next screen$resetLog');
    dispose(); // Clean up before navigation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }

  @override
  void pushReplacementBack(BuildContext context, Widget screen) {
    debugPrint('${greenLog}[NavigationStateManager] Replacing current screen with previous screen$resetLog');
    dispose(); // Clean up before navigation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );
  }
}


