import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/api/answer_api.dart';
import 'package:wildrapport/api/api_client.dart';
import 'package:wildrapport/api/auth_api.dart';
import 'package:wildrapport/api/questionaire_api.dart';
import 'package:wildrapport/api/species_api.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/api/auth_api_interface.dart';
import 'package:wildrapport/interfaces/api/species_api_interface.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/interfaces/login_interface.dart';
import 'package:wildrapport/interfaces/overzicht_interface.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/managers/animal_sighting_reporting_manager.dart';
import 'package:wildrapport/managers/answer_manager.dart';
import 'package:wildrapport/managers/dropdown_manager.dart';
import 'package:wildrapport/managers/login_manager.dart';
import 'package:wildrapport/managers/overzicht_manager.dart';
import 'package:wildrapport/managers/questionnaire_manager.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/managers/filter_manager.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/screens/rapporteren.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  final apiClient = ApiClient(dotenv.get('DEV_BASE_URL'));
  final appConfig = AppConfig(apiClient);
  
  final authApi = AuthApi(apiClient);
  final speciesApi = SpeciesApi(apiClient);
  
  final questionnaireAPI = QuestionaireApi(apiClient);
  final answerAPI = AnswerApi(apiClient);    

  final loginManager = LoginManager(authApi);
  final filterManager = FilterManager();
  final animalManager = AnimalManager(speciesApi, filterManager);

  final questionnaireManager = QuestionnaireManager(questionnaireAPI);
  final answerManager = AnswerManager(answerAPI);
  
  final animalSightingReportingManager = AnimalSightingReportingManager();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: appConfig),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthApiInterface>.value(value: authApi),
        Provider<SpeciesApiInterface>.value(value: speciesApi),
        Provider<LoginInterface>.value(value: loginManager),
        Provider<AnimalRepositoryInterface>.value(value: animalManager),
        Provider<AnimalManagerInterface>.value(value: animalManager),
        Provider<FilterInterface>.value(value: filterManager),
        Provider<OverzichtInterface>.value(value: OverzichtManager()),
        Provider<DropdownInterface>.value(
          value: DropdownManager(filterManager),
        ),
        Provider<QuestionnaireInterface>.value(value: questionnaireManager),
        Provider<AnswerManager>.value(value: answerManager),
        Provider<AnimalSightingReportingInterface>(
          create: (context) => animalSightingReportingManager,
        ),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: const Rapporteren(),
    );
  }
}


// Separate widget for MediaQuery modifications
// ignore: unused_element
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


