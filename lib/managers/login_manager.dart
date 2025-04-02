<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:wildrapport/config/app_config.dart';
=======
import 'package:flutter/src/widgets/framework.dart';
>>>>>>> ea995d1a941e8197abbd889d59a295f52ace64a9
import 'package:wildrapport/interfaces/api/auth_api_interface.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/models/api_models/user.dart';
import 'package:wildrapport/exceptions/validation_exception.dart';

class LoginManager implements LoginInterface {
  final AuthApiInterface authApi;
  final List<VoidCallback> _listeners = [];
  bool _showVerification = false;
  bool _isError = false;
  String _errorMessage = '';

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
        fontSize: 16,
      );
    }
    
    return BrownButtonModel(
      text: text,
      leftIconPath: leftIconPath,
      rightIconPath: rightIconPath,
    );
  }

  @override
  Future<bool> handleLogin(String email, BuildContext context) async {
    setError(false);
    setVerificationVisible(true);
    
    try {
      return await sendLoginCode(email);
    } catch (e) {
      setVerificationVisible(false);
      setError(true, e.toString());
      return false;
    }
  }

  @override
  Future<bool> sendLoginCode(String email) async {
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
    try {
      return await authApi.authorize(email, code);
    } catch (e) {
      throw Exception("Unhandled Unauthorized Exception");
    }
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
<<<<<<< HEAD
  void setVerificationVisible(bool visible) {
    _showVerification = visible;
    _notifyListeners();
  }

  @override
  bool isVerificationVisible() => _showVerification;

  @override
  bool hasError() => _isError;

  @override
  String getErrorMessage() => _errorMessage;

  @override
  void setError(bool isError, [String message = '']) {
    _isError = isError;
    _errorMessage = message;
    _notifyListeners();
  }

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
=======
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
>>>>>>> ea995d1a941e8197abbd889d59a295f52ace64a9
    }
  }
}

<<<<<<< HEAD
=======
//use interface of api
>>>>>>> ea995d1a941e8197abbd889d59a295f52ace64a9
