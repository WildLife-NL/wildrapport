import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/profile_api.dart';
import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';
import 'package:wildrapport/screens/login/access_denied_screen.dart';
import 'package:wildrapport/screens/login/login_overlay.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/screens/terms/terms_screen.dart';
import 'package:wildlifenl_authenticator_components/wildlifenl_authenticator_components.dart';
import 'package:wildrapport/widgets/overlay/error_overlay.dart';
import 'package:wildlifenl_login_components/wildlifenl_login_components.dart';
import 'package:wildrapport/constants/app_icon_paths.dart';
import 'package:lottie/lottie.dart';
import 'package:wildrapport/utils/access_scope_utils.dart';

Future<void> _routeAfterLogin(BuildContext context) async {
  try {
    // Give the authenticator a moment to update with the new token
    await Future.delayed(const Duration(milliseconds: 500));
    
    ProfileApiInterface profileApi;
    try {
      profileApi = context.read<ProfileApiInterface>();
    } catch (_) {
      profileApi = ProfileApi(AppConfig.shared.apiClient);
    }
    
    // Refresh profile data with new token
    await profileApi.setProfileDataInDeviceStorage();
    if (!context.mounted) return;
    
    final profile = await profileApi.fetchMyProfile();
    if (!context.mounted) return;
    
    // Check access with fresh authenticator state
    final authenticator = context.read<WildLifeNLAuthenticator>();
    final hasValidToken = await authenticator.hasValidToken();
    
    debugPrint('[LoginScreen] Token valid: $hasValidToken');
    
    // If we have a valid token AND we successfully fetched the profile,
    // the user should have access
    if (!hasValidToken) {
      debugPrint('[LoginScreen] No valid token, denying access');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AccessDeniedScreen()),
        (_) => false,
      );
      return;
    }
    
    // Token is valid, now check if we should show terms or go to main screen
    if (profile.reportAppTerms == true) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (_) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TermsScreen()),
        (_) => false,
      );
    }
  } catch (e) {
    debugPrint('[LoginScreen] Routing error: $e');
    if (!context.mounted) return;
    
    // On error, check if we at least have a valid token
    try {
      final hasValidToken = await context.read<WildLifeNLAuthenticator>().hasValidToken();
      if (hasValidToken) {
        // If token is valid, go to main screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (_) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AccessDeniedScreen()),
          (_) => false,
        );
      }
    } catch (_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AccessDeniedScreen()),
        (_) => false,
      );
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showCodeInput = false;
  String _currentEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Voer uw e-mailadres in';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get the login interface and send verification code to email
      final loginInterface = context.read<LoginInterface>();
      final success = await loginInterface.sendLoginCode(email);
      
      if (!success) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Kon verificatiecode niet verzenden';
            _isLoading = false;
          });
        }
        return;
      }
      
      if (mounted) {
        // Show code input screen after successful code send
        setState(() {
          _showCodeInput = true;
          _currentEmail = email;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fout bij aanmelden: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();
    
    if (code.isEmpty) {
      setState(() {
        _errorMessage = 'Voer de verificatiecode in';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loginInterface = context.read<LoginInterface>();
      final result = await loginInterface.verifyCode(_currentEmail, code);
      
      if (result == null || result == false) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Ongeldige verificatiecode';
            _isLoading = false;
          });
        }
        return;
      }
      
      if (!context.mounted) return;
      // After successful verification, route appropriately
      await _routeAfterLogin(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Fout bij verificatie: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _backToEmailInput() {
    setState(() {
      _showCodeInput = false;
      _codeController.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo
                SizedBox(
                  width: 120,
                  height: 120,
                  child: SvgPicture.asset(
                    'assets/logo-wildlife.svg',
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  'Welkom bij WildRapport',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Een app van WildLifeNL',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Login Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_showCodeInput) ...[
                          // Email Input Form
                          Text(
                            'Voer uw e-mailadres in',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'E-mailadres',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF999999),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD0D0D0),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Lottie.asset(
                                        AppIconPaths.loadingPaw,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : Text(
                                      'Aanmelden',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const LoginOverlay(),
                                );
                              },
                              child: Text(
                                'Hoe werkt de registratie?',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 103, 103, 103),
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Code Verification Form
                          Text(
                            'Voer verificatiecode in',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Wij hebben een code naar $_currentEmail verzonden',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _codeController,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '123456',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF999999),
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD0D0D0),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryGreen,
                                  width: 1.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: const TextStyle(fontSize: 24, letterSpacing: 8),
                          ),
                          const SizedBox(height: 16),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleVerifyCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Lottie.asset(
                                        AppIconPaths.loadingPaw,
                                        fit: BoxFit.contain,
                                      ),
                                    )
                                  : Text(
                                      'Verifieer',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: _isLoading ? null : _backToEmailInput,
                              child: Text(
                                'Terug naar e-mail',
                                style: TextStyle(
                                  color: AppColors.primaryGreen,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
