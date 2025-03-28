import 'package:flutter/material.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
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

  void saveState(AppStateProvider provider) {
    provider.setScreenState('LoginScreen', 'showVerification', showVerification);
    provider.setScreenState('LoginScreen', 'email', emailController.text);
  }

  void loadState(AppStateProvider provider) {
    showVerification = provider.getScreenState('LoginScreen', 'showVerification') ?? false;
    emailController.text = provider.getScreenState('LoginScreen', 'email') ?? '';
  }
}