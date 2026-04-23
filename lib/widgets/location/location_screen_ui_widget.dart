import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/location/location_screen_interface.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/managers/map/location_screen_manager.dart';
import 'package:wildrapport/managers/map/location_map_manager.dart';
import 'package:wildrapport/models/enums/date_time_type.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/interfaces/other/permission_interface.dart';
import 'package:wildrapport/widgets/location/location_display.dart';
import 'package:wildrapport/widgets/location/location_map_preview.dart';
import 'package:wildrapport/screens/location/map_screen.dart';
import 'package:wildrapport/widgets/location/custom_location_map_widget.dart';
import 'package:wildrapport/screens/belonging/belonging_location_screen.dart';
import 'package:wildrapport/widgets/location/time_selection_row.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/utils/location_sharing_dialog.dart';
import 'dart:async';

class LocationScreenUIWidget extends StatefulWidget {
  const LocationScreenUIWidget({super.key});

  @override
  State<LocationScreenUIWidget> createState() => _LocationScreenUIWidgetState();
}

class _LocationScreenUIWidgetState extends State<LocationScreenUIWidget> {
  late final LocationServiceInterface _locationService;
  late final MapProvider _mapProvider;
  bool _useCurrentChecked = false;

  @override
  void initState() {
    super.initState();
    _locationService = LocationMapManager();
    _mapProvider = context.read<MapProvider>();
    final appState = context.read<AppStateProvider>();
    if (!appState.isLocationTrackingEnabled) {
      _mapProvider.clearUserLocationAndStopTracking();
    }
    _initializeMap();
  }

  // Add listener for map provider changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeMap() async {
    if (!mounted) return;

    final appState = context.read<AppStateProvider>();
    if (!appState.isLocationTrackingEnabled) {
      _mapProvider.clearUserLocationAndStopTracking();
      _updateMapViewToDefault();
      return;
    }

