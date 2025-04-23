import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/widgets/app_bar.dart';

class MapScreen extends StatelessWidget {
  final Widget mapWidget;
  final String title;
  final VoidCallback? onBackPressed;

  const MapScreen({
    super.key,
    required this.mapWidget,
    this.title = 'Kaart',
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: title,
              rightIcon: Icons.menu,
              onLeftIconPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              onRightIconPressed: () {/* Handle menu */},
            ),
            Expanded(
              child: mapWidget,
            ),
          ],
        ),
      ),
    );
  }
}

