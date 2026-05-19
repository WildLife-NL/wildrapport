import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';
import 'package:wildrapport/interfaces/other/permission_interface.dart';
import 'package:wildrapport/providers/app_state_provider.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/services/notification_navigation_handler.dart';
import 'package:wildrapport/services/push_notification_coordinator.dart';
import 'package:wildlifenl_authenticator_components/wildlifenl_authenticator_components.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/screens/zone/alarms_screen.dart';
import 'package:wildrapport/screens/zone/zones_screen.dart';
import 'package:wildrapport/screens/shared/rapporteren.dart';
import 'package:wildrapport/screens/location/kaart_overview_screen.dart';
import 'package:wildrapport/screens/logbook/logbook_screen.dart';
import 'package:wildrapport/screens/profile/profile_screen.dart';
import 'package:wildrapport/widgets/navigation/custom_nav_bar.dart';

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
  bool _pushSetupStarted = false;
  bool _alarmsNavigationHandled = false;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab ?? NavTab.kaart;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupPushNotificationsIfLoggedIn();
      _openAlarmsIfRequested();
      NotificationNavigationHandler.consumePendingAfterLogin();
    });
  }

  void _openAlarmsIfRequested() {
    if (!widget.openAlarmsDirectly || _alarmsNavigationHandled || !mounted) {
      return;
    }
    _alarmsNavigationHandled = true;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AlarmsScreen()),
    );
  }

  Future<void> _setupPushNotificationsIfLoggedIn() async {
    if (_pushSetupStarted || !mounted) return;
    _pushSetupStarted = true;

    final authenticator = context.read<WildLifeNLAuthenticator>();
    if (!await authenticator.hasValidToken()) return;

    final app = context.read<AppStateProvider>();
    if (!app.notificationsEnabled) return;

    await PushNotificationCoordinator.instance.syncAfterLogin(
      profileApi: context.read<ProfileApiInterface>(),
      requestPermission: true,
      forceResync: true,
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
    permissionManager.isPermissionGranted(PermissionType.location).then((granted) {
      if (granted) return;
      if (!mounted) return;
      permissionManager.requestPermission(
        context,
        PermissionType.location,
        showRationale: false,
      );
    });
  }

  void _onTabSelected(NavTab tab) {
    setState(() => _currentTab = tab);
    if (tab == NavTab.kaart) {
      _requestLocationPermissionIfKaartTab(context);
      // IndexedStack keeps the map mounted — refresh vicinity when returning to Kaart.
      context.read<MapProvider>().loadAllPinsFromVicinity();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_currentTab == NavTab.kaart) _requestLocationPermissionIfKaartTab(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