    if (_mapProvider.selectedPosition != null) {
      _mapProvider.updatePosition(
        _mapProvider.selectedPosition!,
        _mapProvider.selectedAddress,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMapView(_mapProvider.selectedPosition!);
      });
      return;
    }

    if (appState.isLocationCacheValid && appState.cachedPosition != null) {
      final position = appState.cachedPosition!;
      final address = appState.cachedAddress ?? '';
      if (_locationService.isLocationInNetherlands(
        position.latitude,
        position.longitude,
      )) {
        _mapProvider.updatePosition(position, address);
        _updateMapView(position);
        return;
      }
    }

    // No cached location yet: fetch current GPS immediately so report map opens on user.
    final Position? freshPosition = await _locationService.determinePosition();
    if (!mounted) return;
    if (freshPosition != null &&
        _locationService.isLocationInNetherlands(
          freshPosition.latitude,
          freshPosition.longitude,
        )) {
      final address = await _locationService.getAddressFromPosition(freshPosition);
      if (!mounted) return;
      _mapProvider.updatePosition(freshPosition, address);
      _updateMapView(freshPosition);
      return;
    }

    _updateMapViewToDefault();
  }

  void _updateMapViewToDefault() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      while (mounted && !_mapProvider.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      if (!mounted) return;
      try {
        final center = LatLng(51.69, 5.30);
        _mapProvider.mapController.move(center, 7);
      } catch (_) {}
    });
  }

  // Helper method to update map view
  Future<void> _updateMapView(Position position) async {
    // Schedule the map update for after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      while (mounted && (!_mapProvider.isInitialized)) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      if (!mounted) return;

      try {
        _mapProvider.mapController.move(
          LatLng(position.latitude, position.longitude),
          15,
        );
      } catch (e) {
        debugPrint('Error moving map: $e');
      }
    });
  }

  // Dropdown selection removed; interaction handled via map preview expand button

  // Navigation handled by LocationMapPreview expand button

  void _handleLocationIconTap() {
    debugPrint('Location icon tapped in LocationScreenUIWidget');
  }

  Future<void> _applyCurrentAsSelected() async {
    final appState = context.read<AppStateProvider>();
    final permissionManager = context.read<PermissionInterface>();
    final granted =
        await permissionManager.isPermissionGranted(PermissionType.location);
    if (!granted) {
      final ok = await permissionManager.requestPermission(
        context,
        PermissionType.location,
        showRationale: true,
      );
      if (!ok || !mounted) return;
    }

    if (!appState.isLocationTrackingEnabled) {
      await appState.setLocationTrackingEnabled(true);
      if (!mounted) return;
    }

    final Position? pos = await _locationService.determinePosition();
    if (!mounted) return;
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Huidige locatie niet beschikbaar')),
      );
      return;
    }
    final address = await _locationService.getAddressFromPosition(pos);
    if (!mounted) return;
    context.read<MapProvider>().setSelectedLocation(pos, address);
    await _updateMapView(pos);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Huidige locatie geselecteerd')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (!context.watch<AppStateProvider>().isLocationTrackingEnabled)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 22, color: Colors.orange.shade800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Locatie delen staat uit. Zet het aan in je profiel om je huidige locatie te gebruiken, of kies een plek op de kaart.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade900,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecteer locatie',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 160,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.brown.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async {
                          final newValue = !_useCurrentChecked;
                          if (newValue) {
                            final appState = context.read<AppStateProvider>();
                            if (!appState.isLocationTrackingEnabled) {
                              final enable =
                                  await showLocationSharingOffDialog(context);
                              if (!mounted) return;
                              if (enable != true) return;
                              await appState.setLocationTrackingEnabled(true);
                              if (!mounted) return;
                            }
                            setState(() => _useCurrentChecked = true);
                            await _applyCurrentAsSelected();
                          } else {
                            setState(() => _useCurrentChecked = false);
                          }
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: _useCurrentChecked,
                              onChanged: (v) async {
                                if (v != true) {
                                  setState(() => _useCurrentChecked = false);
                                  return;
                                }
                                final appState =
                                    context.read<AppStateProvider>();
                                if (!appState.isLocationTrackingEnabled) {
                                  final enable =
                                      await showLocationSharingOffDialog(
                                    context,
                                  );
                                  if (!mounted) return;
                                  if (enable != true) return;
                                  await appState.setLocationTrackingEnabled(
                                    true,
                                  );
                                  if (!mounted) return;
                                }
                                setState(() => _useCurrentChecked = true);
                                _applyCurrentAsSelected();
                              },
                            ),
                            const Text('Huidige locatie'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_useCurrentChecked) {
                            return;
                          }
                          final appState = context.read<AppStateProvider>();
                          if (!appState.isLocationTrackingEnabled) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Locatie delen staat uit. Zet het aan in je profiel om je locatie te zien. Je kunt wel een plek op de kaart aanwijzen.',
                                ),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          }
                          final isFromPossession =
                              ModalRoute.of(context)?.settings.name ==
                                  'PossesionLocationScreen' ||
                              context
                                      .findAncestorWidgetOfExactType<
                                        BelongingLocationScreen
                                      >() !=
                                  null;

                          if (!context.mounted) return;
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
                        child: const Text('Selecteer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Vink Huidige locatie aan voor je GPS-positie, of kies Selecteer om een plek op de kaart te kiezen.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const LocationMapPreview(),
                  LocationDisplay(
                    onLocationIconTap: _handleLocationIconTap,
                    locationText:
                        context.watch<MapProvider>().selectedAddress.isNotEmpty
                            ? context.watch<MapProvider>().selectedAddress
                            : (context.watch<AppStateProvider>().isLocationTrackingEnabled
                                ? ''
                                : 'Locatie delen staat uit'),
                    isLoading:
                        context.watch<AppStateProvider>().isLocationTrackingEnabled &&
                        context.watch<MapProvider>().selectedAddress.isEmpty,
                    position:
                        context.watch<MapProvider>().selectedPosition ??
                        (context.watch<AppStateProvider>().isLocationTrackingEnabled
                            ? context.watch<MapProvider>().currentPosition
                            : null),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datum en tijd',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 130,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.brown.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TimeSelectionRow(
              initialSelection:
                  context.read<LocationScreenInterface>().selectedDateTime,
              initialDate:
                  context.read<LocationScreenInterface>().customDateTime,
              onOptionSelected: (selectedOption) {
                final locationManager = context.read<LocationScreenInterface>();
                if (locationManager is LocationScreenManager) {
                  locationManager.updateDateTime(selectedOption);
                }
              },
              onDateSelected: (date) {
                final locationManager = context.read<LocationScreenInterface>();
                if (locationManager is LocationScreenManager) {
                  locationManager.updateDateTime(
                    DateTimeType.custom.displayText,
                    date: date,
                  );
                }
              },
              onTimeSelected: (time) {
                final locationManager = context.read<LocationScreenInterface>();
                if (locationManager is LocationScreenManager) {
                  locationManager.updateDateTime(
                    DateTimeType.custom.displayText,
                    time: time,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
