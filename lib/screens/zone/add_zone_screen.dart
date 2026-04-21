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
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildrapport/widgets/map/wildlifenl_map.dart';
import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';

class AddZoneScreen extends StatefulWidget {
  const AddZoneScreen({super.key});

  @override
  State<AddZoneScreen> createState() => _AddZoneScreenState();
}

class _AddZoneScreenState extends State<AddZoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mapController = fm.MapController();
  static const LatLng _defaultCenter = LatLng(51.69, 5.30);
  List<LatLng> _polygonPoints = [];
  LatLng? _currentLocation;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  DateTime _lastMapTapTime = DateTime(0);
  static const _mapTapDebounceMs = 400;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onMapTap(LatLng point) {
    final now = DateTime.now();
    if (now.difference(_lastMapTapTime).inMilliseconds < _mapTapDebounceMs) return;
    _lastMapTapTime = now;
    setState(() => _polygonPoints.add(point));
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
      if (!MockLocationConfig.kForceMockLocation) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Zet locatievoorziening aan in je telefooninstellingen.'),
              ),
            );
          }
          return;
        }
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Geen toestemming voor locatie. Geef de app toegang in je telefooninstellingen.',
                ),
              ),
            );
          }
          return;
        }
      }

      Position pos;
      if (MockLocationConfig.kForceMockLocation) {
        pos = Position(
          latitude: MockLocationConfig.kMockLat,
          longitude: MockLocationConfig.kMockLon,
          timestamp: DateTime.now(),
          accuracy: 3.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0,
        );
      } else {
        // Eerst cache: vaak direct beschikbaar, dan direct iets tonen
        final cached = await Geolocator.getLastKnownPosition();
        if (cached != null && mounted) {
          final point = LatLng(cached.latitude, cached.longitude);
          setState(() {
            _currentLocation = point;
            _isLoadingLocation = false;
          });
          _mapController.move(point, 16);
          // Op achtergrond verse positie ophalen (lagere nauwkeurigheid = sneller)
          Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 8),
            ),
          ).then((fresh) {
            if (!mounted) return;
            setState(() => _currentLocation = LatLng(fresh.latitude, fresh.longitude));
            _mapController.move(LatLng(fresh.latitude, fresh.longitude), 16);
          }).catchError((_) {});
          return;
        }
        // Geen cache: verse positie (low = sneller, max 8 sec)
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 8),
          ),
        );
      }
      final point = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _currentLocation = point);
      _mapController.move(point, 16);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Huidge locatie kon niet worden opgehaald.')),
      );
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _removeLastPoint() {
    if (_polygonPoints.isEmpty) return;
    setState(() => _polygonPoints.removeLast());
  }

  void _clearPoints() {
    setState(() => _polygonPoints.clear());
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teken minimaal 3 punten op de kaart om een zone te maken.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final definition = _polygonPoints
        .map((p) => ZoneDefinitionPoint(latitude: p.latitude, longitude: p.longitude))
        .toList();
    final request = ZoneCreateRequest(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      definition: definition,
    );

    String? errorMessage;
    Zone? zone;
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.post('zone/', request.toJson(), authenticated: true);

      if (!mounted) return;
      if (response.statusCode == 200) {
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          zone = Zone.fromJson(json);
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
        debugPrint('Zone toevoegen exception: $e\n$st');
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (zone != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zone is toegevoegd.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage ?? 'Zone toevoegen mislukt. Controleer je invoer of probeer later opnieuw.',
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Zone toevoegen',
              rightIcon: null,
              showUserIcon: false,
              onLeftIconPressed: () {
                Navigator.of(context).pop();
              },
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
                  'Teken je zone op de kaart:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: const Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Map area expands to fill available space
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              WildLifeNLMap(
                                mapController: _mapController,
                                options: fm.MapOptions(
                                  initialCenter: _defaultCenter,
                                  initialZoom: 10,
                                  minZoom: 4,
                                  maxZoom: 17,
                                  onTap: (_, point) => _onMapTap(point),
                                  interactionOptions: const fm.InteractionOptions(
                                    flags: fm.InteractiveFlag.drag |
                                        fm.InteractiveFlag.pinchZoom |
                                        fm.InteractiveFlag.doubleTapZoom |
                                        fm.InteractiveFlag.flingAnimation |
                                        fm.InteractiveFlag.pinchMove,
                                  ),
                                ),
                                extraLayers: [
                                  if (_polygonPoints.isNotEmpty)
                                    fm.PolygonLayer(
                                      polygons: [
                                        fm.Polygon(
                                          points: _polygonPoints,
                                          color: AppColors.darkGreen.withValues(alpha: 0.25),
                                          borderStrokeWidth: 2,
                                          borderColor: AppColors.darkGreen,
                                        ),
                                      ],
                                    ),
                                  fm.MarkerLayer(
                                    markers: _polygonPoints.asMap().entries.map((e) {
                                      return fm.Marker(
                                        point: e.value,
                                        width: 24,
                                        height: 24,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.darkGreen,
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${e.key + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                                              color: Colors.blue.withValues(alpha: 0.3),
                                              border: Border.all(color: Colors.blue, width: 3),
                                            ),
                                            child: const Icon(Icons.my_location, color: Colors.blue, size: 22),
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
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                          Text(
                                            'Locatie ophalen…',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 12,
                                left: 12,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _polygonPoints.isEmpty ? null : _removeLastPoint,
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _polygonPoints.isEmpty ? const Color(0xFFCCCCCC) : const Color(0xFF333333),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.undo, size: 24, color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (!_isLoadingLocation) _goToMyLocation();
                                  },
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
                                    child: _isLoadingLocation
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.my_location, size: 24, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        color: AppColors.borderDefault,
                      ),
                      // Point management footer
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.borderDefault,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          child: Row(
                            children: [
                              Text(
                                '${_polygonPoints.length} punt${_polygonPoints.length == 1 ? '' : 'en'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _polygonPoints.isEmpty ? null : _clearPoints,
                                icon: const Icon(Icons.clear_all, size: 18),
                                label: const Text('Wissen'),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                     
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Naam',
                                  hintText: 'Minimaal 2 tekens',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: AppColors.textSecondary),
                                  ),
                                ),
                                validator: (v) {
                                  final s = v?.trim() ?? '';
                                  if (s.length < 2) return 'Naam moet minimaal 2 tekens zijn.';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: 'Beschrijving',
                                  hintText: 'Minimaal 5 tekens',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: AppColors.textSecondary),
                                  ),
                                ),
                                validator: (v) {
                                  final s = v?.trim() ?? '';
                                  if (s.length < 5) return 'Beschrijving moet minimaal 5 tekens zijn.';
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF37A904),
                      disabledBackgroundColor: const Color(0xFFEFEFEF),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFFACACAC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Zone toevoegen',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
