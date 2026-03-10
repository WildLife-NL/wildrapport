import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/widgets/map/wildlifenl_map.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class LocationMapPreview extends StatefulWidget {
  const LocationMapPreview({super.key});

  @override
  State<LocationMapPreview> createState() => _LocationMapPreviewState();
}

class _LocationMapPreviewState extends State<LocationMapPreview> {
  static const LatLng _defaultCenter = LatLng(51.69, 5.30);
  static const double _defaultZoom = 7.0;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final locationSharingOn = context.watch<AppStateProvider>().isLocationTrackingEnabled;
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        final hasPosition = mapProvider.selectedPosition != null ||
            mapProvider.currentPosition != null;
        final showPosition = locationSharingOn && hasPosition;

        if (!showPosition) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            try {
              final cam = mapProvider.mapController.camera;
              final needMove = cam.zoom != _defaultZoom ||
                  (cam.center.latitude - _defaultCenter.latitude).abs() > 0.01 ||
                  (cam.center.longitude - _defaultCenter.longitude).abs() > 0.01;
              if (needMove) {
                mapProvider.mapController.move(_defaultCenter, _defaultZoom);
              }
            } catch (_) {}
          });
          return SizedBox(
            height: responsive.hp(14),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(responsive.sp(3.75)),
              ),
              child: WildLifeNLMap(
                mapController: mapProvider.mapController,
                options: flutter_map.MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: _defaultZoom,
                  minZoom: 4.0,
                  maxZoom: 17.0,
                  interactionOptions: const flutter_map.InteractionOptions(
                    flags: flutter_map.InteractiveFlag.none,
                  ),
                ),
                userAgentPackageName: 'nl.wildlife.rapport',
                extraLayers: const [],
              ),
            ),
          );
        }

        final position =
            mapProvider.selectedPosition ?? mapProvider.currentPosition!;
        final point = LatLng(position.latitude, position.longitude);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          try {
            mapProvider.mapController.move(point, 15);
          } catch (_) {}
        });

        return SizedBox(
          height: responsive.hp(14),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(responsive.sp(3.75)),
            ),
            child: WildLifeNLMap(
              mapController: mapProvider.mapController,
              options: flutter_map.MapOptions(
                initialCenter: point,
                initialZoom: 15,
                minZoom: 4.0,
                maxZoom: 17.0,
                interactionOptions: const flutter_map.InteractionOptions(
                  flags: flutter_map.InteractiveFlag.none,
                ),
              ),
              userAgentPackageName: 'nl.wildlife.rapport',
              extraLayers: [
                flutter_map.MarkerLayer(
                  markers: [
                    flutter_map.Marker(
                      point: point,
                      width: responsive.sp(6),
                      height: responsive.sp(6),
                      child: Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: responsive.sp(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
