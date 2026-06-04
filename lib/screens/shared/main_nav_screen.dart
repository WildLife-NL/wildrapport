import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/state/navigation_state_interface.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/config/feature_flags.dart';
import 'package:wildrapport/screens/zone/alarms_screen.dart';
import 'package:wildrapport/screens/zone/zones_screen.dart';
import 'package:wildrapport/screens/shared/rapporteren.dart';
import 'package:wildrapport/screens/location/kaart_overview_screen.dart';
import 'package:wildrapport/screens/logbook/logbook_screen.dart';
import 'package:wildrapport/screens/profile/bluetooth_contact_settings_screen.dart';
import 'package:wildrapport/screens/profile/profile_screen.dart';
import 'package:wildrapport/widgets/navigation/custom_nav_bar.dart';
import 'package:wildrapport/utils/snack_bar_utils.dart';
import 'package:wildrapport/services/alarm_map_focus_service.dart';
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
  bool _alarmFocusListenerAttached = false;
  AlarmMapFocusService? _alarmMapFocusService;

  @override
  void initState() {
    super.initState();
    var initial = widget.initialTab ?? NavTab.rapporten;
    if (!FeatureFlags.zonesNavEnabled && initial == NavTab.zones) {
      initial = NavTab.kaart;
    }
    _currentTab = initial;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<ContactTracingCoordinator>().initialize());
    });
  }

  void _openAlarmsIfRequested() {
    if (!widget.openAlarmsDirectly || _alarmsNavigationDone) return;
    _alarmsNavigationDone = true;
    context.read<NavigationStateInterface>().pushForward(
          context,
          const AlarmsScreen(),
        );
  }

  int get _currentIndex => _tabToIndex(_currentTab);

  static int _tabToIndex(NavTab tab) {
    if (FeatureFlags.zonesNavEnabled) {
      switch (tab) {
        case NavTab.zones:
        case NavTab.bluetooth:
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
    switch (tab) {
      case NavTab.zones:
        return 0;
      case NavTab.bluetooth:
        return 0;
      case NavTab.kaart:
        return 1;
      case NavTab.rapporten:
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

  void _onTabSelected(NavTab tab) {
    if (!FeatureFlags.zonesNavEnabled && tab == NavTab.zones) return;
    setState(() => _currentTab = tab);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _alarmMapFocusService ??= context.read<AlarmMapFocusService>();
    if (!_alarmFocusListenerAttached) {
      _alarmFocusListenerAttached = true;
      _alarmMapFocusService!.addListener(_onAlarmMapFocusRequested);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _openAlarmsIfRequested();
      _onAlarmMapFocusRequested();
    });
  }

  @override
  void dispose() {
    _alarmMapFocusService?.removeListener(_onAlarmMapFocusRequested);
    super.dispose();
  }

  void _onAlarmMapFocusRequested() {
    if (!mounted) return;
    final alarmFocus = context.read<AlarmMapFocusService>();
    if (!alarmFocus.consumeOpenMapTabRequest()) return;
    setState(() => _currentTab = NavTab.kaart);
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
        children: FeatureFlags.zonesNavEnabled
            ? [
                ZonesScreen(onBackPressed: _onBackFromTab),
                Rapporteren(
                  key: _currentTab == NavTab.rapporten
                      ? null
                      : ValueKey(_currentTab),
                  onBackPressed: _onBackFromTab,
                ),
                KaartOverviewScreen(
                  onBackPressed: _onBackFromTab,
                  isTabActive: _currentTab == NavTab.kaart,
                ),
                LogbookScreen(
                  onBackPressed: _onBackFromTab,
                  openRecentSightings: widget.openRecentSightingsDirectly &&
                      _currentTab == NavTab.logboek,
                ),
                ProfileScreen(onBackPressed: _onBackFromTab),
              ]
            : [
                const BluetoothContactSettingsScreen(
                  embeddedInMainNav: true,
                ),
                KaartOverviewScreen(
                  onBackPressed: _onBackFromTab,
                  isTabActive: _currentTab == NavTab.kaart,
                ),
                Rapporteren(
                  key: _currentTab == NavTab.rapporten
                      ? null
                      : ValueKey(_currentTab),
                  onBackPressed: _onBackFromTab,
                ),
                LogbookScreen(
                  onBackPressed: _onBackFromTab,
                  openRecentSightings: widget.openRecentSightingsDirectly &&
                      _currentTab == NavTab.logboek,
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
