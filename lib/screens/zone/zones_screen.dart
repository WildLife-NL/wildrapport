import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/zone/add_zone_screen.dart';
import 'package:wildrapport/screens/zone/add_species_to_zone_screen.dart';
import 'package:wildrapport/screens/zone/alarms_screen.dart';
import 'package:wildrapport/screens/zone/remove_species_from_zone_screen.dart';
import 'package:wildrapport/screens/zone/deactivate_zone_screen.dart';
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
      backgroundColor: AppColors.lightMintGreen,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: null,
              centerText: "Zone's",
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
                      description: 'Voeg soort toe aan een zone',
                      onPressed: () {
                        nav.pushForward(context, const AddSpeciesToZoneScreen());
                      },
                    ),
                    SizedBox(height: responsive.hp(1.4)),
                    _MenuCard(
                      icon: Icons.remove_circle_outline,
                      label: 'Alarm verwijderen voor diersoort',
                      description: 'Verwijder soort uit een zone',
                      onPressed: () {
                        nav.pushForward(context, const RemoveSpeciesFromZoneScreen());
                      },
                    ),
                    SizedBox(height: responsive.hp(1.4)),
                    _MenuCard(
                      icon: Icons.cancel_outlined,
                      label: 'Zone deactiveren',
                      description: 'Schakel een zone tijdelijk uit',
                      onPressed: () {
                        nav.pushForward(context, const DeactivateZoneScreen());
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

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return SizedBox(
      width: double.infinity,
      height: 124,
      child: GestureDetector(
        onTap: onPressed,
        child: Card(
          elevation: 2,
          shadowColor: Colors.black12,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: Colors.grey.shade300,
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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 32,
                      color: AppColors.brownDark,
                    ),
                  ),
                ),
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          color: Colors.grey.shade600,
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
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
