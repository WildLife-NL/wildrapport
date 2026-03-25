import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/providers/app_state_provider.dart';

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Geen Toegang',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Je account heeft momenteel geen toegang tot WildRapport.\n\n'
                'Toegang is alleen toegestaan voor gebruikers met één van de volgende rollen:\n'
                '• land-user\n• nature-area-manager\n• wildlife-manager\n\n'
                'Ontbreekt één van deze rollen? Neem dan rechtstreeks contact op met WildlifeNL om toegang te verkrijgen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brown300,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (context.mounted) {
                      await context.read<AppStateProvider>().logout();
                    }
                  },
                  label: const Text('Uitloggen en terug naar inloggen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
