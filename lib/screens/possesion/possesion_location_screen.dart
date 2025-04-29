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
              await _possesionManager.postInteraction();
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