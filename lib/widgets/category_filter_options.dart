import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

class CategoryFilterOptions extends StatelessWidget {
  final List<Map<String, String>> items;
  final Function(String) onCategorySelected;

  const CategoryFilterOptions({
    super.key,
    required this.items,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive sizes
    final containerHeight = screenHeight * 0.25; // 25% of screen height
    final circleSize = screenWidth * 0.30; // 25% of screen width
    final iconSize = circleSize * 0.75; // 65% of circle size
    final fontSize = screenWidth * 0.04; // 4% of screen width

    // Add minimum and maximum constraints
    final constrainedCircleSize = circleSize.clamp(80.0, 120.0);
    final constrainedIconSize = iconSize.clamp(52.0, 80.0);
    final constrainedFontSize = fontSize.clamp(14.0, 16.0);
    final constrainedContainerHeight = containerHeight.clamp(160.0, 200.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: constrainedContainerHeight,
          width: double.infinity,
          child: Row(
            children: items.map((item) => Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01, // 1% of screen width
                ),
                child: GestureDetector(
                  onTap: () => onCategorySelected(item['text']!),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PhysicalModel(
                        color: Colors.transparent,
                        shadowColor: Colors.black.withOpacity(0.25),
                        elevation: 4,
                        shape: BoxShape.circle,
                        child: CircleIconContainer(
                          size: constrainedCircleSize,
                          backgroundColor: AppColors.brown,
                          imagePath: item['icon'],
                          iconSize: constrainedIconSize,
                        ),
                      ),
                      SizedBox(height: constrainedContainerHeight * 0.05),
                      Text(
                        item['text']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.brown,
                          fontSize: constrainedFontSize,
                          fontWeight: FontWeight.w500,
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
            )).toList(),
          ),
        );
      },
    );
  }
}


