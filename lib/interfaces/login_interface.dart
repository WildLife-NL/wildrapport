import 'package:flutter/material.dart';
import 'package:wildrapport/models/api_models/user.dart';

abstract class LoginInterface {
  /// Validates email format and returns error message if invalid, null if valid
  String? validateEmail(String? email);
  
  /// Handles the login process
  Future<bool> handleLogin(String email, BuildContext context);
  
  /// Handles verification code submission
  Future<bool> handleVerificationCode(String email, String code, BuildContext context);
  
  /// Resends verification code
  Future<bool> resendCode(String email);
  
  /// Verifies the code and returns user data
  Future<User> verifyCode(String email, String code);
  
  /// Sends initial login code
  Future<bool> sendLoginCode(String email);

  /// Shows or hides verification screen
  void setVerificationVisible(bool visible);
  
  /// Gets current verification screen visibility state
  bool isVerificationVisible();
  
  /// Gets current error state
  bool hasError();
  
  /// Gets current error message
  String getErrorMessage();
  
  /// Sets error state and message
  void setError(bool isError, [String message = '']);
  
  /// Add listener for state changes
  void addListener(VoidCallback listener);
  
  /// Remove listener for state changes
  void removeListener(VoidCallback listener);
}





