import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/button_layout.dart';
import 'package:wildrapport/data_managers/api_client.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';
import 'package:wildlifenl_zone_components/wildlifenl_zone_components.dart';

class DeactivateZoneScreen extends StatefulWidget {
  const DeactivateZoneScreen({super.key});

  @override
  State<DeactivateZoneScreen> createState() => _DeactivateZoneScreenState();
}

class _DeactivateZoneScreenState extends State<DeactivateZoneScreen> {
  Zone? _selectedZone;
  List<Zone> _zones = [];
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
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        zones = list.map((e) => Zone.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (mounted) {
        setState(() {
          _zones = zones;
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
    if (_selectedZone == null) return;
    final zone = _selectedZone!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zone deactiveren'),
        content: Text(
          'Weet je zeker dat je de zone "${zone.name}" wilt deactiveren? Deze actie kan niet ongedaan worden gemaakt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deactiveren'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    String? errorMessage;
    bool success = false;
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.delete(
        'zone/${zone.id}',
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
        debugPrint('Deactivate zone exception: $e\n$st');
      }
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zone is gedeactiveerd.')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? 'Deactiveren mislukt.'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.backgroundLight,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          CustomAppBar(
            leftIcon: Icons.arrow_back_ios,
            centerText: 'Zone deactiveren',
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
                          'Kies de zone die je wilt deactiveren',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Een gedeactiveerde zone wordt niet meer gebruikt voor alarmen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.grey[700],
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
                            'Je hebt geen zones om te deactiveren.',
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
                              value: _selectedZone,
                              isExpanded: true,
                              hint: const Text(
                                'Kies een zone',
                                style: TextStyle(fontSize: 15),
                              ),
                              borderRadius: BorderRadius.circular(16),
                              items: _zones.map((z) {
                                return DropdownMenuItem<Zone>(
                                  value: z,
                                  child: Text(
                                    '${z.name} – ${z.description}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                );
                              }).toList(),
                              onChanged: (z) {
                                setState(() => _selectedZone = z);
                              },
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
                  onPressed:
                      (_isSubmitting || _zones.isEmpty || _selectedZone == null)
                          ? null
                          : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
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
                          'Zone deactiveren',
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