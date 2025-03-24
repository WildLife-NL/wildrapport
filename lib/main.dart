import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';

void main() {
  runApp(const MyApp());
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
      ),
      home: const OverzichtScreen(),
    );
  }
}


