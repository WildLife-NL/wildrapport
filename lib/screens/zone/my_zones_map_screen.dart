import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/config/mock_location.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/utils/location_sharing_dialog.dart';
import 'package:wildrapport/utils/responsive_utils.dart';
import 'package:wildrapport/models/api_models/species.dart';
import 'package:wildrapport/screens/zone/add_zone_screen.dart';
import 'package:wildrapport/screens/zone/species_grid_picker_screen.dart';
import 'package:wildrapport/utils/zone_api_parser.dart';
import 'package:wildrapport/utils/zone_map_utils.dart';
import 'package:wildrapport/widgets/map/wildlifenl_map.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/zone/zone_species_silhouettes_row.dart';
import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';

class MyZonesMapScreen extends StatefulWidget {
  const MyZonesMapScreen({super.key});

  @override
  State<MyZonesMapScreen> createState() => _MyZonesMapScreenState();
}

class _MyZonesMapScreenState extends State<MyZonesMapScreen> {
  static const LatLng _fallbackCenter = LatLng(52.15, 5.38);

  final _mapController = fm.MapController();
  List<Zone> _zones = [];
  Map<String, List<ZoneSpeciesRef>> _speciesByZoneId = {};
  bool _loading = true;
  bool _actionInProgress = false;
  String? _loadError;
  LatLng _mapCenter = _fallbackCenter;
  LatLng? _currentLocation;
  bool _isLoadingLocation = false;
  bool _mapReady = false;
  bool _pendingFitToZones = false;
  String? _selectedZoneId;

  List<Zone> get _activeZones => _zones.where(isActiveZone).toList();

  List<Zone> get _drawableZones =>
      _activeZones.where(zoneHasDrawablePolygon).toList();

