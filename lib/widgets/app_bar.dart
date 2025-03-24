import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';

class CustomAppBar extends StatelessWidget {
  final IconData? leftIcon;
  final String? centerText;
  final IconData? rightIcon;
  final VoidCallback? onLeftIconPressed;
  final VoidCallback? onRightIconPressed;

  const CustomAppBar({
    super.key,
    this.leftIcon,
    this.centerText,
    this.rightIcon,
    this.onLeftIconPressed,
    this.onRightIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      color: Colors.transparent,
      child: Row(
        children: [
          // Left section (1/4 of space)
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leftIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: GestureDetector(
                      onTap: onLeftIconPressed,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.brown,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Center text (2/4 of space)
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                centerText ?? '',
                style: const TextStyle(
                  color: AppColors.brown,
                  fontSize: 20,
                  fontFamily: 'Arimo',
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Right section (1/4 of space)
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (rightIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: onRightIconPressed,
                      child: Icon(
                        Icons.menu,
                        color: AppColors.brown,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}










