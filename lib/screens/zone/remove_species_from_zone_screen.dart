import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/zone/zones_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';

class ZoneSpeciesItem {
  final String id;
  final String commonName;
  ZoneSpeciesItem({required this.id, required this.commonName});
}

class RemoveSpeciesFromZoneScreen extends StatefulWidget {
  const RemoveSpeciesFromZoneScreen({super.key});

  @override
  State<RemoveSpeciesFromZoneScreen> createState() => _RemoveSpeciesFromZoneScreenState();
}

class _RemoveSpeciesFromZoneScreenState extends State<RemoveSpeciesFromZoneScreen> {
  Zone? _selectedZone;
  List<Zone> _zones = [];
  Map<String, List<ZoneSpeciesItem>> _zoneIdToSpecies = {};
  ZoneSpeciesItem? _selectedSpecies;
  bool _loading = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    final apiClient = context.read<ApiClient>();
    try {
      final response = await apiClient.get('zones/me/', authenticated: true);
      List<Zone> zones = [];
      Map<String, List<ZoneSpeciesItem>> zoneIdToSpecies = {};
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        for (final e in list) {
          final json = e as Map<String, dynamic>;
          zones.add(Zone.fromJson(json));
          final zoneId = json['ID'] as String?;
          if (zoneId != null && json['species'] != null) {
            final speciesList = json['species'] as List;
            zoneIdToSpecies[zoneId] = speciesList.map((s) {
              final m = s as Map<String, dynamic>;
              return ZoneSpeciesItem(
                id: m['ID'] as String? ?? '',
                commonName: m['commonName'] as String? ?? '',
              );
            }).toList();
          } else if (zoneId != null) {
            zoneIdToSpecies[zoneId] = [];
          }
        }
      }
      if (mounted) {
        setState(() {
          _zones = zones;
          _zoneIdToSpecies = zoneIdToSpecies;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<ZoneSpeciesItem> get _currentZoneSpecies {
    if (_selectedZone == null) return [];
    return _zoneIdToSpecies[_selectedZone!.id] ?? [];
  }

  Future<void> _submit() async {
    if (_selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies een zone.')),
      );
      return;
    }
    if (_selectedSpecies == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies een dier om te verwijderen.')),
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    String? errorMessage;
    bool success = false;
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.put(
        'zone/species/',
        {'zoneID': _selectedZone!.id, 'speciesID': _selectedSpecies!.id},
        authenticated: true,
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        success = true;
      } else {
        String body = response.body;
        if (body.length > 200) body = '${body.substring(0, 200)}...';
        errorMessage = 'Fout ${response.statusCode}: $body';
      }
    } catch (e, st) {
      if (mounted) {
        errorMessage = e.toString();
        debugPrint('Remove species from zone exception: $e\n$st');
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dier is uit de zone verwijderd.')),
      );
      await _loadZones();
      if (!mounted) return;
      setState(() {
        _selectedSpecies = null;
        if (_currentZoneSpecies.isEmpty) _selectedZone = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Verwijderen mislukt.'),
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
              centerText: 'Dier verwijderen uit zone',
              rightIcon: null,
              showUserIcon: true,
              onLeftIconPressed: () {
                context.read<NavigationStateInterface>().pushReplacementBack(
                      context,
                      const ZonesScreen(),
                    );
              },
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Zone',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: AppColors.darkGreen),
                        ),
                      )
                    else if (_loadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _loadError!,
                          style: TextStyle(color: Colors.red[700], fontSize: 13),
                        ),
                      )
                    else if (_zones.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Je hebt nog geen zones.',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.darkGreen),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Zone>(
                              value: _selectedZone,
                              isExpanded: true,
                              hint: const Text('Kies een zone'),
                              items: _zones.map((z) {
                                final count = (_zoneIdToSpecies[z.id] ?? []).length;
                                return DropdownMenuItem<Zone>(
                                  value: z,
                                  child: Text('${z.name} (${count} dier${count == 1 ? '' : 'en'})'),
                                );
                              }).toList(),
                              onChanged: (z) => setState(() {
                                _selectedZone = z;
                                _selectedSpecies = null;
                              }),
                            ),
                          ),
                        ),
                      ),
                    if (_selectedZone != null && _currentZoneSpecies.isNotEmpty) ...[
                      const Text(
                        'Dier om te verwijderen',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.darkGreen),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ZoneSpeciesItem>(
                            value: _selectedSpecies,
                            isExpanded: true,
                            hint: const Text('Kies een dier'),
                            items: _currentZoneSpecies.map((s) {
                              return DropdownMenuItem<ZoneSpeciesItem>(
                                value: s,
                                child: Text(s.commonName.isEmpty ? s.id : s.commonName),
                              );
                            }).toList(),
                            onChanged: (s) => setState(() => _selectedSpecies = s),
                          ),
                        ),
                      ),
                    ],
                    if (_selectedZone != null && _currentZoneSpecies.isEmpty && !_loading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Deze zone heeft geen soorten. Voeg eerst een dier toe aan de zone.',
                          style: TextStyle(color: Colors.grey[700], fontSize: 13),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting ||
                                _zones.isEmpty ||
                                _selectedZone == null ||
                                _selectedSpecies == null)
                            ? null
                            : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
                            : const Text('Dier uit zone verwijderen'),
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
