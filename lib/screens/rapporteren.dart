import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/models/enums/report_type.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/screens/animal_condition_screen.dart';
import 'package:wildrapport/screens/animals_screen.dart';
import 'package:wildrapport/screens/overzicht_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/report_button.dart';

class Rapporteren extends StatefulWidget {
  const Rapporteren({super.key});

  @override
  State<Rapporteren> createState() => _RapporterenState();
}

class _RapporterenState extends State<Rapporteren> {
  String selectedCategory = '';

  void _handleReportTypeSelection(String reportType) {
    if (!mounted) return;
    
    setState(() {
      selectedCategory = reportType;
    });
    
    final navigationManager = context.read<NavigationStateInterface>();
    final appStateProvider = context.read<AppStateProvider>();
    
    ReportType selectedReportType;
    Widget nextScreen;

    switch (reportType) {
      case 'animalSightingen':
        selectedReportType = ReportType.waarneming;
        nextScreen = const AnimalConditionScreen();
        break;
      case 'Gewasschade':
        selectedReportType = ReportType.gewasschade;
        nextScreen = AnimalsScreen(appBarTitle: reportType);
        break;
      case 'Diergezondheid':
        selectedReportType = ReportType.verkeersongeval;
        nextScreen =  AnimalsScreen(appBarTitle: reportType);
        break;
      default:
        throw Exception('Unknown report type: $reportType');
    }

    // Initialize the report in the app state
    appStateProvider.initializeReport(selectedReportType);

    // Navigate to the next screen
    navigationManager.pushReplacementForward(context, nextScreen);
  }

  void _handleBackNavigation(BuildContext context) {
    final navigationManager = context.read<NavigationStateInterface>();
    navigationManager.pushAndRemoveUntil(
      context,
      const OverzichtScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double verticalPadding = screenSize.height * 0.01;
    final double horizontalPadding = screenSize.width * 0.05;
    final navigationManager = context.read<NavigationStateInterface>();

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Rapporteren',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => _handleBackNavigation(context),
              onRightIconPressed: () {},
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: ReportButton(
                              image: 'assets/icons/rapporteren/crop_icon.png',
                              text: 'Gewasschade',
                              onPressed: () => _handleReportTypeSelection('Gewasschade'),
                            ),
                          ),
                          SizedBox(width: screenSize.width * 0.02),
                          Expanded(
                            child: ReportButton(
                              image: 'assets/icons/rapporteren/health_icon.png',
                              text: 'Diergezondheid',
                              onPressed: () => _handleReportTypeSelection('Diergezondheid'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Expanded(
                      child: ReportButton(
                        image: 'assets/icons/rapporteren/sighting_icon.png',
                        text: 'Waarnemingen',
                        onPressed: () => _handleReportTypeSelection('animalSightingen'),
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}








