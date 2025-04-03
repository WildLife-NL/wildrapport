import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';

class CustomBottomAppBar extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onNextPressed;

  const CustomBottomAppBar({
    super.key,
    required this.onBackPressed,
    required this.onNextPressed,
  });

  void _handleBackPress() {
    debugPrint('CustomBottomAppBar: Back button pressed');
  }

  void _handleNextPress() {
    debugPrint('CustomBottomAppBar: Next button pressed');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Increased size values
    final double barHeight = screenSize.height * 0.1; // Increased from 0.08
    final double minHeight = 80.0; // Increased from 60.0
    final double maxHeight = 100.0; // Increased from 80.0
    
    // Increased font and icon sizes
    final double fontSize = screenSize.width * 0.05; // Increased from 0.04
    final double minFontSize = 18.0; // Increased from 14.0
    final double maxFontSize = 24.0; // Increased from 18.0
    
    final double iconSize = screenSize.width * 0.08; // Increased from 0.06
    final double minIconSize = 28.0; // Increased from 20.0
    final double maxIconSize = 36.0; // Increased from 28.0
    
    final double finalHeight = barHeight.clamp(minHeight, maxHeight);
    final double finalFontSize = fontSize.clamp(minFontSize, maxFontSize);
    final double finalIconSize = iconSize.clamp(minIconSize, maxIconSize);
    final double horizontalPadding = screenSize.width * 0.06; // Increased from 0.04

    return Container(
      height: finalHeight,
      // Removed decoration to make background transparent
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: _handleBackPress,
              child: Padding(
                padding: EdgeInsets.only(left: horizontalPadding),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.brown,
                      size: finalIconSize,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    SizedBox(width: screenSize.width * 0.03), // Increased from 0.02
                    Text(
                      'Terug',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontSize: finalFontSize,
                        fontWeight: FontWeight.w600, // Increased from w500
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
            ),
            
            // Next button
            GestureDetector(
              onTap: _handleNextPress,
              child: Padding(
                padding: EdgeInsets.only(right: horizontalPadding),
                child: Row(
                  children: [
                    Text(
                      'Volgende',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontSize: finalFontSize,
                        fontWeight: FontWeight.w600, // Increased from w500
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.03), // Increased from 0.02
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.brown,
                      size: finalIconSize,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





