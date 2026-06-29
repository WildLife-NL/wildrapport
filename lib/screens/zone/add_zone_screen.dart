import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/config/mock_location.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/button_layout.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/utils/location_sharing_dialog.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/map/wildlifenl_map.dart';
import 'package:wildrapport/utils/zone_api_parser.dart';
import 'package:wildrapport/utils/zone_map_utils.dart';
import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';

class AddZoneScreen extends StatefulWidget {
  const AddZoneScreen({super.key, this.existingZone});

  final Zone? existingZone;

  @override
  State<AddZoneScreen> createState() => _AddZoneScreenState();
}

class _AddZoneScreenState extends State<AddZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _mapController = fm.MapController();

  static const LatLng _fallbackCenter = LatLng(52.15, 5.38);
  LatLng _mapCenter = _fallbackCenter;

  List<LatLng> _polygonPoints = [];
  LatLng? _currentLocation;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  DateTime _lastMapTapTime = DateTime(0);

  static const _mapTapDebounceMs = 400;

  bool get _isEditing => widget.existingZone != null;

  @override
  void initState() {
    super.initState();
    _initFromExistingZone();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing && _polygonPoints.length >= 3) {
        _centerMapOnPolygon();
      } else {
        _loadInitialMapCenter();
      }
    });
  }

  void _initFromExistingZone() {
    final zone = widget.existingZone;
    if (zone == null) return;

    _nameController.text = zone.name;

    final def = zone.definition;
    if (def == null || def.isEmpty) return;

    _polygonPoints = def.map((p) => LatLng(p.latitude, p.longitude)).toList();

    final center = centroidOfPoints(_polygonPoints);
    if (center != null) _mapCenter = center;
  }

  void _centerMapOnPolygon() {
    final bounds = boundsForPoints(_polygonPoints);
    if (bounds == null) return;

    try {
      _mapController.fitCamera(
        fm.CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(48),
          maxZoom: 17,
          minZoom: 4,
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng point) {
    final now = DateTime.now();

    if (now.difference(_lastMapTapTime).inMilliseconds < _mapTapDebounceMs) {
      return;
    }

    _lastMapTapTime = now;
    setState(() => _polygonPoints.add(point));
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

_mapController.move(center, 16);
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

      _mapController.move(point, 16);
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
      if (MockLocationConfig.kForceMockLocation) {
        return const LatLng(
          MockLocationConfig.kMockLat,
          MockLocationConfig.kMockLon,
        );
      }

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

  void _removeLastPoint() {
    if (_polygonPoints.isEmpty) return;
    setState(() => _polygonPoints.removeLast());
  }

  void _clearPoints() {
    setState(() => _polygonPoints.clear());
  }

  Map<String, dynamic> _buildZoneRequestBody(
    List<ZoneDefinitionPoint> definition,
  ) {
    return {
      'name': _nameController.text.trim(),
      'definition': definition.map((e) => e.toJson()).toList(),
    };
  }

  List<ZoneDefinitionPoint> _currentDefinition() {
    return _polygonPoints
        .map(
          (p) => ZoneDefinitionPoint(
            latitude: p.latitude,
            longitude: p.longitude,
          ),
        )
        .toList();
  }

  bool _hasZoneChanges(List<ZoneDefinitionPoint> definition) {
    final existing = widget.existingZone;
    if (existing == null) return true;

    if (_nameController.text.trim() != existing.name.trim()) return true;
    return !zoneDefinitionsEqual(existing.definition, definition);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Teken minimaal 3 punten op de kaart om een zone te maken.',
          ),
        ),
      );
      return;
    }

    final definition = _currentDefinition();

    if (_isEditing && !_hasZoneChanges(definition)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen wijzigingen om op te slaan.')),
      );
      Navigator.of(context).pop(true);
      return;
    }

    if (_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Zone bewerken wordt nog niet ondersteund door de server. '
            'Maak eventueel een nieuwe zone aan.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final body = _buildZoneRequestBody(definition);

    String? errorMessage;
    Zone? zone;

    try {
      final apiClient = context.read<ApiClient>();
      final http.Response response = await apiClient.post(
        'zone/',
        body,
        authenticated: true,
      );

      if (!mounted) return;

      if (isSuccessfulHttpStatus(response.statusCode)) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          zone = zoneFromApiJson(json);
        } catch (_) {
          errorMessage = 'Ongeldig antwoord van de server.';
        }
      } else {
        String body = response.body;
        if (body.length > 200) body = '${body.substring(0, 200)}...';
        errorMessage = 'Fout ${response.statusCode}: $body';
      }
    } catch (e, st) {
      if (mounted) {
        errorMessage = e.toString();
        debugPrint('Zone opslaan exception: $e\n$st');
      }
    }

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (zone != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Zone is bijgewerkt.' : 'Zone is toegevoegd.',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage ??
                (_isEditing
                    ? 'Zone bewerken mislukt. Probeer het later opnieuw.'
                    : 'Zone toevoegen mislukt. Controleer je invoer of probeer later opnieuw.'),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: _isEditing ? 'Zone bewerken' : 'Zone toevoegen',
              rightIcon: null,
              showUserIcon: false,
              onLeftIconPressed: () => Navigator.of(context).pop(),
              iconColor: AppColors.textPrimary,
              textColor: AppColors.textPrimary,
              fontScale: 1.4,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 12, 0, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Klik op de kaart om punten te\nmarkeren en zo je zone af te bakenen:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: AppColors.borderDefault,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Teken je zone op de kaart',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tik op de kaart om punten te zetten (min. 3). Gebruik "Huidige locatie" om naar je positie te gaan.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkGrey,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 280,
                                  child: Stack(
                                    children: [
                                      WildLifeNLMap(
                                        mapController: _mapController,
                                        options: fm.MapOptions(
                                          initialCenter: _mapCenter,
                                          initialZoom: 14,
                                          minZoom: 4,
                                          maxZoom: 17,
                                          onTap: (_, point) =>
                                              _onMapTap(point),
                                          interactionOptions:
                                              const fm.InteractionOptions(
                                            flags: fm.InteractiveFlag.drag |
                                                fm.InteractiveFlag.pinchZoom |
                                                fm.InteractiveFlag
                                                    .doubleTapZoom |
                                                fm.InteractiveFlag
                                                    .flingAnimation |
                                                fm.InteractiveFlag.pinchMove,
                                          ),
                                        ),
                                        extraLayers: [
                                          if (_polygonPoints.isNotEmpty)
                                            fm.PolygonLayer(
                                              polygons: [
                                                fm.Polygon(
                                                  points: _polygonPoints,
                                                  color: AppColors.primaryGreen
                                                      .withValues(alpha: 0.25),
                                                  borderStrokeWidth: 2,
                                                  borderColor:
                                                      AppColors.primaryGreen,
                                                ),
                                              ],
                                            ),
                                          if (_polygonPoints.isNotEmpty)
                                            fm.MarkerLayer(
                                              markers: _polygonPoints
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                final index = entry.key;
                                                final point = entry.value;

                                                return fm.Marker(
                                                  point: point,
                                                  width: 35,
                                                  height: 35,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors
                                                          .primaryGreen,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          if (_currentLocation != null)
                                            fm.MarkerLayer(
                                              markers: [
                                                fm.Marker(
                                                  point: _currentLocation!,
                                                  width: 36,
                                                  height: 36,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: AppColors
                                                          .liveLocation,
                                                      border: Border.all(
                                                        color: AppColors
                                                            .liveLocation,
                                                        width: 3,
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.my_location,
                                                      color: Colors.blue,
                                                      size: 22,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      if (_isLoadingLocation)
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.black26,
                                            child: const Center(
                                              child: SizedBox(
                                                width: 40,
                                                height: 40,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: _polygonPoints.isEmpty
                                              ? null
                                              : _removeLastPoint,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.darkCharcoal,
                                            ),
                                            child: const Icon(
                                              Icons.undo,
                                              size: 24,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        right: 12,
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: _isLoadingLocation
                                              ? null
                                              : _goToMyLocation,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.darkCharcoal,
                                            ),
                                            child: _isLoadingLocation
                                                ? const Padding(
                                                    padding:
                                                        EdgeInsets.all(12),
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.my_location,
                                                    size: 24,
                                                    color: Colors.white,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Text(
                                    '${_polygonPoints.length} punt${_polygonPoints.length == 1 ? '' : 'en'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.brown900,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    onPressed: _polygonPoints.isEmpty
                                        ? null
                                        : _removeLastPoint,
                                    icon: const Icon(Icons.undo, size: 18),
                                    label: const Text('Ongedaan'),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          AppColors.primaryGreen,
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: _polygonPoints.isEmpty
                                        ? null
                                        : _clearPoints,
                                    icon:
                                        const Icon(Icons.clear_all, size: 18),
                                    label: const Text('Wissen'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _nameController,
                                focusNode: _nameFocusNode,
                                scrollPadding:
                                    const EdgeInsets.only(bottom: 260),
                                onTap: () {
                                  Future.delayed(
                                    const Duration(milliseconds: 350),
                                    () {
                                      if (!mounted) return;

                                      Scrollable.ensureVisible(
                                        context,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                        alignment: 0.15,
                                      );
                                    },
                                  );
                                },
                                decoration: InputDecoration(
                                  labelText: 'Naam',
                                  hintText: 'Minimaal 2 tekens',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderDefault,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  final s = v?.trim() ?? '';
                                  if (s.length < 2) {
                                    return 'Naam moet minimaal 2 tekens zijn.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: primaryButtonHeight(context),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_isEditing ? 'Zone opslaan' : 'Zone toevoegen'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}