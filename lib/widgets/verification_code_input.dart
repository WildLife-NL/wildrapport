import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wildrapport/api/auth_api.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/managers/login_manager.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/models/api_models/user.dart';
import 'package:lottie/lottie.dart';

class VerificationCodeInput extends StatefulWidget {
  final VoidCallback onBack;
  final String email;

  const VerificationCodeInput({
    super.key,
    required this.onBack,
    required this.email,
  });

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  final List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final LoginInterface loginManager = LoginManager(AuthApi(AppConfig.shared.apiClient));  
  bool isLoading = false;
  User? verifiedUser;

  Future<void> _verifyCode() async {
    // First unfocus any active text fields
    FocusScope.of(context).unfocus();
    
    // Get the verification code
    final code = controllers.map((c) => c.text).join();
    debugPrint("Email: ${widget.email} & Code: $code");
    
    setState(() {
      isLoading = true;
    });
    
    try {
      User response = await loginManager.verifyCode(widget.email, code);
      debugPrint("verified!!");
      
      // Store the user response but don't navigate yet
      verifiedUser = response;
      
      // Wait for animation to complete at least one cycle (assuming animation is ~1 second)
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Navigate if still mounted and verified
      if (context.mounted && verifiedUser != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const OverzichtScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      // Wait a moment before showing error to ensure smooth animation
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        isLoading = false;
        verifiedUser = null;
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verkeerde code. Probeer het opnieuw.'),
            backgroundColor: AppColors.brown,
          ),
        );
        
        // Clear all fields
        for (var controller in controllers) {
          controller.clear();
        }
        // Focus on first field
        focusNodes[0].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/loaders/loading_paw.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            frameRate: FrameRate(60),
            // Optional: You can add onLoaded callback to get exact animation duration
            onLoaded: (composition) {
              debugPrint('Animation duration: ${composition.duration}');
            },
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.brown,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Text(
              'Voer de verificatiecode in',
              style: AppTextTheme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => Container(
              width: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.darkGreen),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    focusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    focusNodes[index - 1].requestFocus();
                  }
                  
                  // Check if all fields are filled
                  if (value.isNotEmpty && index == 5) {
                    // Verify if all fields have a value
                    bool allFilled = controllers.every((controller) => 
                      controller.text.isNotEmpty
                    );
                    if (allFilled) {
                      _verifyCode();
                    }
                  }
                },
              ),
            ),
          ),
        ),
        const Spacer(),
        BrownButton(
          model: LoginManager.createButtonModel(text: 'Verifiëren'),
          onPressed: _verifyCode,
        ),
        const SizedBox(height: 15),
        Center(
          child: InkWell(
            onTap: () {
              // Resend code logic would go here
            },
            child: Text(
              'Code niet ontvangen? Stuur opnieuw',
              style: TextStyle(
                color: AppColors.brown,
                decoration: TextDecoration.underline,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}


