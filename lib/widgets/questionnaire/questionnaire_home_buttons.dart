import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';
import 'package:wildrapport/widgets/questionnaire/questionnaire_white_button.dart';

class QuestionnaireHomeButtons extends StatelessWidget{
  final Function() onOverslaanPressed;
  final Function() onBewaarVoorLaterPressed;
  final VoidCallback onVragenlijnstOpenenPressed;

  const QuestionnaireHomeButtons({
    super.key,
    required this.onOverslaanPressed,
    required this.onBewaarVoorLaterPressed,
    required this.onVragenlijnstOpenenPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(
              text: "Overslaan", 
              image: Image.asset("assets/icons/questionnaire/arrow.png"),
              height: 63,
              width: 200,
              onPressed: onOverslaanPressed,
              ),
              SizedBox(height: 24),
              _buildButton(
              text: "Bewaar voor later", 
              image: Image.asset("assets/icons/questionnaire/save.png"),
              height: 63,
              width: 277,
              onPressed: onBewaarVoorLaterPressed,
              ),
              SizedBox(height: 24),
              _buildButton(
              text: "Vragenlijst Openen", 
              image: Image.asset("assets/icons/questionnaire/arrow_forward.png"),
              height: 70,
              width: 339,
              onPressed: onVragenlijnstOpenenPressed,
              ),
          ],
        )
      )
    );
  }
  Widget _buildButton({
    required String text,
    required Image image,
    double? height,
    double? width,
    VoidCallback? onPressed,
  }) {
    return QuestionnaireWhiteButton(
      text: text,
      rightWidget: SizedBox(
        width: 24,
        height: 24,
        child: image,
      ),
      height: height,
      width: width,
      onPressed: onPressed,
    );
  }
}