  /// Zelfde zones als op de kaart.
  List<Zone> get _listZones => _drawableZones;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadZones());
  }

  @override
  void dispose() {
    _mapReady = false;
    _mapController.dispose();
    super.dispose();
  }

  void _onMapReady() {
    if (!mounted) return;
    setState(() => _mapReady = true);
    if (_pendingFitToZones) {
      _pendingFitToZones = false;
      _fitMapToZones();
    }
  }

  void _safeMoveMap(LatLng center, double zoom) {
    if (!_mapReady || !mounted) return;
    try {
      _mapController.move(center, zoom);
    } catch (_) {}
  }

  void _safeFitCamera(fm.CameraFit fit) {
    if (!_mapReady || !mounted) return;
    try {
      _mapController.fitCamera(fit);
    } catch (_) {}
  }

  Future<void> _loadZones() async {
    final apiClient = context.read<ApiClient>();
    try {
      final response = await apiClient.get('zones/me/', authenticated: true);
      var zones = <Zone>[];
      var speciesByZoneId = <String, List<ZoneSpeciesRef>>{};
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        // zones/me/ is already scoped to the logged-in user; avoid over-filtering.
        final loaded = loadZonesWithSpeciesFromApi(list, null);
        zones = loaded.zones;
        speciesByZoneId = loaded.speciesByZoneId;
      }
      if (!mounted) return;
      setState(() {
        _zones = zones;
        _speciesByZoneId = speciesByZoneId;
        _loading = false;
        _loadError = null;
        _selectedZoneId = null;
      });
      if (_drawableZones.isNotEmpty) {
        _fitMapToZones();
      } else {
        await _loadInitialMapCenter();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  void _fitMapToZones() {
    if (!_mapReady) {
      _pendingFitToZones = true;
      return;
    }
    final points = _drawableZones.expand(zoneDefinitionToPoints);
    final bounds = boundsForPoints(points);
    if (bounds == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeFitCamera(
        fm.CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.fromLTRB(40, 56, 40, 120),
          maxZoom: 16,
          minZoom: 4,
        ),
      );
    });
  }

  void _fitCameraToZone(Zone zone) {
    final bounds = boundsForPoints(zoneDefinitionToPoints(zone));
    if (bounds == null) return;
    _safeFitCamera(
      fm.CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(72),
        maxZoom: 17,
        minZoom: 4,
      ),
    );
  }

  void _toggleZoneSelection(Zone zone) {
    if (_selectedZoneId == zone.id) {
      setState(() => _selectedZoneId = null);
      return;
    }
    setState(() => _selectedZoneId = zone.id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fitCameraToZone(zone);
    });
  }

  Future<void> _editZone(Zone zone) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddZoneScreen(existingZone: zone)),
    );
    if (saved == true) await _loadZones();
  }

  Future<void> _addSpeciesToZone(Zone zone) async {
    final species = await Navigator.of(context).push<Species>(
      MaterialPageRoute(
        builder: (_) => const SpeciesGridPickerScreen(
          title: 'Dier toevoegen aan zone',
        ),
      ),
    );
    if (species == null || !mounted) return;

    setState(() => _actionInProgress = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.post(
        'zone/species/',
        {'zoneID': zone.id, 'speciesID': species.id},
        authenticated: true,
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${species.commonName} toegevoegd aan ${zone.name}.')),
        );
        await _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dier toevoegen mislukt.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _deactivateZone(Zone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zone verwijderen'),
        content: Text(
          'Weet je zeker dat je "${zone.name}" wilt deactiveren? '
          'Dit kan niet ongedaan worden gemaakt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _actionInProgress = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.delete(
        'zone/${zone.id}',
        authenticated: true,
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        if (_selectedZoneId == zone.id) {
          setState(() => _selectedZoneId = null);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zone is gedeactiveerd.')),
        );
        await _loadZones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zone verwijderen mislukt.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _actionInProgress = false);
    }
  }

  Future<void> _loadInitialMapCenter() async {
    setState(() => _isLoadingLocation = true);
    var point = await _resolveDeviceLocation(
      preferCached: true,
      requestPermissionIfDenied: false,
    );
    point ??= await _resolveDeviceLocation(
      preferCached: false,
      requestPermissionIfDenied: false,
    );
    if (!mounted) return;
    setState(() => _isLoadingLocation = false);
    final center = point;
    if (center == null) return;
    setState(() {
      _currentLocation = center;
      _mapCenter = center;
    });
    _safeMoveMap(center, 14);
  }

  Future<void> _goToMyLocation() async {
    if (_isLoadingLocation) return;
    final appState = context.read<AppStateProvider>();
    if (!appState.isLocationTrackingEnabled) {
      final enable = await showLocationSharingOffDialog(context);
      if (!mounted || enable != true) return;
      await appState.setLocationTrackingEnabled(true);
      if (!mounted) return;
    }

    setState(() => _isLoadingLocation = true);
    try {
      final point = await _resolveDeviceLocation(
        preferCached: true,
        requestPermissionIfDenied: true,
        showErrors: true,
      );
      if (!mounted || point == null) return;
      setState(() {
        _currentLocation = point;
        _mapCenter = point;
      });
      _safeMoveMap(point, 16);
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  Future<LatLng?> _resolveDeviceLocation({
    bool preferCached = false,
    bool requestPermissionIfDenied = false,
    bool showErrors = false,
  }) async {
    try {
      if (!MockLocationConfig.kForceMockLocation) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (showErrors && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Zet locatievoorziening aan in je telefooninstellingen.',
                ),
              ),
            );
          }
          return null;
        }
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied &&
            requestPermissionIfDenied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (showErrors && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Geen toestemming voor locatie. Geef de app toegang in je telefooninstellingen.',
                ),
              ),
            );
          }
          return null;
        }
      }

      if (MockLocationConfig.kForceMockLocation) {
        return const LatLng(
          MockLocationConfig.kMockLat,
          MockLocationConfig.kMockLon,
        );
      }

      if (preferCached) {
        final cached = await Geolocator.getLastKnownPosition();
        if (cached != null) {
          return LatLng(cached.latitude, cached.longitude);
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      if (showErrors && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Huidige locatie kon niet worden opgehaald.'),
          ),
        );
      }
      return null;
    }
  }

  List<fm.Polygon> _buildZonePolygons() {
    return _drawableZones.map((zone) {
      final points = zoneDefinitionToPoints(zone);
      final selected = zone.id == _selectedZoneId;
      return fm.Polygon(
        points: points,
        color: selected
            ? AppColors.primaryGreen.withValues(alpha: 0.35)
            : Colors.grey.shade400.withValues(alpha: 0.18),
        borderStrokeWidth: selected ? 4 : 1.5,
        borderColor: selected ? AppColors.primaryGreen : Colors.grey.shade500,
      );
    }).toList();
  }

  List<fm.Marker> _buildZoneLabelMarkers() {
    return _drawableZones.map((zone) {
      final points = zoneDefinitionToPoints(zone);
      final center = centroidOfPoints(points);
      if (center == null) return null;
      final selected = zone.id == _selectedZoneId;
      return fm.Marker(
        point: center,
        width: 110,
        height: 28,
        alignment: Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggleZoneSelection(zone),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.primaryGreen : AppColors.borderDefault,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              zone.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }).whereType<fm.Marker>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final titleScale = responsive.breakpointValue<double>(
      small: 1.4,
      medium: 1.3,
      large: 1.2,
      extraLarge: 1.15,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Mijn zones',
              rightIcon: null,
              showUserIcon: false,
              onLeftIconPressed: () => Navigator.of(context).pop(),
              iconColor: AppColors.textPrimary,
              textColor: AppColors.textPrimary,
              fontScale: titleScale,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.wp(5),
                  responsive.hp(0.6),
                  responsive.wp(5),
                  responsive.hp(1.2),
                ),
                child: _loading
                    ? const _ZonesContentCard(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    : _loadError != null
                    ? _ZonesContentCard(
                        child: _ErrorBody(
                          message: _loadError!,
                          onRetry: () {
                            setState(() {
                              _loading = true;
                              _loadError = null;
                            });
                            _loadZones();
                          },
                        ),
                      )
                    : _listZones.isEmpty
                    ? _ZonesContentCard(
                        child: _EmptyBody(
                          hasZones: _zones.isNotEmpty,
                          onRetry: _loadZones,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _ZonesContentCard(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _MapBody(
                                    mapController: _mapController,
                                    mapCenter: _mapCenter,
                                    polygons: _buildZonePolygons(),
                                    labelMarkers: _buildZoneLabelMarkers(),
                                    currentLocation: _currentLocation,
                                    isLoadingLocation: _isLoadingLocation,
                                    mapReady: _mapReady,
                                    onMapReady: _onMapReady,
                                    onGoToMyLocation: _goToMyLocation,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: responsive.hp(0.6)),
                          Expanded(
                            child: _ZonesListPanel(
                              zones: _listZones,
                              speciesByZoneId: _speciesByZoneId,
                              selectedZoneId: _selectedZoneId,
                              actionsEnabled: !_actionInProgress,
                              onZoneSelected: _toggleZoneSelection,
                              onEditZone: _editZone,
                              onAddSpecies: _addSpeciesToZone,
                              onDeleteZone: _deactivateZone,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White card shell matching other Zone's screens.
class _ZonesContentCard extends StatelessWidget {
  const _ZonesContentCard({
    required this.child,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.zero,
      color: Colors.white,
      clipBehavior: clipBehavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      child: child,
    );
  }
}

class _MapBody extends StatelessWidget {
  const _MapBody({
    required this.mapController,
    required this.mapCenter,
    required this.polygons,
    required this.labelMarkers,
    required this.currentLocation,
    required this.isLoadingLocation,
    required this.mapReady,
    required this.onMapReady,
    required this.onGoToMyLocation,
  });

  final fm.MapController mapController;
  final LatLng mapCenter;
  final List<fm.Polygon> polygons;
  final List<fm.Marker> labelMarkers;
  final LatLng? currentLocation;
  final bool isLoadingLocation;
  final bool mapReady;
  final VoidCallback onMapReady;
  final VoidCallback onGoToMyLocation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: WildLifeNLMap(
          mapController: mapController,
          options: fm.MapOptions(
            initialCenter: mapCenter,
            initialZoom: 12,
            minZoom: 4,
            maxZoom: 17,
            interactionOptions: fm.InteractionOptions(
              flags: mapReady
                  ? fm.InteractiveFlag.all & ~fm.InteractiveFlag.rotate
                  : fm.InteractiveFlag.none,
            ),
            onMapReady: onMapReady,
          ),
          userAgentPackageName: 'nl.wildlife.rapport',
          extraLayers: [
            fm.PolygonLayer(polygons: polygons),
            fm.MarkerLayer(markers: labelMarkers),
            if (currentLocation != null)
              fm.MarkerLayer(
                markers: [
                  fm.Marker(
                    point: currentLocation!,
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    child: const _GoogleMapsLocationDot(size: 22),
                  ),
                ],
              ),
          ],
          ),
        ),
        if (isLoadingLocation)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33000000),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 12,
          right: 12,
          child: _MapFab(
            onTap: isLoadingLocation ? null : onGoToMyLocation,
            loading: isLoadingLocation,
          ),
        ),
      ],
    );
  }
}

class _ZonesListPanel extends StatelessWidget {
  const _ZonesListPanel({
    required this.zones,
    required this.speciesByZoneId,
    required this.selectedZoneId,
    required this.actionsEnabled,
    required this.onZoneSelected,
    required this.onEditZone,
    required this.onAddSpecies,
    required this.onDeleteZone,
  });

  final List<Zone> zones;
  final Map<String, List<ZoneSpeciesRef>> speciesByZoneId;
  final String? selectedZoneId;
  final bool actionsEnabled;
  final void Function(Zone zone) onZoneSelected;
  final void Function(Zone zone) onEditZone;
  final void Function(Zone zone) onAddSpecies;
  final void Function(Zone zone) onDeleteZone;

  @override
  Widget build(BuildContext context) {
    return _ZonesContentCard(
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'Jouw zones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              '${zones.length} zone${zones.length == 1 ? '' : 's'} · tik om te selecteren',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: zones.isEmpty
                ? const Center(
                    child: Text(
                      'Geen zones gevonden',
                      style: TextStyle(color: AppColors.darkGrey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    physics: const BouncingScrollPhysics(),
                    itemCount: zones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final zone = zones[index];
                      final selected = zone.id == selectedZoneId;
                      return _ZoneCard(
                        zone: zone,
                        species: speciesByZoneId[zone.id] ?? const [],
                        selected: selected,
                        actionsEnabled: actionsEnabled,
                        onTap: () => onZoneSelected(zone),
                        onEdit: () => onEditZone(zone),
                        onAddSpecies: () => onAddSpecies(zone),
                        onDelete: () => onDeleteZone(zone),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.zone,
    required this.species,
    required this.selected,
    required this.actionsEnabled,
    required this.onTap,
    required this.onEdit,
    required this.onAddSpecies,
    required this.onDelete,
  });

  final Zone zone;
  final List<ZoneSpeciesRef> species;
  final bool selected;
  final bool actionsEnabled;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onAddSpecies;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final areaLabel = formatZoneArea(zone);
    final speciesLabel = formatSpeciesCount(species.length);
    final nameColor = selected ? Colors.white : AppColors.textPrimary;
    final metaColor =
        selected ? Colors.white.withValues(alpha: 0.92) : Colors.grey.shade700;

    return Material(
      elevation: selected ? 8 : 2,
      shadowColor: selected
          ? AppColors.primaryGreen.withValues(alpha: 0.45)
          : Colors.black12,
      borderRadius: BorderRadius.circular(16),
      color: selected ? AppColors.primaryGreen : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Geselecteerd',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 20,
                    color: selected ? Colors.white : AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      zone.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: nameColor,
                      ),
                    ),
                  ),
                  _ZoneActionsMenu(
                    enabled: actionsEnabled,
                    onDarkBackground: selected,
                    onEdit: onEdit,
                    onDelete: onDelete,
                    onAddSpecies: onAddSpecies,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (species.isNotEmpty)
                    ZoneSpeciesSilhouettesRow(
                      species: species,
                      iconSize: 30,
                      iconOnDarkBackground: selected,
                    )
                  else
                    Icon(Icons.pets_outlined, size: 26, color: metaColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      speciesLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: metaColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.square_foot_outlined, size: 16, color: metaColor),
                  const SizedBox(width: 6),
                  Text(
                    areaLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: metaColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneActionsMenu extends StatelessWidget {
  const _ZoneActionsMenu({
    required this.enabled,
    required this.onDarkBackground,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSpecies,
  });

  final bool enabled;
  final bool onDarkBackground;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddSpecies;

  @override
  Widget build(BuildContext context) {
    final iconColor = onDarkBackground ? Colors.white : AppColors.textPrimary;
    return PopupMenuButton<String>(
      enabled: enabled,
      icon: Icon(Icons.more_vert, color: iconColor, size: 22),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
          case 'delete':
            onDelete();
          case 'add':
            onAddSpecies();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: _ZoneMenuRow(icon: Icons.edit_outlined, label: 'Bewerken'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: _ZoneMenuRow(
            icon: Icons.delete_outline,
            label: 'Verwijderen',
            color: Colors.red,
          ),
        ),
        const PopupMenuItem(
          value: 'add',
          child: _ZoneMenuRow(
            icon: Icons.add,
            label: 'Dier toevoegen',
          ),
        ),
      ],
    );
  }
}

class _ZoneMenuRow extends StatelessWidget {
  const _ZoneMenuRow({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.textPrimary),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.onTap,
    this.loading = false,
  });

  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF333333),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: loading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.my_location, size: 24, color: Colors.white),
      ),
    );
  }
}

/// Blue dot with light halo, similar to Google Maps current-location marker.
class _GoogleMapsLocationDot extends StatelessWidget {
  const _GoogleMapsLocationDot({required this.size});

  final double size;

  static const Color _googleBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    final halo = size * 1.45;
    final core = size * 0.42;
    return SizedBox(
      width: halo,
      height: halo,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: halo,
            height: halo,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _googleBlue.withValues(alpha: 0.22),
            ),
          ),
          Container(
            width: core,
            height: core,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _googleBlue,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.hasZones, required this.onRetry});

  final bool hasZones;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 48,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasZones
                  ? 'Je zones hebben geen geldige kaartomtrek.'
                  : 'Nog geen eigen zones',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasZones
                  ? 'Controleer of je zone minimaal drie punten heeft.'
                  : 'Voeg een zone toe en teken minimaal drie punten op de kaart.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Opnieuw laden'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Zones laden mislukt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Opnieuw proberen'),
            ),
          ],
        ),
      ),
    );
  }
}
