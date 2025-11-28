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

    final double fontSize = responsive.breakpointValue<double>(
      small: responsive.fontSize(14),
      medium: responsive.fontSize(15),
      large: responsive.fontSize(16),
      extraLarge: responsive.fontSize(16),
    );

    final double iconSize = responsive.sp(2.5);
    final double minIconSize = responsive.sp(2.2);
    final double maxIconSize = responsive.sp(3);

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
    final double finalIconSize = iconSize.clamp(minIconSize, maxIconSize);
    final double horizontalPadding = responsive.wp(6);

    return Container(
      height: finalHeight,
      color: Colors.transparent, // Make container background transparent
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: responsive.spacing(10)),
          child: Center(
            child: Row(
              mainAxisAlignment:
                  showNextButton && showBackButton
                      ? MainAxisAlignment.spaceBetween
                      : showNextButton
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
              children: [
                if (showBackButton)
                  GestureDetector(
                    onTap: _handleBackPress,
                    child: Padding(
                      padding: EdgeInsets.only(left: horizontalPadding),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.brown,
                            size: finalIconSize,
                          ),
                          SizedBox(width: responsive.wp(3)),
                          Text(
                            'Terug',
                            style: TextStyle(
                              color: AppColors.brown,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (showNextButton)
                  SizedBox(
                    width: buttonWidth,
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
                        fontSize: responsive.fontSize(20),
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
