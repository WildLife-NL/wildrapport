import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/services/dropdown_service.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

class CategoryFilterOptions extends StatelessWidget {
  final List<Map<String, String>> items;
  final Function(String) onCategorySelected;

  const CategoryFilterOptions({
    Key? key,
    required this.items,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
          mainAxisSpacing: 16,
          crossAxisSpacing: 8,
          childAspectRatio: 0.75, // Make cells even taller
          children: items.map((item) => LayoutBuilder(
            builder: (context, constraints) {
              final circleSize = constraints.maxWidth * 1.0;
              return GestureDetector(
                onTap: () => onCategorySelected(item['text']!),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleIconContainer(
                      size: circleSize,
                      backgroundColor: AppColors.brown,
                      imagePath: item['icon'],
                      iconColor: Colors.white,
                      iconSize: circleSize * 0.8, // Increased from default 0.5 to 0.7
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Text(
                        item['text']!,
                        style: const TextStyle(
                          color: AppColors.brown,
                          fontSize: 14, // Bigger text
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          )).toList(),
        ),
        
        // Back button
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: GestureDetector(
              onTap: () => onCategorySelected('Resetten'), // Changed to use 'Resetten' like the reset button
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: AppColors.brown,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Terug',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


