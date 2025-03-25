import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/asset_preloader.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback? onLoadingComplete;
  
  const LoadingScreen({
    super.key,
    this.onLoadingComplete,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initializeApp();
    }
  }

  Future<void> _initializeApp() async {
    // Create two futures: one for asset preloading and one for the minimum duration
    final Future<void> assetsFuture = AssetPreloader.precacheAllAssets(context);
    final Future<void> timerFuture = Future.delayed(const Duration(seconds: 2));
    
    // Wait for both futures to complete
    await Future.wait([assetsFuture, timerFuture]);
    
    if (mounted && widget.onLoadingComplete != null) {
      widget.onLoadingComplete!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/loaders/loading_paw.json',
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                frameRate: FrameRate(60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





