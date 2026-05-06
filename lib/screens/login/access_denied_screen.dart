import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/constants/app_icon_paths.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Logo
                SizedBox(
                  width: 140,
                  height: 140,
                  child: SvgPicture.asset(
                    'assets/logo-wildlife.svg',
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryGreen,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'Geen Toegang',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'Je account heeft geen toegang',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 56),
                // Info Card
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(
                      color: Color(0xFF999999),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vereiste Rollen:',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Je account heeft momenteel geen toegang tot WildRapport. Toegang is alleen toegestaan voor gebruikers met één van de volgende rollen:\n\n'
                          '• land-user\n'
                          '• nature-area-manager\n'
                          '• wildlife-manager\n\n'
                          'Ontbreekt één van deze rollen? Neem dan rechtstreeks contact op met WildlifeNL om toegang te verkrijgen.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (context.mounted) {
                                await context.read<AppStateProvider>().logout();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Uitloggen',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
    );
  }
}
