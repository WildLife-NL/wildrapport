import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/white_bulk_button.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class CustomBottomAppBar extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onNextPressed;
  final bool showNextButton;
  final bool showBackButton;

  const CustomBottomAppBar({
    super.key,
    this.onBackPressed,
    this.onNextPressed,
    this.showNextButton = true,
    this.showBackButton = true,
  });

  void _handleBackPress() {
    debugPrint('CustomBottomAppBar: Back button pressed');
    onBackPressed?.call();
  }

  void _handleNextPress() {
    debugPrint('CustomBottomAppBar: Next button pressed');
    onNextPressed?.call();
  }
  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    final double barHeight = responsive.hp(13); // increased from 10
    final double minHeight = responsive.spacing(90); // increased from 70
    final double maxHeight = responsive.spacing(120); // increased from 100

    // Use a larger, consistent button height and width for all 'Next' buttons
    final double buttonHeight = responsive.breakpointValue<double>(
      small: responsive.spacing(100),
      medium: responsive.spacing(100),
      large: responsive.spacing(100),
      extraLarge: responsive.spacing(100),
    );

    final double buttonWidth = responsive.breakpointValue<double>(
      small: responsive.wp(65),
      medium: responsive.wp(65),
      large: responsive.wp(65),
      extraLarge: responsive.wp(65),
    );

    final double finalHeight = barHeight.clamp(minHeight, maxHeight);

    // Responsive font size for buttons
    final double buttonFontSize = responsive.breakpointValue<double>(
      small: responsive.fontSize(14),
      medium: responsive.fontSize(15),
      large: responsive.fontSize(16),
      extraLarge: responsive.fontSize(17),
    );

    return Container(
      height: finalHeight,
      color: Colors.transparent, // Make container background transparent
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: responsive.spacing(10)),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showBackButton)
                  SizedBox(
                    width: showNextButton ? buttonWidth * 0.45 : buttonWidth,
                    height: buttonHeight,
                    child: WhiteBulkButton(
                      text: 'Vorige',
                      showIcon: false,
                      height: buttonHeight,
                      backgroundColor: AppColors.lightMintGreen100,
                      borderColor: AppColors.brown,
                      hoverBackgroundColor: AppColors.brown,
                      hoverBorderColor: AppColors.lightMintGreen100,
                      textStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.black,
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      showShadow: false,
                      onPressed: _handleBackPress,
                    ),
                  ),
                if (showBackButton && showNextButton)
                  SizedBox(width: responsive.wp(4)),
                if (showNextButton)
                  SizedBox(
                    width: showBackButton ? buttonWidth * 0.45 : buttonWidth,
                    height: buttonHeight,
                    child: WhiteBulkButton(
                      text: 'Volgende',
                      showIcon: false,
                      height: buttonHeight,
                      backgroundColor: AppColors.lightMintGreen100,
                      borderColor: AppColors.brown,
                      hoverBackgroundColor: AppColors.brown,
                      hoverBorderColor: AppColors.lightMintGreen100,
                      textStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.black,
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      showShadow: false,
                      onPressed: _handleNextPress,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
