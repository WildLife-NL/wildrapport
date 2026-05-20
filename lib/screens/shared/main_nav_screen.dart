import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/other/permission_interface.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/screens/zone/alarms_screen.dart';
import 'package:wildrapport/screens/zone/zones_screen.dart';
import 'package:wildrapport/screens/shared/rapporteren.dart';
import 'package:wildrapport/screens/location/kaart_overview_screen.dart';
import 'package:wildrapport/screens/logbook/logbook_screen.dart';
import 'package:wildrapport/screens/profile/profile_screen.dart';
import 'package:wildrapport/widgets/navigation/custom_nav_bar.dart';
import 'package:wildrapport/utils/snack_bar_utils.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/services/contact_tracing_coordinator.dart';

class MainNavScreen extends StatefulWidget {
  final NavTab? initialTab;
  final bool openRecentSightingsDirectly;
  final bool openAlarmsDirectly;

  const MainNavScreen({
    super.key,
    this.initialTab,
    this.openRecentSightingsDirectly = false,
    this.openAlarmsDirectly = false,
  });

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late NavTab _currentTab;
  bool _alarmsNavigationDone = false;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab ?? NavTab.rapporten;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<ContactTracingCoordinator>().initialize());
    });
  }

  void _openAlarmsIfRequested() {
    if (!widget.openAlarmsDirectly || _alarmsNavigationDone) return;
    if (_currentTab != NavTab.zones) return;
    _alarmsNavigationDone = true;
    context.read<NavigationStateInterface>().pushForward(
          context,
          const AlarmsScreen(),
        );
  }

  int get _currentIndex => _tabToIndex(_currentTab);

  static int _tabToIndex(NavTab tab) {
    switch (tab) {
      case NavTab.zones:
        return 0;
      case NavTab.rapporten:
        return 1;
      case NavTab.kaart:
        return 2;
      case NavTab.logboek:
        return 3;
      case NavTab.profile:
        return 4;
    }
  }

  void _onBackFromTab() {
    setState(() => _currentTab = NavTab.kaart);
  }

  void _requestLocationPermissionIfKaartTab(BuildContext context) {
    final permissionManager = context.read<PermissionInterface>();
    final appState = context.read<AppStateProvider>();
    permissionManager.isPermissionGranted(PermissionType.location).then((granted) {
      if (granted) {
        if (!appState.isLocationTrackingEnabled) {
          appState.setLocationTrackingEnabled(true);
        }
        return;
      }
      if (!mounted) return;
      permissionManager.requestPermission(
        context,
        PermissionType.location,
        showRationale: false,
      ).then((approved) {
        if (approved && !appState.isLocationTrackingEnabled) {
          appState.setLocationTrackingEnabled(true);
        }
      });
    });
  }

  void _onTabSelected(NavTab tab) {
    setState(() => _currentTab = tab);
    if (tab == NavTab.kaart) _requestLocationPermissionIfKaartTab(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_currentTab == NavTab.kaart) _requestLocationPermissionIfKaartTab(context);
      _openAlarmsIfRequested();
    });
  }

  @override
  Widget build(BuildContext context) {
    final snackBarTheme = Theme.of(context).snackBarTheme.copyWith(
      behavior: SnackBarBehavior.floating,
      insetPadding: floatingSnackBarMargin(context),
    );

    return Theme(
      data: Theme.of(context).copyWith(snackBarTheme: snackBarTheme),
      child: Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ZonesScreen(onBackPressed: _onBackFromTab),
          Rapporteren(
            key: _currentTab == NavTab.rapporten ? null : ValueKey(_currentTab),
            onBackPressed: _onBackFromTab,
          ),
          KaartOverviewScreen(onBackPressed: _onBackFromTab),
          LogbookScreen(
            onBackPressed: _onBackFromTab,
            openRecentSightings: widget.openRecentSightingsDirectly && _currentTab == NavTab.logboek,
          ),
          ProfileScreen(onBackPressed: _onBackFromTab),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: false,
        child: CustomNavBar(
          currentTab: _currentTab,
          onTabSelected: _onTabSelected,
        ),
      ),
      ),
    );
  }
}
