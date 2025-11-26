import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class QuestionnaireHome extends StatelessWidget {
  final VoidCallback nextScreen;
  final int amountOfQuestions;
  final String questionnaireName;
  final String questionnaireDescription;

  const QuestionnaireHome({
    super.key,
    required this.nextScreen,
    required this.amountOfQuestions,
    required this.questionnaireName,
    required this.questionnaireDescription,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Stack(
      children: [
        // Main content
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(8),
            vertical: responsive.hp(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Questionnaire name
              Text(
                questionnaireName,
                textAlign: TextAlign.center,
                style: AppTextTheme.textTheme.titleLarge?.copyWith(
                  fontSize: responsive.fontSize(24),
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: responsive.spacing(16)),
              // Questionnaire description
              Text(
                questionnaireDescription,
                textAlign: TextAlign.center,
                style: AppTextTheme.textTheme.bodyLarge?.copyWith(
                  fontSize: responsive.fontSize(16),
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: responsive.spacing(24)),
              // Question count
              Column(
                children: [
                  Text(
                    "Totaal aantal vragen",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Roboto',
                      fontSize: responsive.fontSize(14),
                    ),
                  ),
                  Text(
                    "$amountOfQuestions",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.fontSize(20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(32)),
              // Large "Start" button
              SizedBox(
                width: responsive.wp(75),
                height: responsive.hp(8),
                child: ElevatedButton(
                  onPressed: nextScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightMintGreen100,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive.sp(1.5)),
                      side: BorderSide(
                        color: AppColors.lightGreen,
                        width: responsive.sp(0.25),
                      ),
                    ),
                  ),
                  child: Text(
                    "Start",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: responsive.fontSize(20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Small close button in top-right corner
        Positioned(
          top: responsive.hp(2),
          right: responsive.wp(4),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OverzichtScreen()),
              );
            },
            icon: Icon(
              Icons.close,
              color: Colors.black38,
              size: responsive.sp(3),
            ),
            tooltip: 'Overslaan',
          ),
        ),
      ],
    );
  }
}

