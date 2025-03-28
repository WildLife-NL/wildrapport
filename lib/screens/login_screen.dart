import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/login_overlay.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/verification_code_input.dart';
import 'package:wildrapport/managers/login_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  bool showVerification = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppStateProvider>();
      showVerification = provider.getScreenState<bool>('LoginScreen', 'showVerification') ?? false;
      emailController.text = provider.getScreenState<String>('LoginScreen', 'email') ?? '';
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    final provider = context.read<AppStateProvider>();
    provider.setScreenState('LoginScreen', 'showVerification', showVerification);
    provider.setScreenState('LoginScreen', 'email', emailController.text);
    emailController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    print('Login button pressed');
    setState(() {
      showVerification = true;
    });
    print('showVerification set to: $showVerification');
  }


  @override
  Widget build(BuildContext context) {
    print('Building LoginScreen, showVerification: $showVerification');
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
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.offWhite,
                            borderRadius: BorderRadius.circular(25),
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
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'voorbeeld@gmail.com',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        BrownButton(
                          model: LoginManager.createButtonModel(
                            text: 'Login',
                            isLoginButton: true,  // This will use the login-specific styling
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

































