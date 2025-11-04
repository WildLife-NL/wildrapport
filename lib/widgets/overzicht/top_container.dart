import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';

class TopContainer extends StatelessWidget {
  final String userName;
  final double height;
  final double welcomeFontSize;
  final double usernameFontSize;

  const TopContainer({
    super.key,
    required this.userName,
    required this.height,
    required this.welcomeFontSize,
    required this.usernameFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.zero, // straight bottom edge to match mock
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: height * 0.06),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welkom Bij Wild Rapport',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: welcomeFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: height * 0.03),
              Text(
                userName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: usernameFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
