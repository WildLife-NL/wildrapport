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

  const ActionButtons({
    super.key,
    required this.buttons,
    this.verticalPadding,
    this.horizontalPadding,
    this.buttonSpacing,
    this.useCircleIcons = true,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding ?? MediaQuery.of(context).size.width * 0.05,
          vertical: verticalPadding ?? MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var button in buttons) ...[
              _buildButton(
                text: button.text,
                icon: button.icon,
                onPressed: button.onPressed,
              ),
              if (button != buttons.last)
                SizedBox(height: buttonSpacing ?? MediaQuery.of(context).size.height * 0.02),
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




