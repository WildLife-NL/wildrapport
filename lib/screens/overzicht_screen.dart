import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/managers/screen_state_manager.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/widgets/rapporteren.dart';

class OverzichtScreen extends StatefulWidget {
  const OverzichtScreen({super.key});

  @override
  State<OverzichtScreen> createState() => _OverzichtScreenState();
}

class _OverzichtScreenState extends ScreenStateManager<OverzichtScreen> {
  String userName = 'John Doe';
  final double topContainerHeight = 260.0; // Reduced from 300 to 285 (15px less)
  final double welcomeFontSize = 20.0;
  final double usernameFontSize = 24.0;
  final double logoWidth = 180.0;
  final double logoHeight = 180.0;

  @override
  String get screenName => 'OverzichtScreen';

  @override
  Map<String, dynamic> getInitialState() => {
    'userName': 'John Doe',
  };

  @override
  void updateState(String key, dynamic value) {
    switch (key) {
      case 'userName':
        userName = value as String;
        break;
    }
  }

  @override
  Map<String, dynamic> getCurrentState() => {
    'userName': userName,
  };

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        context.read<AppStateProvider>()
            .setScreenState('OverzichtScreen', 'userName', userName);
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final availableWidth = constraints.maxWidth;
              
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: availableHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Top green container
                        Container(
                          height: topContainerHeight,
                          width: double.infinity,  // This ensures full width
                          decoration: BoxDecoration(
                            color: AppColors.darkGreen,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(75),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: availableWidth * 0.05,
                                  top: topContainerHeight * 0.15,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welkom Bij Wild Rapport',
                                      style: TextStyle(
                                        color: AppColors.offWhite,
                                        fontSize: welcomeFontSize,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.25),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: topContainerHeight * 0.03),
                                    Text(
                                      userName,
                                      style: TextStyle(
                                        color: AppColors.offWhite,
                                        fontSize: usernameFontSize,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.25),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 15,
                                right: 0,
                                left: 0,
                                child: Center(
                                  child: Image.asset(
                                    'assets/LogoWildlifeNL.png',
                                    width: availableWidth * 0.7,  // Increased from 0.5 to 0.7
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Buttons section
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: availableWidth * 0.05,
                              vertical: availableHeight * 0.02,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                WhiteBulkButton(
                                  text: 'RapportenKaart',
                                  leftWidget: Image.asset(
                                    'assets/icons/marked_earth.png',
                                    width: availableWidth * 0.12,
                                    height: availableWidth * 0.12,
                                  ),
                                  rightWidget: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                    size: availableWidth * 0.05,
                                  ),
                                ),
                                WhiteBulkButton(
                                  text: 'Rapporteren',
                                  leftWidget: Image.asset(
                                    'assets/icons/report.png',
                                    width: availableWidth * 0.12,
                                    height: availableWidth * 0.12,
                                  ),
                                  rightWidget: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                    size: availableWidth * 0.05,
                                  ),
                                  onPressed: () {
                                    context.read<AppStateProvider>()
                                        .setScreenState('OverzichtScreen', 'userName', userName);
                                    
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Rapporteren(),
                                      ),
                                    );
                                  },
                                ),
                                WhiteBulkButton(
                                  text: 'Mijn Rapporten',
                                  leftWidget: Image.asset(
                                    'assets/icons/my_report.png',
                                    width: availableWidth * 0.12,
                                    height: availableWidth * 0.12,
                                  ),
                                  rightWidget: Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.black54,
                                    size: availableWidth * 0.05,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}



















