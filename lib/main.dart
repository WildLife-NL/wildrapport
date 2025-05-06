import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/api/answer_api.dart';
import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/api/auth_api.dart';
import 'package:wildrapport/api/interaction_api.dart';
import 'package:wildrapport/api/profile_api.dart';
import 'package:wildrapport/api/questionaire_api.dart';
import 'package:wildrapport/api/species_api.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/api/auth_api_interface.dart';
import 'package:wildrapport/interfaces/api/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/api/species_api_interface.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/overzicht_interface.dart';
import 'package:wildrapport/interfaces/permission_interface.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/managers/animal_sighting_reporting_manager.dart';
import 'package:wildrapport/managers/answer_manager.dart';
import 'package:wildrapport/managers/dropdown_manager.dart';
import 'package:wildrapport/managers/map/location_screen_manager.dart';
import 'package:wildrapport/managers/login_manager.dart';
import 'package:wildrapport/managers/navigation_state_manager.dart';
import 'package:wildrapport/managers/overzicht_manager.dart';
import 'package:wildrapport/managers/permission_manager.dart';
import 'package:wildrapport/managers/possesion_manager.dart';
import 'package:wildrapport/managers/questionnaire_manager.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/managers/filter_manager.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/screens/login_screen.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';

Future<Widget> getHomepageBasedOnLoginStatus() async {
  String? token = await _getToken();
  if (token != null) {
    return OverzichtScreen();
  } else {
    return LoginScreen();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appStateProvider = AppStateProvider();
  final prefs = await SharedPreferences.getInstance();
  final permissionManager = PermissionManager(prefs);
  
  await dotenv.load(fileName: ".env");
  
  final apiClient = ApiClient(dotenv.get('DEV_BASE_URL'));
  final appConfig = AppConfig(apiClient);
  
  final authApi = AuthApi(apiClient);
  final profileApi = ProfileApi(apiClient);
  final speciesApi = SpeciesApi(apiClient);
  final interactionApi = InteractionApi(apiClient);

  final questionnaireAPI = QuestionaireApi(apiClient);
  final answerAPI = AnswerApi(apiClient);    

  final loginManager = LoginManager(authApi, profileApi);
  final filterManager = FilterManager();
  final animalManager = AnimalManager(speciesApi, filterManager);
  final possesionDamageFormProvider = PossesionDamageFormProvider();
  final mapProvider = MapProvider();
  final possesionManager = PossesionManager(interactionApi, possesionDamageFormProvider, mapProvider);

  final questionnaireManager = QuestionnaireManager(questionnaireAPI);
  final answerManager = AnswerManager(answerAPI);
  
  final animalSightingReportingManager = AnimalSightingReportingManager();
  
  final locationScreenManager = LocationScreenManager();
  

  // Check for existing token
  final String? token = prefs.getString('bearer_token');
  final Widget initialScreen = token != null ? const OverzichtScreen() : const LoginScreen();

  // Start the app
  runApp(
    MultiProvider(
      providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: appStateProvider),
          ChangeNotifierProvider<PossesionDamageFormProvider>.value(value: possesionDamageFormProvider),          
          ChangeNotifierProvider<MapProvider>.value(value: mapProvider),
        Provider<AppConfig>.value(value: appConfig),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthApiInterface>.value(value: authApi),
        Provider<SpeciesApiInterface>.value(value: speciesApi),
        Provider<InteractionApiInterface>.value(value: interactionApi),
        Provider<LoginInterface>.value(value: loginManager),
        Provider<AnimalRepositoryInterface>.value(value: animalManager),
        Provider<AnimalManagerInterface>.value(value: animalManager),
        Provider<FilterInterface>.value(value: filterManager),
        Provider<OverzichtInterface>.value(value: OverzichtManager()),
        Provider<PossesionInterface>.value(value: possesionManager),
        Provider<DropdownInterface>.value(
          value: DropdownManager(filterManager),
        ),
        Provider<QuestionnaireInterface>.value(value: questionnaireManager),
        Provider<AnswerManager>.value(value: answerManager),
        Provider<AnimalSightingReportingInterface>(
          create: (context) => animalSightingReportingManager,
        ),
        Provider<NavigationStateInterface>(
          create: (context) => NavigationStateManager(),
        ),
        Provider<LocationScreenInterface>(
          create: (_) => locationScreenManager,
        ),
        Provider<PermissionInterface>(
          create: (_) => permissionManager,
        ),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: MyApp(
        initialScreen: initialScreen,
        onAppStart: () async {
          // Check if we already have permission
          bool hasPermission = await permissionManager.isPermissionGranted(PermissionType.location);
          
          if (!hasPermission) {
            // Get the context after the app has started
            final context = appStateProvider.navigatorKey.currentContext;
            if (context != null) {
              hasPermission = await permissionManager.requestPermission(
                context,
                PermissionType.location,
                showRationale: true,
              );
            }
          }

          if (hasPermission) {
            await appStateProvider.updateLocationCache();
            appStateProvider.startLocationUpdates();
          } else {
            debugPrint('\x1B[31m[Main] Location permission denied\x1B[0m');
          }
        },
      ),
    ),
  );
}

class UserService {
}

Future<String?> _getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('bearer_token');
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  final Future<void> Function() onAppStart;
  
  const MyApp({
    super.key, 
    required this.initialScreen,
    required this.onAppStart,
  });

  @override
  Widget build(BuildContext context) {
    final appStateProvider = context.read<AppStateProvider>();
    
    // Call onAppStart after the app has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onAppStart();
    });
    
    return _MediaQueryWrapper(
      child: MaterialApp(
        navigatorKey: appStateProvider.navigatorKey,
        title: 'WildRapport',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.lightMintGreen,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.darkGreen,
            surface: AppColors.lightMintGreen,
          ),
          textTheme: AppTextTheme.textTheme,
          fontFamily: 'Arimo',
          snackBarTheme: const SnackBarThemeData(
            backgroundColor: AppColors.brown300,
            behavior: SnackBarBehavior.floating,
            contentTextStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'Arimo',
            ),
          ),
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.4),
              ),
            ),
            child: child!,
          );
        },
        home: FutureBuilder<Widget>(
          future: getHomepageBasedOnLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return const Scaffold(
                body: Center(child: Text('Something went wrong')),
              );
            } else {
              return snapshot.data!;
            }
          },
        ),
      ),
    );
  }
}


// Separate widget for MediaQuery modifications
class _MediaQueryWrapper extends StatelessWidget {
  final Widget child;

  const _MediaQueryWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate base text scale based on screen width
    final baseTextScale = (screenSize.width / 375).clamp(0.8, 1.2);
    
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        // Combine device text scale with our responsive scale
        textScaler: TextScaler.linear(
          baseTextScale * MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.4),
        ),
        viewInsets: MediaQuery.of(context).viewInsets.copyWith(
          bottom: MediaQuery.of(context).viewInsets.bottom * 0.8,
        ),
      ),
      child: child,
    );
  }
}
