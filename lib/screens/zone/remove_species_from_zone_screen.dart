import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/button_layout.dart';
import 'package:wildrapport/data_managers/api_client.dart';
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
          // Keep selected values in sync with freshly loaded objects to avoid
          // DropdownButton assertions when instances changed after reload.
          if (_selectedZone != null) {
            final matchedZone = zones.where((z) => z.id == _selectedZone!.id);
            _selectedZone = matchedZone.isNotEmpty ? matchedZone.first : null;
          }
          if (_selectedSpecies != null) {
            final speciesInZone = _selectedZone == null
                ? <ZoneSpeciesItem>[]
                : (zoneIdToSpecies[_selectedZone!.id] ?? <ZoneSpeciesItem>[]);
            final matchedSpecies = speciesInZone
                .where((s) => s.id == _selectedSpecies!.id)
                .toList();
            _selectedSpecies =
                matchedSpecies.length == 1 ? matchedSpecies.first : null;
          }
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
  final safeSelectedZone = _selectedZone != null &&
          _zones.where((z) => z.id == _selectedZone!.id).length == 1
      ? _zones.firstWhere((z) => z.id == _selectedZone!.id)
      : null;

  final currentSpecies = safeSelectedZone == null
      ? <ZoneSpeciesItem>[]
      : (_zoneIdToSpecies[safeSelectedZone.id] ?? <ZoneSpeciesItem>[]);

  final safeSelectedSpecies = _selectedSpecies != null &&
          currentSpecies.where((s) => s.id == _selectedSpecies!.id).length == 1
      ? currentSpecies.firstWhere((s) => s.id == _selectedSpecies!.id)
      : null;

  return Scaffold(
    backgroundColor: AppColors.backgroundLight,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          CustomAppBar(
            leftIcon: Icons.arrow_back_ios,
            centerText: 'Dier verwijderen',
            rightIcon: null,
            showUserIcon: false,
            onLeftIconPressed: () {
              Navigator.of(context).pop();
            },
            iconColor: Colors.black,
            textColor: Colors.black,
            fontScale: 1.4,
            iconScale: 1.15,
            userIconScale: 1.15,
            useFixedText: true,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: AppColors.borderDefault,
                    width: 1,
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Kies een zone en een diersoort',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Zone',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),

                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.darkGreen,
                            ),
                          ),
                        )
                      else if (_loadError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _loadError!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else if (_zones.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Je hebt nog geen zones.',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Zone>(
                              value: safeSelectedZone,
                              isExpanded: true,
                              hint: const Text(
                                'Kies een zone',
                                style: TextStyle(fontSize: 15),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              items: _zones.map((z) {
                                final count =
                                    (_zoneIdToSpecies[z.id] ?? []).length;
                                return DropdownMenuItem<Zone>(
                                  value: z,
                                  child: Text(
                                    '${z.name} ($count dier${count == 1 ? '' : 'en'})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                );
                              }).toList(),
                              onChanged: (z) => setState(() {
                                _selectedZone = z;
                                _selectedSpecies = null;
                              }),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      Text(
                        'Diersoort',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),

                      if (safeSelectedZone != null && currentSpecies.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ZoneSpeciesItem>(
                              value: safeSelectedSpecies,
                              isExpanded: true,
                              hint: const Text(
                                'Kies een dier',
                                style: TextStyle(fontSize: 15),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              items: currentSpecies.map((s) {
                                return DropdownMenuItem<ZoneSpeciesItem>(
                                  value: s,
                                  child: Text(
                                    s.commonName.isEmpty ? s.id : s.commonName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                );
                              }).toList(),
                              onChanged: (s) {
                                setState(() => _selectedSpecies = s);
                              },
                            ),
                          ),
                        )
                      else if (safeSelectedZone != null &&
                          currentSpecies.isEmpty &&
                          !_loading)
                        Text(
                          'Deze zone heeft geen soorten. Voeg eerst een dier toe aan de zone.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Kies eerst een zone',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF7A7A7A),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: primaryButtonHeight(context),
                child: ElevatedButton(
                  onPressed: (_isSubmitting ||
                          _zones.isEmpty ||
                          _selectedZone == null ||
                          _selectedSpecies == null)
                      ? null
                      : _submit,
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
                          'Dier uit zone verwijderen',
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