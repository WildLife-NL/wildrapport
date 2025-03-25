import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/login_screen.dart';
import 'package:wildrapport/services/ui_state_manager.dart';

void main() {
  runApp(const MyApp());

  // Handle window focus changes
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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final UIStateManager _uiStateManager = UIStateManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _uiStateManager.setWindowFocus(true);
    } else if (state == AppLifecycleState.paused) {
      _uiStateManager.setWindowFocus(false);
    }
  }

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
      home: const LoginScreen(),
    );
  }
}


