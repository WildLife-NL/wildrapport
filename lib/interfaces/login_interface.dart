import 'package:flutter/material.dart';
import 'package:wildrapport/models/user_model.dart';
abstract class LoginInterface {
  Future<bool> handleLogin(String email, BuildContext context);
  Future<bool> handleVerificationCode(String email, String code, BuildContext context);
  Future<bool> resendCode(String email);
  Future<UserModel> verifyCode(String email, String code);
  Future<bool> sendLoginCode(String email);
}


