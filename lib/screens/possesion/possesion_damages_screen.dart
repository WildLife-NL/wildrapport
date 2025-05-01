import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/invisible_map_preloader.dart';

class PossesionDamagesScreen extends StatefulWidget{
  const PossesionDamagesScreen({super.key});

  @override
  State<PossesionDamagesScreen> createState() => _PossesionDamageScreenState();
}

class _PossesionDamageScreenState extends State<PossesionDamagesScreen> {
  late final PossesionInterface _possesionManager;
  late List<dynamic> possesionDamagesWidgetList;
  late int currentIndex;
  late int maxIndex;

  @override
  void initState() {
    super.initState();
    _possesionManager = context.read<PossesionInterface>();
    _loadPossesionWidgets();
    currentIndex = 0;
    maxIndex = possesionDamagesWidgetList.length - 1;
  }

  // Method to check if all required fields are filled
  bool validateForm() {
    final formProvider = Provider.of<PossesionDamageFormProvider>(context, listen: false);
    formProvider.resetErrors();

    bool isValid = true;

    // Check if each required field is filled
    if (formProvider.impactedCrop.isEmpty) {
      isValid = false;
      // Optionally set a flag to highlight this field
      formProvider.setErrorState('impactedCrop', true);
    }
    if (formProvider.impactedAreaType.isEmpty) {
      isValid = false;
      formProvider.setErrorState('impactedAreaType', true);
    }
    if (formProvider.impactedArea == 0) {
      isValid = false;
      formProvider.setErrorState('impactedArea', true);
    }

    return isValid;
  }

  void nextScreen() {
    if (validateForm()) {
      debugPrint("Form is valid!");
      if (currentIndex < maxIndex) {
        setState(() {
          currentIndex++;
        });
      }
    } else {
      // Handle invalid form state, display error messages, or highlight fields
      debugPrint("Form is not valid!!!");
      setState(() {
        // Optionally trigger state changes to show inline errors
      });
    }
  }

  void previousScreen() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  void _loadPossesionWidgets() {
    final widgetList = _possesionManager.buildPossesionWidgetList();
    setState(() {
      possesionDamagesWidgetList = widgetList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PossesionDamageFormProvider>(context);
    final navigationManager = context.read<NavigationStateInterface>();
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
                navigationManager.pushReplacementForward(
                  context,
                  const Rapporteren(),
                );
              },
              onRightIconPressed: () {
                // Handle menu
              },
            ),
            Expanded(child: possesionDamagesWidgetList[currentIndex]),
            CustomBottomAppBar(
              onNextPressed: nextScreen,
              onBackPressed: previousScreen,
              showNextButton: currentIndex < 1,
              showBackButton: currentIndex > 0,
            ),
            const InvisibleMapPreloader(),
          ],
        ),
      ),
    );
  }
}
