import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/screens/possesion/gewasschade_animal_screen.dart';
import 'package:wildrapport/widgets/white_bulk_button.dart';

class SuspectedAnimal extends StatefulWidget{
  const SuspectedAnimal({super.key});

  @override
  State<StatefulWidget> createState() => _SuspectedAnimalState();
}

class _SuspectedAnimalState extends State<SuspectedAnimal> {
  late final PossesionInterface _possesionManager;

  @override
  void initState() {
    super.initState();
    _possesionManager = context.read<PossesionInterface>();    
  }
  Future<dynamic> pressed(String animalType){
    _possesionManager.updateSuspectedAnimal(animalType);
    return Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GewasschadeAnimalScreen(appBarTitle: 'Kies Dier'),
                ),
              );
  }

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
              onPressed: () => pressed("Onbekend"),
              ),
              SizedBox(height: 24),
              _buildButton(
              text: "Vogels", 
              image: Image.asset("assets/icons/questionnaire/arrow_forward.png"),
              height: 63,
              width: 277,
              onPressed: () => pressed("Vogels"),
              ),
              SizedBox(height: 24),
              _buildButton(
              text: "Knaagdieren", 
              image: Image.asset("assets/icons/questionnaire/arrow_forward.png"),
              height: 70,
              width: 339,
              onPressed: () => pressed("Knaagdieren"),
              ),
              SizedBox(height: 24),
              _buildButton(
              text: "Evenhoevigen", 
              image: Image.asset("assets/icons/questionnaire/arrow_forward.png"),
              height: 70,
              width: 339,
              onPressed: () => pressed("Evenhoevigen"),
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