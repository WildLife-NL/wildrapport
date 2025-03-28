import 'package:flutter/material.dart';
import 'package:wildrapport/providers/app_state_provider.dart';

class OverzichtViewModel extends ChangeNotifier {
  String userName = 'John Doe';
  final double topContainerHeight = 285.0;
  final double welcomeFontSize = 20.0;
  final double usernameFontSize = 24.0;
  final double logoWidth = 180.0;
  final double logoHeight = 180.0;

  void updateUserName(String newName) {
    userName = newName;
    notifyListeners();
  }

  void saveState(AppStateProvider provider) {
    provider.setScreenState('OverzichtScreen', 'userName', userName);
  }

  void loadState(AppStateProvider provider) {
    userName = provider.getScreenState('OverzichtScreen', 'userName') ?? 'John Doe';
  }
}