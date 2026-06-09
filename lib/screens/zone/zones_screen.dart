import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/config/feature_flags.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/zone/add_zone_screen.dart';
import 'package:wildrapport/screens/zone/add_species_to_zone_screen.dart';
import 'package:wildrapport/screens/zone/alarms_screen.dart';
import 'package:wildrapport/screens/zone/remove_species_from_zone_screen.dart';
import 'package:wildrapport/screens/zone/my_zones_map_screen.dart';
import 'package:wildrapport/utils/responsive_utils.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final nav = context.read<NavigationStateInterface>();
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: null,
              centerText: 'Zones',
              rightIcon: null,
              showUserIcon: false,
              iconColor: AppColors.textPrimary,
              textColor: AppColors.textPrimary,
              fontScale: responsive.breakpointValue<double>(
                small: 1.4,
                medium: 1.3,
                large: 1.2,
                extraLarge: 1.15, ),
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.wp(10),
                  vertical: responsive.hp(1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MenuCard(
                      icon: Icons.add_location_alt,
                      label: 'Zone toevoegen',
                      description: 'Nieuwe zone instellen',
                      onPressed: () {
                        nav.pushForward(context, const AddZoneScreen());
                      },
                    ),
                    SizedBox(height: responsive.hp(1.4)),
                    _MenuCard(
                      icon: Icons.map_outlined,
                      label: 'Mijn zones op de kaart',
                      description: 'Bekijk je ingestelde zones',
                      onPressed: () {
                        nav.pushForward(context, const MyZonesMapScreen());
                      },
                    ),
                    SizedBox(height: responsive.hp(1.4)),
                    _MenuCard(
                      icon: Icons.notifications_active,
                      label: 'Mijn alarmen',
                      description: 'Bekijk actieve meldingen',
                      onPressed: () {
                        nav.pushForward(context, const AlarmsScreen());
                      },
                    ),
                    SizedBox(height: responsive.hp(1.4)),
                    _MenuCard(
                      icon: Icons.pets,
                      label: 'Alarm instellen voor diersoort',
                      description: FeatureFlags.addSpeciesToZoneEnabled
                          ? 'Voeg soort toe aan een zone'
                          : 'Tijdelijk niet beschikbaar',
                      enabled: FeatureFlags.addSpeciesToZoneEnabled,
                      onPressed: () {
                        nav.pushForward(context, const AddSpeciesToZoneScreen());
                      },
                    ),
                    SizedBox(height: responsive.hp(1.4)),
                    _MenuCard(
                      icon: Icons.remove_circle_outline,
                      label: 'Alarm verwijderen voor diersoort',
                      description: FeatureFlags.removeSpeciesFromZoneEnabled
                          ? 'Verwijder soort uit een zone'
                          : 'Tijdelijk niet beschikbaar',
                      enabled: FeatureFlags.removeSpeciesFromZoneEnabled,
                      onPressed: () {
                        nav.pushForward(
                          context,
                          const RemoveSpeciesFromZoneScreen(),
                        );
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

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onPressed;
  final bool enabled;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final iconColor =
        enabled ? AppColors.primaryGreen : Colors.grey.shade400;
    final titleColor =
        enabled ? AppColors.textPrimary : Colors.grey.shade500;
    final descriptionColor =
        enabled ? Colors.grey.shade600 : Colors.grey.shade400;

    return SizedBox(
      width: double.infinity,
      height: 124,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Card(
          elevation: enabled ? 2 : 0,
          shadowColor: Colors.black12,
          color: enabled ? Colors.white : Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: enabled ? Colors.grey.shade300 : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.wp(6),
              vertical: responsive.hp(1.4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 28),
                SizedBox(width: responsive.wp(5)),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          color: descriptionColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
