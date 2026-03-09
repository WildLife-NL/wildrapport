import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/overzicht/simple_hover_button.dart';
import 'package:wildrapport/constants/app_colors.dart';

class ActionButtons extends StatelessWidget {
  final List<
    ({
      String text,
      IconData? icon,
      String? imagePath,
      VoidCallback? onPressed,
      Key? key,
    })
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
        horizontal: horizontalPadding ?? 8,
        vertical: verticalPadding ?? 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var button in buttons) ...[
            SizedBox(
              height: buttonHeight,
              width: double.infinity,
              child: _buildButton(
                text: button.text,
                icon: button.icon,
                imagePath: button.imagePath,
                onPressed: button.onPressed,
                key: button.key,
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
    Key? key,
  }) {
    Color background = AppColors.lightMintGreen;
    Color? border = AppColors.darkGreen;
    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: buttonFontSize ?? 16,
      fontWeight: FontWeight.w500,
    );

    final button = SimpleHoverButton(
      key: key,
      text: text,
      onPressed: onPressed,
      height: buttonHeight.clamp(40.0, 64.0),
      textStyle: textStyle,
      backgroundColor: background,
      borderColor: border,
      width: double.infinity,
    );

    if (text == 'Uitloggen' || text.toLowerCase().contains('uitlog')) {
      return Visibility(
        visible: false,
        maintainState: true,
        maintainAnimation: true,
        maintainSemantics: true,
        maintainSize: true,
        child: button,
      );
    }

    return button;
  }
}
