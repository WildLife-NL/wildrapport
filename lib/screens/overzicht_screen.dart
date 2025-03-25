import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/mixins/ui_state_aware.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/widgets/rapporteren.dart';

class OverzichtScreen extends StatefulWidget {
  const OverzichtScreen({super.key});

  @override
  State<OverzichtScreen> createState() => _OverzichtScreenState();
}

class _OverzichtScreenState extends State<OverzichtScreen> 
    with WidgetsBindingObserver, UIStateAware<OverzichtScreen> {
  String userName = 'John Doe';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cacheUIState('userName', userName);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('OverzichtScreen - AppLifecycleState changed to: $state');
    if (state == AppLifecycleState.resumed) {
      final cachedUserName = getCachedUIState('userName');
      print('OverzichtScreen - Restored userName from cache: $cachedUserName');
      if (cachedUserName != null) {
        setState(() {
          userName = cachedUserName;
        });
      }
    } else if (state == AppLifecycleState.paused) {
      print('OverzichtScreen - Caching userName: $userName');
      cacheUIState('userName', userName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // This ensures full width
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity, // This ensures full width
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
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 60.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welkom Bij Wild Rapport',
                          style: TextStyle(
                            color: AppColors.offWhite,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userName, // Use the state variable instead of hardcoded value
                          style: TextStyle(
                            color: AppColors.offWhite,
                            fontSize: 24,
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
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Image.asset(
                        'assets/LogoWildlifeNL.png',
                        width: screenWidth * 0.7,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WhiteBulkButton(
                    text: 'RapportenKaart',
                    leftWidget: Image.asset(
                      'assets/icons/marked_earth.png',
                      width: 50,
                      height: 50,
                    ),
                    rightWidget: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                    ),
                  ),
                  WhiteBulkButton(
                    text: 'Rapporteren',
                    leftWidget: Image.asset(
                      'assets/icons/report.png',
                      width: 50,
                      height: 50,
                    ),
                    rightWidget: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                    ),
                    onPressed: () {
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
                      width: 50,
                      height: 50,
                    ),
                    rightWidget: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




