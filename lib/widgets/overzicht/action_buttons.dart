import 'package:flutter/material.dart';
import 'package:wildrapport/constants/button_layout.dart';
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
    this.buttonHeight = 56,
    this.buttonFontSize,
    this.customIconColors = const {},
    this.useCircleIconsForIndices = const {},
  });

  @override
  Widget build(BuildContext context) {
    final height = buttonHeight >= kMinTouchTargetHeight
        ? buttonHeight
        : menuButtonHeight(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? contentHorizontalPadding(context),
        vertical: verticalPadding ?? 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var button in buttons) ...[
            SizedBox(
              height: height,
              width: double.infinity,
              child: _buildButton(
                context: context,
                height: height,
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
    required BuildContext context,
    required double height,
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

    final effectiveHeight = height.clamp(kMinTouchTargetHeight, 72.0);
    final button = SimpleHoverButton(
      key: key,
      text: text,
      onPressed: onPressed,
      height: effectiveHeight,
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
