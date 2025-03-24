import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';

class OverzichtScreen extends StatelessWidget {
  const OverzichtScreen({super.key});

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
                          'John Doe',
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
                    rightWidget: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                    ),
                  ),
                  WhiteBulkButton(
                    text: 'Rapporteren',
                    rightWidget: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                    ),
                  ),
                  WhiteBulkButton(
                    text: 'Mijn Rapporten',
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

