import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildlifenl_profile_components/wildlifenl_profile_components.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';
import 'package:wildrapport/models/beta_models/profile_model.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/screens/profile/edit_profile_screen.dart';
import 'package:wildrapport/utils/responsive_utils.dart';

/// Profielscherm: witte kaart, voorkeuren (locatie + meldingen), uitloggen, account verwijderen.
/// Geen aparte titelbalk bovenaan — alleen inhoud + eventueel systeem safe area.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Loading...';
  Profile? _profile;
  bool _loadingProfile = true;
  String _version = '';

  static const _pageBg = Color(0xFFEFF2EF);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _version = info.version;
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'User';
    });
    try {
      final profileApi = context.read<ProfileApiInterface>();
      final profile = await profileApi.fetchMyProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _userName = profile.userName;
        _loadingProfile = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final app = context.watch<AppStateProvider>();

    final email = _profile?.email ?? '—';

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPad = responsive.wp(3.5).clamp(10.0, 18.0);
            final cardW = math.min(540.0, constraints.maxWidth - horizontalPad * 2);
            final maxBoxH = constraints.maxHeight - 8;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 4),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: cardW,
                      maxHeight: maxBoxH,
                    ),
                    child: WildLifeNLProfileCard(
                      userName: _userName,
                      email: email,
                      isLoadingProfile: _loadingProfile,
                      isLocationTrackingEnabled: app.isLocationTrackingEnabled,
                      notificationsEnabled: app.notificationsEnabled,
                      version: _version,
                      primaryColor: AppColors.darkGreen,
                      onEditProfile: () => _handleEditProfile(context),
                      onLocationToggle: (enabled) async {
                        await app.setLocationTrackingEnabled(enabled);
                        if (!context.mounted) return;
                        final map = context.read<MapProvider>();
                        final state = context.read<AppStateProvider>();
                        if (!enabled) {
                          map.clearUserLocationAndStopTracking();
                        }
                        map.setVicinityNotificationsEnabled(
                          state.isLocationTrackingEnabled &&
                              state.notificationsEnabled,
                        );
                      },
                      onNotificationsToggle: (enabled) async {
                        await app.setNotificationsEnabled(enabled);
                        if (!context.mounted) return;
                        final state = context.read<AppStateProvider>();
                        context.read<MapProvider>().setVicinityNotificationsEnabled(
                              state.isLocationTrackingEnabled &&
                                  state.notificationsEnabled,
                            );
                      },
                      onLogout: () => _confirmLogout(context),
                      onDeleteAccount: () => _confirmDelete(context),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleEditProfile(BuildContext context) async {
    try {
      final profileApi = context.read<ProfileApiInterface>();
      final currentProfile = await profileApi.fetchMyProfile();
      if (!mounted) return;
      final updatedProfile = await Navigator.of(context).push<Profile>(
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(
            initialProfile: currentProfile,
          ),
        ),
      );
      if (updatedProfile != null && mounted) {
        setState(() {
          _profile = updatedProfile;
          _userName = updatedProfile.userName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profiel bijgewerkt'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij laden profiel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmLogout(BuildContext context) {
    final responsive = context.responsive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Afmelden?',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        content: Text(
          'Wilt u uitloggen?',
          style: TextStyle(fontSize: responsive.fontSize(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuleren', style: TextStyle(fontSize: responsive.fontSize(14))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final appStateProvider = context.read<AppStateProvider>();
              await appStateProvider.logout();
            },
            child: Text('Afmelden', style: TextStyle(fontSize: responsive.fontSize(14))),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final responsive = context.responsive;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Account verwijderen?',
          style: TextStyle(fontSize: responsive.fontSize(18)),
        ),
        content: Text(
          'Dit zal uw account en alle bijbehorende gegevens permanent verwijderen. Deze actie kan niet ongedaan worden gemaakt.',
          style: TextStyle(fontSize: responsive.fontSize(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Annuleren', style: TextStyle(fontSize: responsive.fontSize(14))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account wordt verwijderd...'),
                  duration: Duration(seconds: 2),
                ),
              );
              try {
                final profileApi = context.read<ProfileApiInterface>();
                final appStateProvider = context.read<AppStateProvider>();
                await profileApi.deleteMyProfile();
                await appStateProvider.deleteProfile();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fout bij verwijderen: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Verwijderen', style: TextStyle(fontSize: responsive.fontSize(14), color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
