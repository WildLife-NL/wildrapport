import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';

class WhiteBulkButton extends StatelessWidget {
  final String text;
  final Widget? leftWidget;
  final Widget? rightWidget;
  final VoidCallback? onPressed;

  const WhiteBulkButton({
    super.key,
    required this.text,
    this.leftWidget,
    this.rightWidget,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
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
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leftWidget != null) leftWidget! else const SizedBox(),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: AppTextTheme.textTheme.titleLarge?.copyWith(
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
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Colors.black54.withOpacity(0.8),
                          ],
                        ).createShader(bounds);
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.black54,
                        size: 24,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
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







