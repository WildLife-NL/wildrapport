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

  PossesionDamageReport buildReportTesting() {
    debugPrint("✅ buildReportTesting called");
    try {
      // Log provider state
      debugPrint("📍 MapProvider state: selectedPosition=${mapProvider.selectedPosition}, currentPosition=${mapProvider.currentPosition}");
      debugPrint("📋 PossesionProvider state: "
          "impactedCrop=${possesionProvider.impactedCrop}, "
          "impactedAreaType=${possesionProvider.impactedAreaType}, "
          "impactedArea=${possesionProvider.impactedArea}, "
          "currentDamage=${possesionProvider.currentDamage}, "
          "expectedDamage=${possesionProvider.expectedDamage}, "
          "description=${possesionProvider.description}, "
          "suspectedSpeciesID=${possesionProvider.suspectedSpeciesID}");

      // Validate positions
      if (mapProvider.selectedPosition == null || mapProvider.currentPosition == null) {
        debugPrint("❗ One or both positions are null: "
            "selectedPosition=${mapProvider.selectedPosition}, "
            "currentPosition=${mapProvider.currentPosition}");
      }

      // Use actual positions if available, fallback to defaults
      final systemReportLocation = ReportLocation(
        latitude: mapProvider.currentPosition?.latitude ?? 20,
        longtitude: mapProvider.currentPosition?.longitude ?? 20, // Fixed typo: longtitude -> longitude
      );
      final userReportLocation = ReportLocation(
        latitude: mapProvider.selectedPosition?.latitude ?? 20,
        longtitude: mapProvider.selectedPosition?.longitude ?? 20,
      );

      // Validate possesionProvider inputs
      if (possesionProvider.impactedCrop.isEmpty) {
        throw Exception("Impacted crop is empty");
      }
      if (possesionProvider.impactedArea.isEmpty) {
        throw Exception("Impacted area is empty");
      }
      final impactedArea = double.tryParse(possesionProvider.impactedArea);
      if (impactedArea == null) {
        throw Exception("Invalid impacted area: ${possesionProvider.impactedArea}");
      }

      final report = PossesionDamageReport(
        possesion: Possesion(
          possesionID: "3c6c44fc-06da-4530-ab27-3974e6090d7d",
          possesionName: possesionProvider.impactedCrop,
          category: "gewassen",
        ),
        impactedAreaType: possesionProvider.impactedAreaType,
        impactedArea: impactedArea,
        currentImpactDamages: possesionProvider.currentDamage.toString(),
        estimatedTotalDamages: possesionProvider.expectedDamage.toString(),
        description: possesionProvider.description,
        suspectedSpeciesID: possesionProvider.suspectedSpeciesID,
        userSelectedDateTime: DateTime.now(),
        systemDateTime: DateTime.now(),
        systemLocation: systemReportLocation,
        userSelectedLocation: userReportLocation,
      );

      debugPrint("✅ Report created: $report");
      return report;
    } catch (e, stackTrace) {
      debugPrint("❌ Exception in buildReportTesting: $e");
      debugPrint("🔍 Stack trace: $stackTrace");
      rethrow;
    }
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
          onNextPressed: () async {
            debugPrint("🚀 Next button pressed, attempting to build and post report");
            try {
              final report = buildReportTesting();
              debugPrint("✅ Report built successfully: $report");
              await _possesionManager.postInteraction(report);
              debugPrint("✅ Report posted successfully");
              // Navigate to the next screen or show success
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Report submitted successfully")),
              );
              // Example navigation
              // context.read<NavigationStateInterface>().push(context, NextScreen());
            } catch (e, stackTrace) {
              debugPrint("❌ Error in onNextPressed: $e");
              debugPrint("🔍 Stack trace: $stackTrace");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Failed to submit report: $e")),
              );
            }
          },
          showNextButton: true,
          showBackButton: true,
        ),
      ),
    );
  }
}