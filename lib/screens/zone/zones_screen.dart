import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/shared/overzicht_screen.dart';
import 'package:wildrapport/screens/zone/add_zone_screen.dart';
import 'package:wildrapport/screens/zone/add_species_to_zone_screen.dart';
import 'package:wildrapport/screens/zone/alarms_screen.dart';
import 'package:wildrapport/screens/zone/remove_species_from_zone_screen.dart';
import 'package:wildrapport/screens/zone/deactivate_zone_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationStateInterface>();
    return Scaffold(
      backgroundColor: AppColors.lightMintGreen,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: "Zone's",
              rightIcon: null,
              showUserIcon: true,
              onLeftIconPressed: () {
                nav.pushReplacementBack(context, const OverzichtScreen());
              },
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _MenuButton(
                      icon: Icons.add_location_alt,
                      label: 'Zone toevoegen',
                      onPressed: () {
                        nav.pushReplacementForward(context, const AddZoneScreen());
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      icon: Icons.notifications_active,
                      label: 'Mijn alarmen',
                      onPressed: () {
                        nav.pushReplacementForward(context, const AlarmsScreen());
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      icon: Icons.pets,
                      label: 'Dier toevoegen aan zone',
                      onPressed: () {
                        nav.pushReplacementForward(context, const AddSpeciesToZoneScreen());
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      icon: Icons.remove_circle_outline,
                      label: 'Dier verwijderen uit zone',
                      onPressed: () {
                        nav.pushReplacementForward(context, const RemoveSpeciesFromZoneScreen());
                      },
                    ),
                    const SizedBox(height: 16),
                    _MenuButton(
                      icon: Icons.cancel_outlined,
                      label: 'Zone deactiveren',
                      onPressed: () {
                        nav.pushReplacementForward(context, const DeactivateZoneScreen());
                      },
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

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: AppColors.darkGreen, size: 28),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
