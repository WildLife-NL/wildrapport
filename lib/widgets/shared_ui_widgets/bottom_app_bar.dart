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

    final double barHeight = responsive.hp(8);
    final double minHeight = responsive.spacing(60);
    final double maxHeight = responsive.spacing(90);

    final double fontSize = responsive.fontSize(12);
    final double minFontSize = responsive.fontSize(12);
    final double maxFontSize = responsive.fontSize(16);

    final double iconSize = responsive.sp(2.5);
    final double minIconSize = responsive.sp(2.2);
    final double maxIconSize = responsive.sp(3);

    final double finalHeight = barHeight.clamp(minHeight, maxHeight);
    final double finalFontSize = fontSize.clamp(minFontSize, maxFontSize);
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
                              fontSize: finalFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (showNextButton)
                  SizedBox(
                    width: responsive.wp(45),
                    height: responsive.spacing(38),
                    child: WhiteBulkButton(
                      text: 'Volgende',
                      showIcon: false,
                      height: responsive.spacing(38),
                      backgroundColor: AppColors.lightMintGreen100,
                      borderColor: AppColors.brown,
                      hoverBackgroundColor: AppColors.brown,
                      hoverBorderColor: AppColors.lightMintGreen100,
                      textStyle: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.black,
                        fontSize: finalFontSize,
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
