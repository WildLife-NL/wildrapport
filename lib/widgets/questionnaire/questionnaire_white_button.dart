import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';

class QuestionnaireWhiteButton extends StatelessWidget {
  final String text;
  final double? height;
  final double? width;
  final Widget? rightWidget;
  final VoidCallback? onPressed;

  const QuestionnaireWhiteButton({
    super.key,
    required this.text,
    this.height,
    this.width,
    this.rightWidget,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
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
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.brown,
                      fontWeight: FontWeight.normal,
                      fontSize: 20).copyWith(
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                  ),
                ),
                if (rightWidget != null)
                  Positioned(
                    top: 4, 
                    right: 0,  
                    child: rightWidget!,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}