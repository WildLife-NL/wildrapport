import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/constants/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final List<({String text, IconData icon, VoidCallback? onPressed})> buttons;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? buttonSpacing;
  final bool useCircleIcons;
  final double iconSize;
  final double buttonHeight; // Added this property

  const ActionButtons({
    super.key,
    required this.buttons,
    this.verticalPadding,
    this.horizontalPadding,
    this.buttonSpacing,
    this.useCircleIcons = true,
    this.iconSize = 48,
    this.buttonHeight = 160, // Added with default value
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? MediaQuery.of(context).size.width * 0.05,
          vertical: verticalPadding ?? 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Changed from start to center
          children: [
            for (var button in buttons) ...[
              SizedBox(
                height: buttonHeight,
                child: _buildButton(
                  text: button.text,
                  icon: button.icon,
                  onPressed: button.onPressed,
                ),
              ),
              if (button != buttons.last)
                SizedBox(height: buttonSpacing ?? 0), // Ensure spacing is 0 when null
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return WhiteBulkButton(
      text: text,
      leftWidget: useCircleIcons 
          ? CircleIconContainer(
              icon: icon,
              iconColor: AppColors.brown,
              size: iconSize,
            )
          : Icon(
              icon,
              color: AppColors.brown,
              size: iconSize,
            ),
      rightWidget: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.black54,
      ),
      onPressed: onPressed,
    );
  }
}







