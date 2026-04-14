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
    ProfileApiInterface profileApi;
    try {
      profileApi = context.read<ProfileApiInterface>();
    } catch (_) {
      profileApi = ProfileApi(AppConfig.shared.apiClient);
    }
    await profileApi.setProfileDataInDeviceStorage();
    if (!context.mounted) return;
    final profile = await profileApi.fetchMyProfile();
    if (!context.mounted) return;
    final hasAccess = await context.read<WildLifeNLAuthenticator>().hasAccess();
    final scopeAccess = await AccessScopeUtils.checkAuthorizeScopes(
      AppConfig.shared.apiClient,
    );
    final hasScopeAccess =
        scopeAccess.checked ? scopeAccess.hasRequiredScope : hasAccess;
    if (!hasAccess || !hasScopeAccess) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AccessDeniedScreen()),
        (_) => false,
      );
      return;
    }
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
    if (!context.mounted) return;
    final hasAccess = await context.read<WildLifeNLAuthenticator>().hasAccess();
    final scopeAccess = await AccessScopeUtils.checkAuthorizeScopes(
      AppConfig.shared.apiClient,
    );
    final hasScopeAccess =
        scopeAccess.checked ? scopeAccess.hasRequiredScope : hasAccess;
    if (hasAccess && hasScopeAccess) {
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
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
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
      // Get authenticator and attempt login
      final authenticator = context.read<WildLifeNLAuthenticator>();
      // The authenticator might have a login method - adjust as needed
      // For now, we'll just proceed with the normal flow
      await _routeAfterLogin(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Login mislukt: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                const SizedBox(height: 70),
                // Logo
                SizedBox(
                  width: 140,
                  height: 140,
                  child: SvgPicture.asset(
                    'assets/logo-wildlife.svg',
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                Text(
                  'Welkom bij WildRapport',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
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
                const SizedBox(height: 50),
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
                        // Prompt text
                        Text(
                          'Voer uw e-mailadres in',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Email input
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
                                color: Color(0xFFCCCCCC),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFCCCCCC),
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
                        // Error message
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
                        // Login button
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
                        // Help link
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // Handle registration help
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
