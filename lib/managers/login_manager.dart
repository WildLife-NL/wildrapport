import 'package:flutter/src/widgets/framework.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:wildrapport/interfaces/api/auth_api_interface.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/providers/api_provider.dart';
import 'package:wildrapport/models/api_models/user.dart';
import 'package:wildrapport/exceptions/validation_exception.dart';

class LoginManager implements LoginInterface {
  final AuthApiInterface authApi;
  LoginManager(this.authApi);
  
  // Email validation regex
  static final _emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

  @override
  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Voer een e-mailadres in';
    }
    if (!_emailRegex.hasMatch(email.trim())) {
      return 'Voer een geldig e-mailadres in';
    }
    return null;
  }

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
    // Validate email first
    final validationError = validateEmail(email);
    if (validationError != null) {
      throw ValidationException(validationError);
    }

    try {
      await authApi.authenticate("Wild Rapport", email.trim());
      return true;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<User> verifyCode(String email, String code) async {
    try{
      return authApi.authorize(email, code);
    }
    catch(e){
      //TODO: Handle exception
      throw Exception("Unhandled Unauthorized Exception");
    }
  }
}

//use interface of api