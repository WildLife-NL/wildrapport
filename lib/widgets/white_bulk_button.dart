import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

class WhiteBulkButton extends StatelessWidget {
  final String text;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final VoidCallback? onPressed;
  final double height;

  const WhiteBulkButton({
    super.key,
    required this.text,
    this.leftWidget,
    this.rightWidget,
    this.onPressed,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          splashColor: AppColors.brown.withOpacity(0.1),
          highlightColor: AppColors.brown.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leftWidget != null) leftWidget! else const SizedBox(),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextTheme.textTheme.titleLarge?.copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                if (rightWidget != null)
                  rightWidget!
                else 
                  CircleIconContainer(
                    icon: Icons.arrow_forward_ios,
                    iconColor: AppColors.brown,
                    size: 48, // Increased from 38
                    iconSize: 28, // Increased from 20
                    backgroundColor: AppColors.offWhite,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




