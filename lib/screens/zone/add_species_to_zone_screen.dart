import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/interfaces/data_apis/species_api_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/models/api_models/species.dart';
import 'package:wildrapport/screens/zone/zones_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';

class AddSpeciesToZoneScreen extends StatefulWidget {
  const AddSpeciesToZoneScreen({super.key});

  @override
  State<AddSpeciesToZoneScreen> createState() => _AddSpeciesToZoneScreenState();
}

class _AddSpeciesToZoneScreenState extends State<AddSpeciesToZoneScreen> {
  Zone? _selectedZone;
  List<Zone> _zones = [];
  Species? _selectedSpecies;
  List<Species> _species = [];
  bool _loading = true;
  bool _isSubmitting = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadZonesAndSpecies();
  }

  Future<void> _loadZonesAndSpecies() async {
    final apiClient = context.read<ApiClient>();
    final speciesApi = context.read<SpeciesApiInterface>();
    try {
      final zonesResponse = await apiClient.get('zones/me/', authenticated: true);
      List<Zone> zones = [];
      if (zonesResponse.statusCode == 200) {
        final list = jsonDecode(zonesResponse.body) as List;
        zones = list.map((e) => Zone.fromJson(e as Map<String, dynamic>)).toList();
      }
      final speciesList = await speciesApi.getAllSpecies();
      if (mounted) {
        setState(() {
          _zones = zones;
          _species = speciesList;
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

  Future<void> _submit() async {
    if (_selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies een zone.')),
      );
      return;
    }
    final zoneId = _selectedZone!.id;
    if (_selectedSpecies == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies een diersoort.')),
      );
      return;
    }
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    String? errorMessage;
    bool success = false;
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.post(
        'zone/species/',
        {'zoneID': zoneId, 'speciesID': _selectedSpecies!.id},
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
        debugPrint('Add species to zone exception: $e\n$st');
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dier is aan de zone toegevoegd.')),
      );
      context.read<NavigationStateInterface>().pushReplacementBack(
            context,
            const ZonesScreen(),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Toevoegen mislukt.'),
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
              centerText: 'Dier toevoegen aan zone',
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
                      const Center(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: AppColors.darkGreen),
                      ))
                    else if (_loadError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_loadError!, style: TextStyle(color: Colors.red[700], fontSize: 13)),
                      )
                    else if (_zones.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Je hebt nog geen zones. Maak eerst een zone aan via "Zone toevoegen".',
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
                                return DropdownMenuItem<Zone>(
                                  value: z,
                                  child: Text('${z.name} – ${z.description}'),
                                );
                              }).toList(),
                              onChanged: _zones.isEmpty ? null : (z) => setState(() => _selectedZone = z),
                            ),
                          ),
                        ),
                      ),
                    const Text(
                      'Diersoort',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_loading)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(color: AppColors.darkGreen),
                      ))
                    else if (_loadError != null)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(_loadError!, style: TextStyle(color: Colors.red[700])),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.darkGreen),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Species>(
                            value: _selectedSpecies,
                            isExpanded: true,
                            hint: const Text('Kies een diersoort'),
                            items: _species.map((s) {
                              return DropdownMenuItem<Species>(
                                value: s,
                                child: Text('${s.commonName} (${s.category})'),
                              );
                            }).toList(),
                            onChanged: (s) => setState(() => _selectedSpecies = s),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (_isSubmitting || _zones.isEmpty) ? null : _submit,
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
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Dier toevoegen aan zone'),
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
