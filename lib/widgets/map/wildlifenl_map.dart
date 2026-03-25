import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:wildrapport/interfaces/map/map_state_interface.dart';

const double kOpenTopoMapMaxZoom = 17.0;

class _DefaultMapAttribution extends StatelessWidget {
  const _DefaultMapAttribution();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 6, bottom: 6),
        child: Text(
          '© OpenTopoMap · © OpenStreetMap contributors',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black.withValues(alpha: 0.6),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class WildLifeNLMap extends StatelessWidget {
  final MapController? mapController;
  final MapOptions options;
  final List<Widget> extraLayers;
  final String userAgentPackageName;
  final List<Widget>? nonRotatedChildren;
  final bool useSatelliteTiles;
  final int tileKeepBuffer;

  const WildLifeNLMap({
    super.key,
    this.mapController,
    required this.options,
    this.extraLayers = const [],
    this.userAgentPackageName = 'nl.wildlife.rapport',
    this.nonRotatedChildren,
    this.useSatelliteTiles = false,
    this.tileKeepBuffer = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Keep a local attribution widget to prevent bottom overflow on mobile.
    // Tile URLs still come from shared component constants.
    final overlayChildren =
        nonRotatedChildren ?? [const _DefaultMapAttribution()];
    return FlutterMap(
      mapController: mapController,
      options: options,
      children: [
        TileLayer(
          urlTemplate: useSatelliteTiles
              ? MapStateInterface.satelliteTileUrl
              : MapStateInterface.standardTileUrl,
          subdomains: useSatelliteTiles
              ? const []
              : MapStateInterface.standardTileSubdomains,
          userAgentPackageName: userAgentPackageName,
          keepBuffer: tileKeepBuffer,
        ),
        ...extraLayers,
        ...overlayChildren,
      ],
    );
  }
}
