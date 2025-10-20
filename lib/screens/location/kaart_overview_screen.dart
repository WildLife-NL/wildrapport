import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:wildrapport/models/api_models/interaction_query_result.dart';



class KaartOverviewScreen extends StatefulWidget {
  const KaartOverviewScreen({super.key});

  @override
  State<KaartOverviewScreen> createState() => _KaartOverviewScreenState();
}

class _KaartOverviewScreenState extends State<KaartOverviewScreen>
    with TickerProviderStateMixin {
  final _location = LocationMapManager();

Timer? _debounce;
static const _debounceMs = 450;

  @override
  void initState() {
    super.initState();
    _bootstrap(); 
  }

  @override
  void dispose() {
    _debounce?.cancel(); // <-- clean up debounce timer
    super.dispose();
  }

void _queueFetch() {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: _debounceMs), () {
    if (mounted) _fetchInteractionsForView();
  });
}

int _radiusFromView({
  required double zoom,
  required double lat,
  required double widthPx,
}) {
  final metersPerPixel =
      156543.03392 * math.cos(lat * math.pi / 180.0) / math.pow(2.0, zoom);
  final halfWidthMeters = (widthPx / 2.0) * metersPerPixel;
  return halfWidthMeters.round().clamp(250, 30000);
}

Future<void> _fetchInteractionsForView() async {
  final map = context.read<MapProvider>();
  final camera = map.mapController.camera;
  final center = camera.center;
  final zoom = camera.zoom;

  final widthPx = MediaQuery.of(context).size.width;
  final radius = _radiusFromView(
    zoom: zoom,
    lat: center.latitude,
    widthPx: widthPx,
  );

  final now = DateTime.now().toUtc();
  final after = now.subtract(const Duration(days: 180));

  await map.loadInteractions(
    lat: center.latitude,
    lon: center.longitude,
    radiusMeters: radius,
    after: after,
    before: now,
  );
}


Future<void> _bootstrap() async {
  final map = context.read<MapProvider>();
  final app = context.read<AppStateProvider>();
  final mgr = _location; 





  // 1) Get a position (cache → GPS)
  Position? pos = app.isLocationCacheValid ? app.cachedPosition : null;
  pos ??= await mgr.determinePosition();
  if (!mounted || pos == null) return;

  // Optional: clamp to NL center if outside
  if (!mgr.isLocationInNetherlands(pos.latitude, pos.longitude)) {
    pos = Position(
      latitude: LocationMapManager.denBoschCenter.latitude,
      longitude: LocationMapManager.denBoschCenter.longitude,
      timestamp: DateTime.now(),
      accuracy: 100,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  // 2) **Set the position immediately** (don’t wait for address)
  await map.resetToCurrentLocation(pos, 'Locatie gevonden'); // fallback text

// Move camera now so the map appears
WidgetsBinding.instance.addPostFrameCallback((_) async {
  try {
    map.mapController.move(LatLng(pos!.latitude, pos.longitude), 15);

    // Immediate first fetch: wide radius + wide time window
    final now = DateTime.now().toUtc();
    await context.read<MapProvider>().loadInteractions(
      lat: pos.latitude,
      lon: pos.longitude,
      radiusMeters: 5000,                           // start wide
      after: now.subtract(const Duration(days: 365)),
      before: now,
    );

    // Then let the debounced fetch keep it in sync with pans/zooms
    _queueFetch();
  } catch (_) {}
});


  // 3) Try to resolve the address **after** the map is visible
  try {
    final address = await mgr.getAddressFromPosition(pos);
    if (!mounted) return;
    // Update address without clearing position
    map.setSelectedLocation(pos, address);
  } catch (e) {
    debugPrint('[Kaart] Reverse geocoding failed on web: $e');
    // keep the fallback text
  }
}


  @override
  Widget build(BuildContext context) {
    final map = context.watch<MapProvider>();
    final pos = map.selectedPosition ?? map.currentPosition;

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) return true;
        context
            .read<NavigationStateInterface>()
            .pushReplacementBack(context, const OverzichtScreen());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kaart'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context
                    .read<NavigationStateInterface>()
                    .pushReplacementBack(context, const OverzichtScreen());
              }
            },
          ),
        ),
        body: pos == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  fm.FlutterMap(
                    mapController: map.mapController,
                    options: fm.MapOptions(
                      initialCenter: LatLng(pos.latitude, pos.longitude),
                      initialZoom: 15,
                      interactionOptions: const fm.InteractionOptions(
                        flags: fm.InteractiveFlag.all,
                      ),
                      onMapEvent: (evt) => _queueFetch(),
                    ),
                    children: [
                      fm.TileLayer(
                        urlTemplate: LocationMapManager.standardTileUrl,
                        userAgentPackageName: 'com.wildrapport.app',
                      ),
                      // current location dot
                      fm.MarkerLayer(markers: [
                        fm.Marker(
                          point: LatLng(pos.latitude, pos.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.my_location, size: 30),
                        ),
                      ]),
                      // interaction pins
                      fm.MarkerLayer(
                        markers: map.interactions
                            .map((InteractionQueryResult itx) {
                          return fm.Marker(
                            point: LatLng(itx.lat, itx.lon),
                            width: 36,
                            height: 36,
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (_) => Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          itx.speciesName ??
                                              itx.typeName ??
                                              'Interactie',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                            itx.description ?? 'Geen omschrijving'),
                                        const SizedBox(height: 6),
                                        Text(itx.moment.toLocal().toString()),
                                        const SizedBox(height: 6),
                                        Text(
                                            '${itx.lat.toStringAsFixed(5)}, ${itx.lon.toStringAsFixed(5)}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: const Icon(Icons.place, size: 28),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // status chip overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Builder(builder: (context) {
                      final mp = context.watch<MapProvider>();
                      final label = mp.interactionsLoading
                          ? 'Loading…'
                          : (mp.interactionsError != null
                              ? 'Err'
                              : 'Pins: ${mp.interactions.length}');
                      return Chip(label: Text(label));
                    }),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Center on me',
          onPressed: () async {
            final fresh = await _location.determinePosition();
            if (fresh != null) {
              final addr = await _location.getAddressFromPosition(fresh);
              await context
                  .read<MapProvider>()
                  .resetToCurrentLocation(fresh, addr);
              context.read<MapProvider>().mapController.move(
                    LatLng(fresh.latitude, fresh.longitude),
                    16,
                  );
              _queueFetch();
            }
          },
          child: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}
