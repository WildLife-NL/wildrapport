import 'package:flutter/material.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/constants/app_colors.dart';

class CompactAnimalDisplay extends StatelessWidget {
  final AnimalModel animal;
  final double? height;

  const CompactAnimalDisplay({
    super.key,
    required this.animal,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    // Calculate responsive dimensions
    final double calculatedHeight = height ?? screenSize.height * 0.15; // 15% of screen height
    final double minHeight = 100.0;
    final double maxHeight = 150.0;
    final double finalHeight = calculatedHeight.clamp(minHeight, maxHeight);
    
    // Calculate responsive text size
    final double fontSize = screenSize.width * 0.04; // 4% of screen width
    final double minFontSize = 14.0;
    final double maxFontSize = 18.0;
    final double finalFontSize = fontSize.clamp(minFontSize, maxFontSize);
    
    // Calculate responsive padding
    final double paddingSize = screenSize.width * 0.02; // 2% of screen width
    final double minPadding = 8.0;
    final double maxPadding = 16.0;
    final double finalPadding = paddingSize.clamp(minPadding, maxPadding);

    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(finalPadding),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: finalPadding / 3,
              offset: Offset(0, finalPadding / 6),
            ),
          ],
        ),
        padding: EdgeInsets.all(finalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(finalPadding),
              child: animal.animalImagePath != null
                  ? Image.asset(
                      animal.animalImagePath!,
                      height: finalHeight,
                      fit: BoxFit.contain,
                    )
                  : SizedBox(
                      height: finalHeight,
                      width: finalHeight,
                      child: Icon(
                        Icons.help_outline,
                        color: AppColors.brown,
                        size: finalHeight * 0.3, // Responsive icon size
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(top: finalPadding * 0.75),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  animal.animalName,
                  style: TextStyle(
                    color: AppColors.brown,
                    fontSize: finalFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}








