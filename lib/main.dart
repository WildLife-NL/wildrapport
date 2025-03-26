import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/login_screen.dart';
import 'package:wildrapport/services/ui_state_manager.dart';
import 'package:wildrapport/screens/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  
  SystemChannels.lifecycle.setMessageHandler((msg) async {
    if (msg == AppLifecycleState.resumed.toString()) {
      UIStateManager().setWindowFocus(true);
    } else if (msg == AppLifecycleState.paused.toString()) {
      UIStateManager().setWindowFocus(false);
    }
    return null;
  });
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
        : const LoginScreen(),
    );
  }
}


