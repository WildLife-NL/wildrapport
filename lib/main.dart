import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/data_managers/belonging_api.dart';
import 'package:wildrapport/data_managers/response_api.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/data_managers/interaction_api.dart';
import 'package:wildrapport/data_managers/profile_api.dart';
import 'package:wildrapport/data_managers/questionaire_api.dart';
import 'package:wildrapport/data_managers/species_api.dart';
import 'package:wildrapport/data_managers/tracking_api.dart';
import 'package:wildrapport/data_managers/vicinity_api.dart';
import 'package:wildrapport/managers/api_managers/tracking_cache_manager.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_interface.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/data_apis/belonging_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/interaction_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/species_api_interface.dart';
import 'package:wildrapport/interfaces/filters/dropdown_interface.dart';
import 'package:wildrapport/interfaces/filters/filter_interface.dart';
import 'package:wildrapport/interfaces/reporting/interaction_interface.dart';
import 'package:wildrapport/interfaces/location/location_screen_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/other/overzicht_interface.dart';
import 'package:wildrapport/interfaces/other/permission_interface.dart';
import 'package:wildrapport/interfaces/reporting/belonging_damage_report_interface.dart';
import 'package:wildrapport/interfaces/reporting/questionnaire_interface.dart';
import 'package:wildrapport/interfaces/reporting/response_interface.dart';
import 'package:wildrapport/interfaces/data_apis/response_api_interface.dart';
import 'package:wildrapport/managers/waarneming_flow/animal_manager.dart';
import 'package:wildrapport/managers/waarneming_flow/animal_sighting_reporting_manager.dart';
import 'package:wildrapport/managers/api_managers/interaction_manager.dart';
import 'package:wildrapport/managers/api_managers/response_manager.dart';
import 'package:wildrapport/managers/filtering_system/dropdown_manager.dart';
import 'package:wildrapport/managers/map/location_screen_manager.dart';
import 'package:wildrapport/managers/state_managers/navigation_state_manager.dart';
import 'package:wildrapport/managers/other/overzicht_manager.dart';
import 'package:wildrapport/managers/permission/permission_manager.dart';
import 'package:wildrapport/managers/belonging_damage_report_flow/belonging_damage_report_manager.dart';
import 'package:wildrapport/managers/other/questionnaire_manager.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/sighting_report_activities.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/managers/filtering_system/filter_manager.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/belonging_damage_report_provider.dart';
import 'package:wildrapport/providers/response_provider.dart';
import 'package:wildrapport/screens/login/login_screen.dart';
import 'package:wildrapport/screens/shared/main_nav_screen.dart';
import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';

import 'package:wildrapport/data_managers/interaction_types_api.dart';
import 'package:wildrapport/managers/api_managers/interaction_types_manager.dart';

