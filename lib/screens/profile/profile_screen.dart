import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final appStateProvider = context.watch<AppStateProvider>();
    final locationTrackingEnabled = appStateProvider.isLocationTrackingEnabled;

    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar with back button and title (moved slightly down)
              Padding(
                padding: EdgeInsets.only(top: responsive.hp(1)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: AppColors.offWhite,
                      iconSize: responsive.sp(3),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Profiel',
                          style: TextStyle(
                            color: AppColors.offWhite,
                            fontSize: responsive.fontSize(24),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    // keep space to the right so title is centered
                    SizedBox(width: responsive.wp(12)),
                  ],
                ),
              ),

              SizedBox(height: responsive.spacing(36)),

              // Avatar + name
              Row(
                children: [
                  Container(
                    width: responsive.sp(8),
                    height: responsive.sp(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.offWhite,
                    ),
                    child: Center(
                      child: Icon(Icons.person, size: responsive.sp(5)),
                    ),
                  ),
                  SizedBox(width: responsive.wp(3.5)),
                  Expanded(
                    child: Text(
                      _userName,
                      style: TextStyle(
                        color: AppColors.offWhite,
                        fontSize: responsive.fontSize(16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: responsive.spacing(48)),

              // Location Tracking label
              Center(
                child: Text(
                  'Locatie delen',
                  style: TextStyle(
                    color: AppColors.offWhite,
                    fontSize: responsive.fontSize(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              SizedBox(height: responsive.spacing(12)),

              // On/Off segmented style
              Center(
                child: Container(
                  padding: EdgeInsets.all(responsive.sp(0.5)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(responsive.sp(3)),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await appStateProvider.setLocationTrackingEnabled(
                            true,
                          );
                        },
                        child: Container(
                          width: responsive.wp(25),
                          padding: EdgeInsets.symmetric(
                            vertical: responsive.hp(1),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              responsive.sp(2.5),
                            ),
                            color:
                                locationTrackingEnabled
                                    ? AppColors.offWhite
                                    : Colors.transparent,
                            border: Border.all(
                              color: AppColors.offWhite,
                              width: responsive.sp(0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Aan',
                              style: TextStyle(
                                color:
                                    locationTrackingEnabled
                                        ? AppColors.darkGreen
                                        : AppColors.offWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: responsive.fontSize(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.wp(2)),
                      GestureDetector(
                        onTap: () async {
                          await appStateProvider.setLocationTrackingEnabled(
                            false,
                          );
                        },
                        child: Container(
                          width: responsive.wp(25),
                          padding: EdgeInsets.symmetric(
                            vertical: responsive.hp(1),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              responsive.sp(2.5),
                            ),
                            color:
                                !locationTrackingEnabled
                                    ? AppColors.offWhite
                                    : Colors.transparent,
                            border: Border.all(
                              color: AppColors.offWhite,
                              width: responsive.sp(0.2),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Uit',
                              style: TextStyle(
                                color:
                                    !locationTrackingEnabled
                                        ? AppColors.darkGreen
                                        : AppColors.offWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: responsive.fontSize(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: responsive.spacing(62)),

              // Buttons list
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Delete account - outlined
                      _outlinedButton(
                        context,
                        'Account verwijderen',
                        onPressed: () {
                          // placeholder
                        },
                      ),

                      SizedBox(height: responsive.spacing(12)),

                      // Log out - filled white
                      _filledButton(
                        context,
                        'Afmelden',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (ctx) => AlertDialog(
                                  title: Text(
                                    'Afmelden?',
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(18),
                                    ),
                                  ),
                                  content: Text(
                                    'Wilt u uitloggen?',
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(14),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: Text(
                                        'Annuleren',
                                        style: TextStyle(
                                          fontSize: responsive.fontSize(14),
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(ctx).pop();
                                        final appStateProvider =
                                            context.read<AppStateProvider>();
                                        await appStateProvider.logout();
                                      },
                                      child: Text(
                                        'Afmelden',
                                        style: TextStyle(
                                          fontSize: responsive.fontSize(14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        },
                      ),

                      SizedBox(height: responsive.spacing(12)),

                      // Update Info
                      _filledButton(
                        context,
                        'Gegevens bijwerken',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filledButton(
    BuildContext context,
    String text, {
    required VoidCallback onPressed,
  }) {
    final responsive = context.responsive;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          // default background: light mint; on hover/pressed: light green
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed)) {
              return AppColors.lightGreen; // 0xFF1F4A14
            }
            return AppColors.lightMintGreen; // 0xFFF1F5F2
          }),
          // default text: black; on hover/pressed: offWhite
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed)) {
              return AppColors.offWhite;
            }
            return AppColors.black;
          }),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: responsive.hp(1.75)),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.sp(3)),
            ),
          ),
          textStyle: MaterialStateProperty.all(
            TextStyle(fontSize: responsive.fontSize(16)),
          ),
          // small elevation to match flat look; keep default elevation on press
          elevation: MaterialStateProperty.resolveWith<double?>((states) {
            if (states.contains(MaterialState.pressed)) return 2.0;
            return 0.0;
          }),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _outlinedButton(
    BuildContext context,
    String text, {
    required VoidCallback onPressed,
  }) {
    final responsive = context.responsive;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed)) {
              return AppColors.lightGreen;
            }
            return AppColors.lightMintGreen;
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed)) {
              return AppColors.offWhite;
            }
            return AppColors.black;
          }),
          side: MaterialStateProperty.resolveWith<BorderSide?>((states) {
            if (states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed)) {
              return BorderSide(
                color: AppColors.lightGreen,
                width: responsive.sp(0.2),
              );
            }
            return BorderSide(
              color: AppColors.lightMintGreen,
              width: responsive.sp(0.2),
            );
          }),
          padding: MaterialStateProperty.all(
            EdgeInsets.symmetric(vertical: responsive.hp(1.75)),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.sp(3)),
            ),
          ),
          textStyle: MaterialStateProperty.all(
            TextStyle(fontSize: responsive.fontSize(16)),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
