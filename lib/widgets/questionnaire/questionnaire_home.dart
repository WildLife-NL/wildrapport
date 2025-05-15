import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/app_text_theme.dart';
import 'package:wildrapport/interfaces/questionnaire_interface.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_home_buttons.dart';

class QuestionnaireHome extends StatelessWidget {
  final VoidCallback nextScreen;
  final int amountOfQuestions;

  const QuestionnaireHome({super.key, required this.nextScreen, required this.amountOfQuestions});

  @override
  Widget build(BuildContext context) {
    final questionnaireManager = context.read<QuestionnaireInterface>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 100.0,
          ),
          child: Text(
            "Wil je de natuur helpen door een paar vragen te beantwoorden?",
            textAlign: TextAlign.center,
            style: AppTextTheme.textTheme.titleLarge?.copyWith(
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
        Column(
          children: [
            Text(
              "Totaal",
              style: TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ).copyWith(
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            Text(
              "$amountOfQuestions",
              style: TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ).copyWith(
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 40),
        QuestionnaireHomeButtons(
          onOverslaanPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OverzichtScreen()),
            );
          },
          onBewaarVoorLaterPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OverzichtScreen()),
            );
          },
          onVragenlijnstOpenenPressed: () => nextScreen(),
        ),
      ],
    );
  }
}
