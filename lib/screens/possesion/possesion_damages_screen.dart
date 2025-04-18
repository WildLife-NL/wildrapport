import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';

class PossesionDamagesScreen extends StatefulWidget{
  const PossesionDamagesScreen({super.key});

  @override
  State<PossesionDamagesScreen> createState() => _PossesionDamageScreenState();
}

class _PossesionDamageScreenState extends State<PossesionDamagesScreen>{
  late final PossesionInterface _possesionManager;
  late List<dynamic> possesionDamagesWidgetList;
  late int currentIndex;
  late int maxIndex;

  @override
  void initState(){
    super.initState();
    _possesionManager = context.read<PossesionInterface>();
    _loadPossesionWidgets();
    currentIndex = 0;
    maxIndex = possesionDamagesWidgetList.length - 1;

  }
  void nextScreen() {
    if (currentIndex < maxIndex){
      setState(() {
        currentIndex++;
      });
    }
  } 

  void previousScreen(){
    if (currentIndex > 0){
      setState(() {
        currentIndex--;
      });
    }
  } 
  void _loadPossesionWidgets(){
    final widgetList = _possesionManager.buildPossesionWidgetList();
    setState(() {
      possesionDamagesWidgetList = widgetList;
    });
  }

  @override
  Widget build(BuildContext context){
    final provider = Provider.of<PossesionDamageFormProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: "Gewasschade",
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                provider.clearStateOfValues();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OverzichtScreen(),
                  ),
                );
              },
              onRightIconPressed: () {/* Handle menu */},
            ),
            Expanded(child: possesionDamagesWidgetList[currentIndex]),
            CustomBottomAppBar(
              onNextPressed: nextScreen,
              onBackPressed: previousScreen,
              showNextButton: currentIndex < 1,
              showBackButton: currentIndex > 0,
        ),
          ],
        )
      ),
    );
  }
}