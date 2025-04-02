import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/api/auth_api.dart';
import 'package:wildrapport/api/species_api.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/api/auth_api_interface.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/interfaces/overzicht_interface.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/managers/dropdown_manager.dart';
import 'package:wildrapport/managers/login_manager.dart';
import 'package:wildrapport/managers/overzicht_manager.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/login_screen.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/screens/loading_screen.dart';
import 'package:wildrapport/widgets/category_filter_options.dart';
import 'package:wildrapport/managers/filter_manager.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  final apiClient = ApiClient(dotenv.get('DEV_BASE_URL'));
  final appConfig = AppConfig(apiClient);
  
  final authApi = AuthApi(apiClient);
  final speciesApi = SpeciesApi(apiClient);
  final userService = UserService();
  
  final loginManager = LoginManager(authApi);
  final animalManager = AnimalManager();
  final filterManager = FilterManager();
  final overzichtManager = OverzichtManager();
  final dropdownManager = DropdownManager(filterManager);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: appConfig),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthApiInterface>.value(value: authApi),
        Provider<LoginInterface>.value(value: loginManager),
        Provider<AnimalRepositoryInterface>.value(value: animalManager),
        Provider<AnimalManagerInterface>.value(value: animalManager),
        Provider<FilterInterface>.value(value: filterManager),
        Provider<OverzichtInterface>.value(value: overzichtManager),
        Provider<DropdownInterface>.value(value: dropdownManager),
      ],
      child: const MyApp(),
    ),
  );
}

class UserService {
}

Future<String?> _getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('bearer_token');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildRapport',
      builder: (context, child) {
        return _MediaQueryWrapper(child: child!);
      },
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
      home: _isLoading 
        ? LoadingScreen(
            onLoadingComplete: () {
              setState(() {
                _isLoading = false;
              });
            },
          )
        : const LoginScreen(), // Changed from OverzichtScreen to LoginScreen
    );
  }
}


// Separate widget for MediaQuery modifications
class _MediaQueryWrapper extends StatelessWidget {
  final Widget child;

  const _MediaQueryWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(1.0),
        viewInsets: MediaQuery.of(context).viewInsets.copyWith(
          bottom: MediaQuery.of(context).viewInsets.bottom * 0.8,
        ),
      ),
      child: child,
    );
  }
}


