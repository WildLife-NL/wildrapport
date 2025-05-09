import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/counter_widget.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

class CountBar extends StatelessWidget {
  final String name;
  final IconData? rightIcon;
  final String? imagePath;
  final Function(String name, int count)? onCountChanged;
  final double iconSize;
  final double iconScale;
  final Color iconColor;

  const CountBar({
    super.key,
    required this.name,
    this.rightIcon,
    this.imagePath,
    this.onCountChanged,
    this.iconSize = 38.0,
    this.iconScale = 0.5,
    this.iconColor = AppColors.brown,
  }) : assert(
         rightIcon != null || imagePath != null,
         'Either rightIcon or imagePath must be provided',
       );

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final double fontSize = screenSize.width * 0.04;
    final double minFontSize = 14.0;
    final double maxFontSize = 18.0;
    final double finalFontSize = fontSize.clamp(minFontSize, maxFontSize);

    return Container(
      height: iconSize + 12, // Adjust container height based on icon size
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                name,
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: finalFontSize,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: AnimalCounter(name: name, onCountChanged: onCountChanged),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleIconContainer(
                  icon: rightIcon,
                  imagePath: imagePath,
                  iconColor: iconColor,
                  size: iconSize,
                  iconSize: iconSize * iconScale,
                  backgroundColor: AppColors.offWhite,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
