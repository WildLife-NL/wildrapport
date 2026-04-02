import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WildLifeNLLoginScreen(
      config: WildLifeNLLoginConfig(
        logoAssetPath: AppIconPaths.appLogo,
        appName: 'Wild Rapport',
        theme: LoginTheme(
          primaryColor: AppColors.darkGreen,
          accentColor: AppColors.brown,
          inputBackgroundColor: const Color(0xFFF1F5F2),
        ),
        onLoginSuccess: (ctx, _) => _routeAfterLogin(ctx),
        registrationInfoWidget: const LoginOverlay(),
        showErrorDialog: (ctx, messages) {
          showDialog(
            context: ctx,
            builder: (ctx) => ErrorOverlay(messages: messages),
          );
        },
        loadingWidget: Builder(
          builder: (ctx) {
            final size = MediaQuery.sizeOf(ctx);
            final s = size.width * 0.25;
            return SizedBox(
              width: s,
              height: s,
              child: Lottie.asset(
                AppIconPaths.loadingPaw,
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
