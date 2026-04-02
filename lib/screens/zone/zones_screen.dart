import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/constants/button_layout.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/screens/zone/add_zone_screen.dart';
import 'package:wildrapport/screens/zone/add_species_to_zone_screen.dart';
import 'package:wildrapport/screens/zone/alarms_screen.dart';
import 'package:wildrapport/screens/zone/remove_species_from_zone_screen.dart';
import 'package:wildrapport/screens/zone/deactivate_zone_screen.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/app_bar.dart';

class ZonesScreen extends StatelessWidget {
  const ZonesScreen({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
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
              iconColor: Colors.black,
              textColor: Colors.black,
              fontScale: 1.15,
              iconScale: 1.15,
              userIconScale: 1.15,
              useFixedText: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: contentHorizontalPadding(context),
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: buttonSpacing(context)),
                    _MenuButton(
                      icon: Icons.add_location_alt,
                      label: 'Zone toevoegen',
                      onPressed: () {
                        nav.pushForward(context, const AddZoneScreen());
                      },
                    ),
                    SizedBox(height: buttonSpacing(context)),
                    _MenuButton(
                      icon: Icons.notifications_active,
                      label: 'Mijn alarmen',
                      onPressed: () {
                        nav.pushForward(context, const AlarmsScreen());
                      },
                    ),
                    SizedBox(height: buttonSpacing(context)),
                    _MenuButton(
                      icon: Icons.pets,
                      label: 'Alarm instellen voor diersoort',
                      onPressed: () {
                        nav.pushForward(context, const AddSpeciesToZoneScreen());
                      },
                    ),
                    SizedBox(height: buttonSpacing(context)),
                    _MenuButton(
                      icon: Icons.remove_circle_outline,
                      label: 'Alarm verwijderen voor diersoort',
                      onPressed: () {
                        nav.pushForward(context, const RemoveSpeciesFromZoneScreen());
                      },
                    ),
                    SizedBox(height: buttonSpacing(context)),
                    _MenuButton(
                      icon: Icons.cancel_outlined,
                      label: 'Zone deactiveren',
                      onPressed: () {
                        nav.pushForward(context, const DeactivateZoneScreen());
                      },
                    ),
                    SizedBox(height: buttonSpacing(context)),
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
    final height = menuButtonHeight(context);
    final paddingH = contentHorizontalPadding(context).clamp(16.0, 24.0);
    final paddingV = (height * 0.32).clamp(14.0, 20.0);
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: kMinTouchTargetHeight),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
            child: Row(
              children: [
                Icon(icon, color: AppColors.darkGreen, size: 28),
                SizedBox(width: paddingH * 0.7),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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
