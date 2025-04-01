import 'package:flutter/src/widgets/framework.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/providers/api_provider.dart';
import 'package:wildrapport/models/user_model.dart';

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
      ApiProvider(AppConfig.shared.apiClient).authenticate("Wild Rapport", email);
      return true;
    }
    catch(e){
      //TODO: Handle exception
      return false;
    }
  }

  @override
  Future<UserModel> verifyCode(String email, String code) async {
    try{
      return ApiProvider(AppConfig.shared.apiClient).authorize(email, code);
    }
    catch(e){
      //TODO: Handle exception
      throw Exception("Unhandled Unauthorized Exception");
    }
  }
}

//use interface of api