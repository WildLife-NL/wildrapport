import 'package:flutter/material.dart';
import 'package:wildrapport/models/api_models/user.dart';

abstract class LoginInterface {
  /// Validates email format and returns error message if invalid, null if valid
  String? validateEmail(String? email);
  
  Future<bool> handleLogin(String email, BuildContext context);
  Future<bool> handleVerificationCode(String email, String code, BuildContext context);
  Future<bool> resendCode(String email);
  Future<User> verifyCode(String email, String code);
  Future<bool> sendLoginCode(String email);
}



