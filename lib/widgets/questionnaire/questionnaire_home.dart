import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';

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
    final screenSize = MediaQuery.of(context).size;
    final verticalSpacing = screenSize.height * 0.03;
    
    return Stack(
      children: [
        // Main content
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.08,
            vertical: screenSize.height * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Questionnaire name
              Text(
                questionnaireName,
                textAlign: TextAlign.center,
                style: AppTextTheme.textTheme.titleLarge?.copyWith(
                  fontSize: screenSize.width * 0.065,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: verticalSpacing),
              // Questionnaire description
              Text(
                questionnaireDescription,
                textAlign: TextAlign.center,
                style: AppTextTheme.textTheme.bodyLarge?.copyWith(
                  fontSize: screenSize.width * 0.045,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: verticalSpacing * 1.5),
              // Question count
              Column(
                children: [
                  Text(
                    "Totaal aantal vragen",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Roboto',
                      fontSize: screenSize.width * 0.04,
                    ),
                  ),
                  Text(
                    "$amountOfQuestions",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: screenSize.width * 0.055,
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing * 2),
              // Large "Start" button
              SizedBox(
                width: screenSize.width * 0.75,
                height: screenSize.height * 0.08,
                child: ElevatedButton(
                  onPressed: nextScreen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightMintGreen100,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.lightGreen, width: 2),
                    ),
                  ),
                  child: Text(
                    "Start",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: screenSize.width * 0.055,
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
          top: screenSize.height * 0.02,
          right: screenSize.width * 0.04,
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
              size: screenSize.width * 0.06,
            ),
            tooltip: 'Overslaan',
          ),
        ),
      ],
    );
  }
}

