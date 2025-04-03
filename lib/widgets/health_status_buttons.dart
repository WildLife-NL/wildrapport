import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/brown_button.dart' as brown_button;
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

class HealthStatusButtons extends StatelessWidget {
  final Function(String) onStatusSelected;
  final String title;

  const HealthStatusButtons({
    super.key,
    required this.onStatusSelected,
    this.title = 'Title', // Default value
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate responsive text size
    final double fontSize = screenSize.width * 0.06; // 6% of width
    final double minFontSize = 20.0;
    final double maxFontSize = 28.0;
    final double finalFontSize = fontSize.clamp(minFontSize, maxFontSize);
    
    // Calculate responsive icon size
    final double iconSize = screenSize.width * 0.05; // 5% of width
    final double minIconSize = 18.0;
    final double maxIconSize = 24.0;
    final double finalIconSize = iconSize.clamp(minIconSize, maxIconSize);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.brown,
                fontSize: finalFontSize,
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
            _buildButton('Andere', finalIconSize, Icons.help_outline), // Question mark for "Other"
            _buildButton('Dood', finalIconSize, Icons.dangerous), // Dangerous icon for "Dead"
            _buildButton('Ziek', finalIconSize, Icons.sick), // Sick icon for "Sick"
            _buildButton('Gezond', finalIconSize, Icons.favorite), // Heart icon for "Healthy"
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, double iconSize, IconData leftIcon) {
    return WhiteBulkButton(
      text: text,
      leftWidget: CircleIconContainer(
        icon: leftIcon,
        iconColor: AppColors.brown,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        size: 70.0,
        iconSize: 57.0,
      ),
      rightWidget: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.brown,
        size: 32.0,  // Increased from iconSize to a fixed larger size
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      onPressed: () => onStatusSelected(text),
    );
  }
}












