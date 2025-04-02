import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/login_screen.dart';
import 'package:wildrapport/screens/loading_screen.dart';
import 'package:wildrapport/widgets/category_filter_options.dart';
import 'package:wildrapport/managers/filter_manager.dart';
import 'package:wildrapport/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  // Create instances of services
  final animalService = AnimalManager();
  final filterManager = FilterManager();
  
  await dotenv.load(fileName: ".env");
  AppConfig.create();
  
  String? token = await _getToken();

  if(token != null && token != ""){
    debugPrint("Token already stored locally: $token");
  }
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AnimalRepositoryInterface>(create: (_) => animalService),
        Provider<FilterInterface>.value(value: filterManager),
      ],
      child: const MyApp(),
    ),
  );
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
      ),
      home: _isLoading 
        ? LoadingScreen(
            onLoadingComplete: () {
              setState(() {
                _isLoading = false;
              });
            },
          )
        : const LoginScreen(), // Changed from TestScreen back to LoginScreen
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


