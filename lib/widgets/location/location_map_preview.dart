import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/screens/location/map_screen.dart';
import 'package:wildrapport/screens/belonging/belonging_location_screen.dart';
import 'package:wildrapport/widgets/location/custom_location_map_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class LocationMapPreview extends StatelessWidget {
  const LocationMapPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Consumer<MapProvider>(
      builder: (context, mapProvider, child) {
        // Show placeholder for unknown location
        if (mapProvider.selectedAddress.isEmpty) {
          return Container(
            height: responsive.hp(18),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(responsive.sp(3.75)),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: responsive.sp(40), color: Colors.grey[400]),
                  SizedBox(height: responsive.spacing(8)),
                  Text(
                    'Geen locatie geselecteerd',
                    style: TextStyle(color: Colors.grey[600], fontSize: responsive.fontSize(14)),
                  ),
                ],
              ),
            ),
          );
        }

        // Show loading animation when either position is null OR address is empty
        if (mapProvider.currentPosition == null ||
            mapProvider.selectedAddress.isEmpty) {
          return Container(
            height: responsive.hp(18),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(responsive.sp(3.75)),
              ),
            ),
            child: Center(
              child: SizedBox(
                width: responsive.sp(100),
                height: responsive.sp(100),
                child: Lottie.asset(
                  'assets/loaders/loading_paw.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                  frameRate: FrameRate(60),
                ),
              ),
            ),
          );
        }

        // Get the position to display (either selected or current)
        final position =
            mapProvider.selectedPosition ?? mapProvider.currentPosition!;
        final point = LatLng(position.latitude, position.longitude);

        return Stack(
          children: [
            SizedBox(
              height: responsive.hp(18),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(responsive.sp(3.75)),
                ),
                child: flutter_map.FlutterMap(
                  mapController: mapProvider.mapController,
                  options: flutter_map.MapOptions(
                    initialCenter: point,
                    initialZoom: 15,
                    interactionOptions: const flutter_map.InteractionOptions(
                      flags: flutter_map.InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    flutter_map.TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.wildrapport.app',
                    ),
                    flutter_map.MarkerLayer(
                      markers: [
                        flutter_map.Marker(
                          point: point,
                          width: responsive.sp(40),
                          height: responsive.sp(40),
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: responsive.sp(40),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: responsive.spacing(8),
              right: responsive.spacing(8),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(responsive.sp(2)),
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    debugPrint('[LocationMapPreview] Expand button tapped!');

                    // Check if we're in the possession flow
                    final isFromPossession =
                        ModalRoute.of(context)?.settings.name ==
                            'PossesionLocationScreen' ||
                        context
                                .findAncestorWidgetOfExactType<
                                  BelongingLocationScreen
                                >() !=
                            null;

                    debugPrint(
                      '[LocationMapPreview] isFromPossession: $isFromPossession',
                    );

                    // Navigate to full interactive map
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(
                          name:
                              isFromPossession
                                  ? 'PossesionCustomMap'
                                  : 'CustomMap',
                        ),
                        builder:
                            (_) => MapScreen(
                              title: 'Selecteer locatie',
                              mapWidget: CustomLocationMapScreen(
                                isFromPossession: isFromPossession,
                              ),
                            ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(responsive.sp(2)),
                  child: Padding(
                    padding: EdgeInsets.all(responsive.spacing(8)),
                    child: Icon(
                      Icons.fullscreen,
                      color: Colors.grey[700],
                      size: responsive.sp(24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
