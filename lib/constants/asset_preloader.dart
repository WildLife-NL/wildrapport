import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_icon_paths.dart';
import 'package:wildlifenl_assets/wildlifenl_assets.dart';

class AssetPreloader {
  static Future<void> precacheAllAssets(BuildContext context) async {
    final List<Future<void>> precacheFutures = [];

    final List<String> assets = [
      // Icons (dieren + app) uit wildlifenl_assets (git)
      ...getAllAnimalAssetPaths(),
      ...getAllAppIconPaths(),
      // App-assets
      AppIconPaths.logoWildlifeNL,
      AppIconPaths.iconLocation,
      AppIconPaths.appLogo,
      AppIconPaths.gifLogin,
      AppIconPaths.gifThankyou,
    ];

    // Alleen image-assets precachen (AssetImage; .json zoals Lottie niet)
    for (final String asset in assets) {
      if (asset.endsWith('.json')) continue;
      final provider = AssetImage(asset);
      precacheFutures.add(
        precacheImage(provider, context).catchError((error) {
          debugPrint('Failed to load asset: $asset');
          return null;
        }),
      );
    }

    // Wait for all images to be cached
    await Future.wait(precacheFutures);
  }
}
