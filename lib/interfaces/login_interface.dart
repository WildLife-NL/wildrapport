import 'package:flutter/material.dart';
import 'package:wildlife_api_connection/models/user.dart';

abstract class LoginInterface {
  Future<bool> handleLogin(String email, BuildContext context);
  Future<bool> handleVerificationCode(String email, String code, BuildContext context);
  Future<bool> resendCode(String email);
  Future<User> verifyCode(String email, String code);
  Future<bool> sendLoginCode(String email);
}


