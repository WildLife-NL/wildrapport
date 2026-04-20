import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    final fs = responsive.fontSize;

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
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: const Color.fromARGB(255, 197, 197, 197),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          // Profile Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Card(
                              color: const Color(0xFFF5F6F4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 36,
                                        backgroundColor: Colors.grey.shade200,
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 2),
                                            Text(
                                              _userName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: fs(18),
                                                fontWeight: FontWeight.w700,
                                                color: Colors.grey.shade900,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _loadingProfile ? '…' : email,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: fs(14),
                                                color: Colors.grey.shade600,
                                                height: 1.25,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  FilledButton(
                                    onPressed: _loadingProfile ? null : () => _handleEditProfile(context),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.grey.shade900,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      minimumSize: const Size.fromHeight(48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(26),
                                        side: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'Profiel Bewerken',
                                      style: TextStyle(fontSize: fs(15)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Text(
                              'Voorkeuren',
                              style: TextStyle(
                                fontSize: fs(12),
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            child: Column(
                                children: [
                                  SwitchListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    title: Text(
                                      'Locatie delen',
                                      style: TextStyle(
                                        fontSize: fs(15),
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    value: app.isLocationTrackingEnabled,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: const Color(0xFF37A904),
                                    onChanged: (enabled) async {
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
                                  ),
                                  Divider(height: 1, color: Colors.grey.shade300),
                                  SwitchListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    title: Text(
                                      'Meldingen',
                                      style: TextStyle(
                                        fontSize: fs(15),
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    value: app.notificationsEnabled,
                                    activeThumbColor: Colors.white,
                                    activeTrackColor: const Color(0xFF37A904),
                                    onChanged: (enabled) async {
                                      await app.setNotificationsEnabled(enabled);
                                      if (!context.mounted) return;
                                      final state = context.read<AppStateProvider>();
                                      context.read<MapProvider>().setVicinityNotificationsEnabled(
                                            state.isLocationTrackingEnabled &&
                                                state.notificationsEnabled,
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Card(
                              color: const Color(0xFFF5F6F4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      _version.isEmpty ? '' : 'App Version: V$_version',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: fs(11),
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    FilledButton(
                                      onPressed: () => _confirmLogout(context),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.grey.shade900,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(26),
                                          side: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Uitloggen',
                                        style: TextStyle(fontSize: fs(15)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Account verwijderen',
                                  style: TextStyle(
                                    fontSize: fs(16),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Je gegevens gaan permanent verloren; dit kan niet ongedaan worden.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: fs(12),
                                    color: Colors.grey.shade600,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: () => _confirmDelete(context),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(136, 255, 230, 232),
                                    foregroundColor: const Color.fromARGB(255, 209, 118, 118),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    minimumSize: const Size.fromHeight(44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(26),
                                    ),
                                  ),
                                  child: Text(
                                    'Account verwijderen',
                                    style: TextStyle(
                                      fontSize: fs(14),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
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
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFFD4AF37),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Weet je het zeker?',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Je wordt uitgelogd en moet opnieuw inloggen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize(13),
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Annuleren',
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final appStateProvider = context.read<AppStateProvider>();
                        await appStateProvider.logout();
                      },
                      child: Text(
                        'Ja, Uitloggen',
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final responsive = context.responsive;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Weet je het zeker?',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Je gegevens gaan permanent verloren; dit kan niet ongedaan worden.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: responsive.fontSize(13),
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(
                        'Annuleren',
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.red.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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
                      child: Text(
                        'Ja, Verwijderen',
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          color: Colors.red.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