import 'package:wildrapport/providers/conveyance_provider.dart';
import 'package:wildrapport/data_managers/conveyance_api.dart';
import 'package:wildrapport/data_managers/contact_api.dart';
import 'package:wildrapport/services/contact_tracing_monitor.dart';
import 'package:wildrapport/services/contact_tracing_coordinator.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:wildrapport/firebase_options.dart';
import 'package:wildrapport/services/fcm_message_handler.dart';
import 'package:wildrapport/services/push_notification_coordinator.dart';
import 'package:wildrapport/services/alarm_map_focus_service.dart';
import 'package:wildrapport/services/notification_navigation_handler.dart';
import 'package:wildrapport/utils/notification_service.dart';
import 'package:wildrapport/screens/login/access_denied_screen.dart';
import 'package:wildrapport/data_managers/my_interaction_api.dart';
import 'package:wildrapport/utils/access_scope_utils.dart';
import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';
import 'package:wildlifenl_authenticator_components/wildlifenl_authenticator_components.dart';
import 'package:wildlifenl_interaction_components/wildlifenl_interaction_components.dart';
import 'package:wildlifenl_login_components/wildlifenl_login_components.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hide system navigation bar (Samsung/Android back, home, recent) app-wide
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final authenticator = WildLifeNLAuthenticator();
  final appStateProvider = AppStateProvider(authenticator: authenticator);
  final prefs = await SharedPreferences.getInstance();
  final permissionManager = PermissionManager();

  // Load location tracking preference
  await appStateProvider.loadLocationTrackingPreference();
  await appStateProvider.loadNotificationsPreference();

  await dotenv.load(fileName: ".env");

  final baseUrl = (dotenv.env['DEV_BASE_URL'] ?? '').trim();
  if (baseUrl.isEmpty) {
    throw Exception(
      'DEV_BASE_URL ontbreekt in .env. Voeg toe: DEV_BASE_URL=https://jouw-api-url',
    );
  }

  // Firebase + FCM background handler (must be registered before runApp).
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    attachFirebaseMessageListeners();
  } catch (e) {
    debugPrint('[main] Firebase init skipped: $e');
  }

  // Initialize local notifications + alarm tap → AlarmsScreen
  NotificationNavigationHandler.bind(
    navigatorKey: appStateProvider.navigatorKey,
    authenticator: authenticator,
  );
  NotificationNavigationHandler.installTapHandler();
  await NotificationService.instance.init();
  await NotificationNavigationHandler.processColdStart();

  final apiClient = ApiClient(baseUrl);
  final appConfig = AppConfig(apiClient);
  await SightingReportActivityCatalog.preload(apiClient);

  final profileApi = ProfileApi(apiClient);
  final speciesApi = SpeciesApi(apiClient);
  final interactionApi = InteractionApi(apiClient);
  final questionnaireAPI = QuestionaireApi(apiClient);
  final responseAPI = ResponseApi(apiClient);
  final belongingApi = BelongingApi(apiClient);
  final vicinityApi = VicinityApi(apiClient);

  final loginApiClient = HttpLoginApiClient(
    baseUrl: baseUrl,
    displayNameApp: 'WildRapport',
  );
  final loginService = DefaultLoginService(loginApiClient, displayNameApp: 'WildRapport');
  final interactionReadApi = HttpInteractionReadApi(baseUrl: baseUrl);
  final myInteractionApi = MyInteractionApi(interactionReadApi);
  final filterManager = FilterManager();
  final animalManager = AnimalManager(speciesApi, filterManager);
  final belongingDamageFormProvider = BelongingDamageReportProvider();
  final mapProvider = MapProvider();
  final alarmMapFocusService = AlarmMapFocusService();
  mapProvider.setAppStateProvider(appStateProvider);
  final responseProvider = ResponseProvider();

  final conveyanceApi = ConveyanceApi(apiClient);
  final conveyanceProvider = ConveyanceProvider(conveyanceApi);
  final contactApi = ContactApi(apiClient);
  final contactTracingMonitor = ContactTracingMonitor(contactApi);
  final contactTracingCoordinator = ContactTracingCoordinator(
    contactApi: contactApi,
    monitor: contactTracingMonitor,
  );
  final zoneApi = ZoneApi(
    baseUrl: baseUrl,
    getToken: () async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('bearer_token');
    },
  );

  // Interaction types: fetch/display names for UI
  final interactionTypesApi = InteractionTypesApi(apiClient);
  final interactionTypesManager = InteractionTypesManager(interactionTypesApi);

  final trackingApi = TrackingApi(apiClient);
  mapProvider.setTrackingApi(trackingApi);
  mapProvider.setVicinityApi(vicinityApi);
  final trackingCacheManager = TrackingCacheManager(trackingApi: trackingApi);
  trackingCacheManager.init();
  mapProvider.setTrackingCacheManager(trackingCacheManager);

  final interactionManager = InteractionManager(interactionAPI: interactionApi);
  interactionManager.init();

  final responseManager = ResponseManager(
    responseAPI: responseAPI,
    responseProvider: responseProvider,
  );
  responseManager.init();

  final belongingManager = BelongingDamageReportManager(
    interactionAPI: interactionApi,
    belongingAPI: belongingApi,
    formProvider: belongingDamageFormProvider,
    mapProvider: mapProvider,
    interactionManager: interactionManager,
  );
  await belongingManager.init();

  final questionnaireManager = QuestionnaireManager(questionnaireAPI);

  final animalSightingReportingManager = AnimalSightingReportingManager();

  final locationScreenManager = LocationScreenManager();

  prefs.setStringList('interaction_cache', []);

    // Check if dev mode is enabled
    final bool isDevMode = (dotenv.env['DEV_MODE'] ?? 'false').toLowerCase() == 'true';
    
    late final Widget initialScreen;
    if (isDevMode) {
      // Skip authentication in dev mode and go directly to main screen
      initialScreen = const MainNavScreen();
    } else {
      final bool hasValidToken = await authenticator.hasValidToken();
      final bool hasAccess = await authenticator.hasAccess();
      bool hasScopeAccess = false;
      if (hasValidToken && hasAccess) {
        final scopeAccess = await AccessScopeUtils.checkAuthorizeScopes(apiClient);
        hasScopeAccess = scopeAccess.checked ? scopeAccess.hasRequiredScope : hasAccess;
      }
      initialScreen = hasValidToken
        ? ((hasAccess && hasScopeAccess)
            ? const MainNavScreen()
            : const AccessDeniedScreen())
        : const LoginScreen();

      if (hasValidToken &&
          hasAccess &&
          hasScopeAccess &&
          appStateProvider.notificationsEnabled) {
        try {
          await PushNotificationCoordinator.instance.syncAfterLogin(
            profileApi: profileApi,
            requestPermission: false,
          );
        } catch (e) {
          debugPrint('[main] FCM sync on cold start failed: $e');
        }
      }
    }

  runApp(
    MultiProvider(
      providers: [
        Provider<WildLifeNLAuthenticator>.value(value: authenticator),
        ChangeNotifierProvider<AppStateProvider>.value(value: appStateProvider),
        ChangeNotifierProvider<BelongingDamageReportProvider>.value(
          value: belongingDamageFormProvider,
        ),
        ChangeNotifierProvider<MapProvider>.value(value: mapProvider),
        ChangeNotifierProvider<AlarmMapFocusService>.value(
          value: alarmMapFocusService,
        ),
        ChangeNotifierProvider<ResponseProvider>.value(value: responseProvider),
        ChangeNotifierProvider<ConveyanceProvider>.value(
          value: conveyanceProvider,
        ),
        Provider<ContactApi>.value(value: contactApi),
        ChangeNotifierProvider<ContactTracingMonitor>.value(
          value: contactTracingMonitor,
        ),
        ChangeNotifierProvider<ContactTracingCoordinator>.value(
          value: contactTracingCoordinator,
        ),
        Provider<ZoneApi>.value(value: zoneApi),
        Provider<AppConfig>.value(value: appConfig),
        Provider<ApiClient>.value(value: apiClient),
        Provider<ProfileApiInterface>.value(value: profileApi),
        Provider<SpeciesApiInterface>.value(value: speciesApi),
        Provider<InteractionApiInterface>.value(value: interactionApi),
        Provider<BelongingApiInterface>.value(value: belongingApi),
        Provider<InteractionInterface>.value(value: interactionManager),
        Provider<InteractionTypesManager>.value(value: interactionTypesManager),
        Provider<InteractionReadApiInterface>.value(value: interactionReadApi),
        Provider<MyInteractionApi>.value(value: myInteractionApi),
        Provider<LoginInterface>.value(value: loginService),
        Provider<AnimalRepositoryInterface>.value(value: animalManager),
        Provider<AnimalManagerInterface>.value(value: animalManager),
        Provider<FilterInterface>.value(value: filterManager),
        Provider<OverzichtInterface>.value(value: OverzichtManager()),
        Provider<BelongingDamageReportInterface>.value(value: belongingManager),
        Provider<ResponseInterface>.value(value: responseManager),
        Provider<ResponseApiInterface>.value(value: responseAPI),
        Provider<DropdownInterface>.value(
          value: DropdownManager(filterManager),
        ),
        Provider<QuestionnaireInterface>.value(value: questionnaireManager),
        Provider<ResponseManager>.value(value: responseManager),
        Provider<AnimalSightingReportingInterface>(
          create: (context) => animalSightingReportingManager,
        ),
        Provider<NavigationStateInterface>(
          create: (context) => NavigationStateManager(),
        ),
        Provider<LocationScreenInterface>(create: (_) => locationScreenManager),
        Provider<PermissionInterface>(create: (_) => permissionManager),
      ],
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class UserService {}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return _MediaQueryWrapper(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: context.read<AppStateProvider>().navigatorKey,
        title: 'WildRapport',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.lightMintGreen,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.darkGreen,
            surface: AppColors.lightMintGreen,
          ),
          textTheme: AppTextTheme.textTheme,
          fontFamily: 'Roboto',
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.offWhite,
            behavior: SnackBarBehavior.floating,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.mediumGrey),
            ),
            contentTextStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Roboto',
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
        home: initialScreen,
      ),
    );
  }
}

class _MediaQueryWrapper extends StatelessWidget {
  final Widget child;

  const _MediaQueryWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final baseTextScale = (screenSize.width / 375).clamp(0.8, 1.2);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          baseTextScale *
              MediaQuery.textScalerOf(context).scale(1.0).clamp(0.8, 1.4),
        ),
      ),
      child: child,
    );
  }
}
