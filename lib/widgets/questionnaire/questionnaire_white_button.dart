import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';

class QuestionnaireWhiteButton extends StatelessWidget{
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextTheme.textTheme.titleMedium?.copyWith(
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
                  Container(
                    child: rightWidget!,  // Directly use the rightWidget without ShaderMask
                  )
                else 
                  const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}