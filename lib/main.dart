import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/login_screen.dart';
import 'package:wildrapport/screens/loading_screen.dart';
import 'package:wildrapport/widgets/category_filter_options.dart';
import 'package:wildrapport/managers/filter_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const MyApp(),
    ),
  );
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


