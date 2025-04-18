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

class _VerificationCodeInputState extends State<VerificationCodeInput> with SingleTickerProviderStateMixin {
  final List<TextEditingController> controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  final LoginInterface loginManager = LoginManager(AuthApi(AppConfig.shared.apiClient));
  late final AnimationController _animationController;
  bool isLoading = false;
  bool isError = false;
  User? verifiedUser;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  Future<void> _verifyCode() async {
    FocusScope.of(context).unfocus();

    final code = controllers.map((c) => c.text).join();
    debugPrint("Email: ${widget.email} & Code: $code");

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      User response = await loginManager.verifyCode(widget.email, code);
      debugPrint("verified!!");
      verifiedUser = response;

      // Ensure animation plays at least one full cycle
      if (_animationController.duration != null) {
        // Reset animation to start
        _animationController.reset();
        // Start animation
        _animationController.forward();
        // Wait for one full cycle
        await Future.delayed(_animationController.duration!);
      } else {
        // Fallback if animation duration isn't set
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      if (context.mounted && verifiedUser != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const OverzichtScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
        verifiedUser = null;
      });

      if (context.mounted) {
        for (var controller in controllers) {
          controller.clear();
        }
        focusNodes[0].requestFocus();
      }
    }
  }

  Widget _buildTextField(int index) {
    return Container(
      width: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isError ? Colors.red.shade50.withOpacity(0.9) : Colors.white,
        border: isError
            ? Border.all(color: Colors.red.shade300, width: 1.0)
            : Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: isError
                ? Colors.red.withOpacity(0.1)
                : Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RawKeyboardListener(
        focusNode: FocusNode(), // Unique FocusNode for each listener
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            // If current field is empty and not the first field
            if (controllers[index].text.isEmpty && index > 0) {
              // Move focus to previous field and clear it
              focusNodes[index - 1].requestFocus();
              controllers[index - 1].clear();
            }
          }
        },
        child: TextField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
          onChanged: (value) {
            if (isError) {
              setState(() => isError = false);
            }
            if (value.isNotEmpty) {
              // Move to next field if not the last one
              if (index < 5) {
                focusNodes[index + 1].requestFocus();
              } else if (index == 5) {
                // Verify code if all fields are filled
                if (controllers.every((c) => c.text.isNotEmpty)) {
                  _verifyCode();
                }
              }
            } else if (value.isEmpty && index > 0) {
              // Move to previous field when backspace clears the current field
              focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
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
            controller: _animationController,
            onLoaded: (composition) {
              _animationController.duration = composition.duration;
              _animationController.forward();
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
              onPressed: () {
                // Unfocus all text fields before going back
                FocusScope.of(context).unfocus();
                widget.onBack();
              },
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
        if (isError) ...[
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10),
            child: Text(
              'Verkeerde code. Probeer het opnieuw.',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildTextField(index)),
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
    _animationController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}


