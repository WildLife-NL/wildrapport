import 'package:wildrapport/models/brown_button_model.dart';

class LoginService {
  static BrownButtonModel createButtonModel({
    required String text,
    String leftIconPath = '',
    String rightIconPath = '',
    bool isLoginButton = false,  // Add flag to differentiate login buttons
  }) {
    if (isLoginButton) {
      return BrownButtonModel(
        text: text,
        leftIconPath: leftIconPath,
        rightIconPath: rightIconPath,
        height: 48,        // Match TextField height
        fontSize: 16,      // Specific font size for login
        leftIconSize: 24,
        rightIconSize: 24,
      );
    }
    
    // Default button model for other cases
    return BrownButtonModel(
      text: text,
      leftIconPath: leftIconPath,
      rightIconPath: rightIconPath,
      leftIconSize: 38,    // Original size
      rightIconSize: 24,   // Original size
    );
  }
}


