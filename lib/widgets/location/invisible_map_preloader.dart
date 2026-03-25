import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/config/mock_location.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/widgets/map/wildlifenl_map.dart';

class InvisibleMapPreloader extends StatelessWidget {
  const InvisibleMapPreloader({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = context.read<MapProvider>().mapController;

    return Opacity(
      opacity: 0,
      child: SizedBox(
        width: 1,
        height: 1,
        child: WildLifeNLMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(
              MockLocationConfig.kMockLat,
              MockLocationConfig.kMockLon,
            ),
            initialZoom: 5,
            minZoom: 4.0,
            maxZoom: 17.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          userAgentPackageName: 'nl.wildlife.rapport',
          extraLayers: const [],
        ),
      ),
    );
  }
}
