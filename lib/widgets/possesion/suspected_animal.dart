import 'package:flutter/material.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';

class SuspectedAnimal extends StatefulWidget{
  const SuspectedAnimal({super.key});

  @override
  State<StatefulWidget> createState() => _SuspectedAnimalState();
}

class _SuspectedAnimalState extends State<SuspectedAnimal> {

  @override
  Widget build(BuildContext context){
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
              text: "Onbekend", 
              image: Image.asset("assets/icons/questionnaire/arrow_forward.png"),
              height: 63,
              width: 200,
              ),
              SizedBox(height: 24),
              _buildButton(
              text: "Vogels", 
              image: Image.asset("assets/icons/questionnaire/arrow_forward.png"),
              height: 63,
              width: 277,
              ),
              SizedBox(height: 24),
              _buildButton(
              text: "Knaagdieren", 
              image: Image.asset("assets/icons/questionnaire/arrow_forward.png"),
              height: 70,
              width: 339,
              ),
              SizedBox(height: 24),
              _buildButton(
              text: "Evenhoevigen", 
              image: Image.asset("assets/icons/questionnaire/arrow_forward.png"),
              height: 70,
              width: 339,
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
    return WhiteBulkButton(
      text: text,
      rightWidget: SizedBox(
        width: 24,
        height: 24,
        child: image,
      ),
      onPressed: onPressed,
    );
  }
}