import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
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

class PossesionLocationScreen extends StatefulWidget {
  const PossesionLocationScreen({super.key});

  @override
  State<PossesionLocationScreen> createState() => _PossesionLocationScreenState();
}

class _PossesionLocationScreenState extends State<PossesionLocationScreen> {
  late final PossesionInterface _possesionManager;
  final greenLog = '\x1B[32m';
  final redLog = '\x1B[31m';
  final yellowLog = '\x1B[93m';
  final blueLog = '\x1B[34m';
  final purpleLog = '\x1B[35m';
  late final PossesionDamageFormProvider possesionProvider;
  late final MapProvider mapProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Defer initialization to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _possesionManager = context.read<PossesionInterface>();
      possesionProvider = context.read<PossesionDamageFormProvider>();
      mapProvider = context.read<MapProvider>();
      await mapProvider.initialize();
      setState(() {
        _isInitialized = true;
      });
    });
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
              Expanded(
                child: _isInitialized
                    ? const LocationScreenUIWidget()
                    : const Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(
          onBackPressed: () => context
              .read<NavigationStateInterface>()
              .pushReplacementBack(context, const Rapporteren()),
          onNextPressed: () {
            debugPrint("${purpleLog}[PossesionLocationScreen] ⚡ Next button callback triggered\x1B[0m");
            
            final locationManager = context.read<LocationScreenInterface>();
            final locationInfo = locationManager.getLocationAndDateTime(context);
            
            // Comprehensive logging of all location and datetime information
            debugPrint("${blueLog}[PossesionLocationScreen] 📍 Location and DateTime Info:\x1B[0m");
            debugPrint("${blueLog}[PossesionLocationScreen] Current GPS Location: ${locationInfo['currentGpsLocation']}\x1B[0m");
            debugPrint("${blueLog}[PossesionLocationScreen] Selected Location: ${locationInfo['selectedLocation']}\x1B[0m");
            debugPrint("${blueLog}[PossesionLocationScreen] DateTime Info: ${locationInfo['dateTime']}\x1B[0m");
            debugPrint("${blueLog}[PossesionLocationScreen] Is Location Unknown: ${locationInfo['isLocationUnknown']}\x1B[0m");
            debugPrint("${blueLog}[PossesionLocationScreen] Is DateTime Unknown: ${locationInfo['isDateTimeUnknown']}\x1B[0m");
            
            if (locationInfo['isLocationUnknown'] || locationInfo['isDateTimeUnknown']) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Please select a valid location and time")),
              );
              return;
            }

            _possesionManager.postInteraction().then((_) {
              debugPrint("${greenLog}[PossesionLocationScreen] ✅ Report posted successfully\x1B[0m");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report submitted successfully")),
              );
            }).catchError((e, stackTrace) {
              debugPrint("${redLog}[PossesionLocationScreen] ❌ Error in onNextPressed: $e\x1B[0m");
              debugPrint("${redLog}[PossesionLocationScreen] 🔍 Stack trace: $stackTrace\x1B[0m");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to submit report: $e")),
              );
            });
          },
          showNextButton: true,
          showBackButton: true,
        ),
      ),
    );
  }
}







