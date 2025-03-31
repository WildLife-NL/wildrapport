import 'dart:nativewrappers/_internal/vm/lib/developer.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/models/brown_button_model.dart';

import 'package:wildlife_api_connection/auth_api.dart';
import 'package:wildrapport/constants/api_url.dart';
import 'package:wildlife_api_connection/models/user.dart';

class LoginManager implements LoginInterface {
  static BrownButtonModel createButtonModel({
    required String text,
    String leftIconPath = '',
    String rightIconPath = '',
    bool isLoginButton = false,
  }) {
    if (isLoginButton) {
      return BrownButtonModel(
        text: text,
        leftIconPath: leftIconPath,
        rightIconPath: rightIconPath,
        fontSize: 16,      // Override font size for login
      );
    }
    
    return BrownButtonModel(
      text: text,
      leftIconPath: leftIconPath,
      rightIconPath: rightIconPath,
    );
  }

  @override
  Future<bool> handleLogin(String email, BuildContext context) {
    // TODO: implement handleLogin
    throw UnimplementedError();
  }

  @override
  Future<bool> handleVerificationCode(String email, String code, BuildContext context) {
    // TODO: implement handleVerificationCode
    throw UnimplementedError();
  }

  @override
  Future<bool> resendCode(String email) {
    // TODO: implement resendCode
    throw UnimplementedError();
  }

  @override
  Future<bool> sendLoginCode(String email) async {
    try{
      AuthApi(ApiUrl.apiClient)
      .authenticate("Wild Rapport", email);
      return true;
    }
    catch(e){
      //TODO: Handle exception
      return false;
    }
  }

  @override
  Future<User> verifyCode(String email, String code) async {
    try{
      return AuthApi(ApiUrl.apiClient)
      .authorize(email, code);
    }
    catch(e){
      //TODO: Handle exception
      throw Exception("Unhandled Unauthorized Exception")
    }
  }
}