import 'package:flutter/material.dart';
import 'package:wildrapport/managers/login_manager.dart';

class LoginViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  bool showVerification = false;
  
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void handleLogin() {
    showVerification = true;
    notifyListeners();
  }

  bool isValidEmail() {
    return emailController.text.contains('@');
  }
}
