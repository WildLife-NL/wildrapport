import 'package:flutter/material.dart';

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
}
