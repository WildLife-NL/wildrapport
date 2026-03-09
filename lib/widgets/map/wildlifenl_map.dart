import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:wildrapport/interfaces/map/map_state_interface.dart';

const String _openTopoMapTileUrl =
    'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
const List<String> _openTopoMapSubdomains = ['a', 'b', 'c'];

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

/// Kaartwidget: OpenTopoMap (of optioneel satelliet), attribution + [extraLayers].
/// Lokale implementatie zolang wildlifenl_map_logic_components geen WildLifeNLMap exporteert.
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
    final overlayChildren =
        nonRotatedChildren ?? [const _DefaultMapAttribution()];
    return FlutterMap(
      mapController: mapController,
      options: options,
      children: [
        TileLayer(
          urlTemplate: useSatelliteTiles
              ? MapStateInterface.satelliteTileUrl
              : _openTopoMapTileUrl,
          subdomains:
              useSatelliteTiles ? const [] : _openTopoMapSubdomains,
          userAgentPackageName: userAgentPackageName,
          keepBuffer: tileKeepBuffer,
        ),
        ...extraLayers,
        ...overlayChildren,
      ],
    );
  }
}
