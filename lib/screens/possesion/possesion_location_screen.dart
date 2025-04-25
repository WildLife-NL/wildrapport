import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/possesion_interface.dart';
import 'package:wildrapport/models/beta_models/possesion_damage_report_model.dart';
import 'package:wildrapport/models/beta_models/possesion_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/possesion_damage_report_provider.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';
import 'package:wildrapport/widgets/location/location_screen-ui_widget.dart';
import 'package:wildrapport/widgets/permission_gate.dart';

class PossesionLocationScreen extends StatefulWidget{
  const PossesionLocationScreen({super.key});

  @override
  State<PossesionLocationScreen> createState() => _PossesionLocationScreenState();
}
class _PossesionLocationScreenState extends State<PossesionLocationScreen> {
  late final MapProvider _mapProvider;
  late final PossesionInterface _possesionManager;

  @override
  void initState() {
    super.initState();
    _mapProvider = context.read<MapProvider>();
    _possesionManager = context.read<PossesionInterface>();
  }

PossesionDamageReport _buildReportTesting(){
    final possesionProvider = Provider.of<PossesionDamageFormProvider>(context, listen: false);
    
    Position userSelectedPosition = _mapProvider.selectedPosition!;
    Position systemSelectedPosition = _mapProvider.currentPosition!;

    final systemReportLocation = ReportLocation(latitude: systemSelectedPosition.latitude, longtitude: systemSelectedPosition.longitude);
    final userReportLocation = ReportLocation(latitude: userSelectedPosition.latitude, longtitude: userSelectedPosition.longitude);

    final report = PossesionDamageReport(
      possesion: Possesion(
        possesionID: "3c6c44fc-06da-4530-ab27-3974e6090d7d", 
        possesionName: possesionProvider.impactedCrop, 
        category: "gewassen"
      ),
      impactedAreaType: possesionProvider.impactedAreaType,
      impactedArea: double.tryParse(possesionProvider.impactedArea) ?? 0,
      currentImpactDamages: possesionProvider.currentDamage.toString(),
      estimatedTotalDamages: possesionProvider.expectedDamage.toString(),
      description: possesionProvider.description,
      suspectedSpeciesID: possesionProvider.suspectedSpeciesID,
      userSelectedDateTime: DateTime.now(),
      systemDateTime: DateTime.now(),
      systemLocation: systemReportLocation,
      userSelectedLocation: userReportLocation,
    );
    return report;
  }

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              CustomAppBar(
                leftIcon: Icons.arrow_back_ios,
                centerText: 'Locatie',
                rightIcon: Icons.menu,
                onLeftIconPressed: () => context
                    .read<NavigationStateInterface>()
                    .pushReplacementBack(context, const Rapporteren()),
                onRightIconPressed: () {/* Handle menu */},
              ),
              const Expanded(
                child: LocationScreenUIWidget(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(
          onBackPressed: () => context
              .read<NavigationStateInterface>()
              .pushReplacementBack(context, const Rapporteren()),
          onNextPressed: () {
            _possesionManager.postInteraction(_buildReportTesting());
          },
          showNextButton: true,
          showBackButton: true,
        ),
      ),
    );
  }
}