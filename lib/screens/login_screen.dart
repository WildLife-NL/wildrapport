import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/models/factories/button_model_factory.dart';
import 'package:wildrapport/screens/login_overlay.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/verification_code_input.dart';
import 'package:wildrapport/interfaces/login_interface.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  late final LoginInterface _loginManager;
  bool showVerification = false;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loginManager = context.read<LoginInterface>();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    debugPrint('Login button pressed');
    // Immediately show verification screen
    setState(() {
      isError = false;
      errorMessage = '';
      showVerification = true;
    });
    
    // Handle API call in the background
    _loginManager.sendLoginCode(emailController.text).then((response) {
      if (!response) {
        setState(() {
          showVerification = false;
          isError = true;
          errorMessage = 'Login mislukt';
          debugPrint("Login Failed");
        });
      } else {
        debugPrint("Verification Code Sent To Email!");
      }
    }).catchError((e) {
      setState(() {
        showVerification = false;
        isError = true;
        errorMessage = e.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building LoginScreen, showVerification: $showVerification');
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(75),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/LogoWildlifeNL.png',
                      width: screenWidth * 0.7,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    right: -10,
                    child: Image.asset(
                      'assets/gifs/login.gif',
                      width: screenWidth * 0.35,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: showVerification
                  ? VerificationCodeInput(
                      onBack: () {
                        setState(() {
                          showVerification = false;
                        });
                      },
                      email: emailController.text,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voer uw e-mailadres in',
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
                        const SizedBox(height: 5),
                        if (isError) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 5),
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        Container(
                          decoration: BoxDecoration(
                            color: isError 
                              ? Colors.red.shade50.withOpacity(0.9) 
                              : AppColors.offWhite,
                            borderRadius: BorderRadius.circular(25),
                            border: isError ? Border.all(
                              color: Colors.red.shade300,
                              width: 1.0,
                            ) : null,
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
                          child: TextField(
                            controller: emailController,
                            onChanged: (value) {
                              if (isError) {
                                setState(() {
                                  isError = false;
                                  errorMessage = '';
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'voorbeeld@gmail.com',
                              hintStyle: TextStyle(
                                color: isError 
                                  ? Colors.red.shade200
                                  : Colors.grey,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        BrownButton(
                          model: ButtonModelFactory.createLoginButton(
                            text: 'Login',
                          ),
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => const LoginOverlay(),
                              );
                            },
                            child: Text(
                              'Leer hoe de registratie werkt?',
                              style: TextStyle(
                                color: AppColors.brown,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.brown,
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
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}



