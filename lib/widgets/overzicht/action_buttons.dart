import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';
import 'package:wildrapport/constants/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final List<
    ({String text, IconData? icon, String? imagePath, VoidCallback? onPressed})
  >
  buttons;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? buttonSpacing;
  final bool useCircleIcons;
  final double iconSize;
  final double buttonHeight;
  final double? buttonFontSize;
  final Map<int, Color> customIconColors;
  final Set<int> useCircleIconsForIndices;

  const ActionButtons({
    super.key,
    required this.buttons,
    this.verticalPadding,
    this.horizontalPadding,
    this.buttonSpacing,
    this.useCircleIcons = true,
    this.iconSize = 48,
    this.buttonHeight = 160,
    this.buttonFontSize,
    this.customIconColors = const {},
    this.useCircleIconsForIndices = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            horizontalPadding ?? 8, // <-- Only small margin on left/right
        vertical: verticalPadding ?? 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var button in buttons) ...[
            SizedBox(
              height: buttonHeight,
              width:
                  double.infinity, // <-- Force button to be as wide as possible
              child: _buildButton(
                text: button.text,
                icon: button.icon,
                imagePath: button.imagePath,
                onPressed: button.onPressed,
              ),
            ),
            if (button != buttons.last) SizedBox(height: buttonSpacing ?? 0),
          ],
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    IconData? icon,
    String? imagePath,
    VoidCallback? onPressed,
  }) {
    Widget? leftWidget;

    final int buttonIndex = buttons.indexWhere((b) => b.text == text);
    final Color iconColor = customIconColors[buttonIndex] ?? AppColors.brown;
    final bool useCircle = useCircleIconsForIndices.contains(buttonIndex);

    if (icon != null) {
      leftWidget =
          useCircle
              ? CircleIconContainer(
                icon: icon,
                iconColor: iconColor,
                size: iconSize,
              )
              : Icon(icon, color: iconColor, size: iconSize);
    } else if (imagePath != null) {
      leftWidget = Image.asset(
        imagePath,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      );
    }

    return WhiteBulkButton(
      text: text,
      leftWidget: leftWidget,
      rightWidget: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.brown,
        size: 24,
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      onPressed: onPressed,
      height: buttonHeight,
      fontSize: buttonFontSize,
      // No width passed here - WhiteBulkButton defaults to full width
    );
  }
}
