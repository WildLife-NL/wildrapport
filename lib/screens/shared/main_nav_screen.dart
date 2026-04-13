import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/other/permission_interface.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';
import 'package:wildrapport/screens/zone/zones_screen.dart';
import 'package:wildrapport/screens/shared/rapporteren.dart';
import 'package:wildrapport/screens/location/kaart_overview_screen.dart';
import 'package:wildrapport/screens/logbook/recent_sightings_screen.dart';
import 'package:wildrapport/screens/profile/profile_screen.dart';
import 'package:wildrapport/widgets/navigation/custom_nav_bar.dart';

class MainNavScreen extends StatefulWidget {
  final NavTab? initialTab;
  final bool openRecentSightingsDirectly;
  
  const MainNavScreen({
    super.key, 
    this.initialTab,
    this.openRecentSightingsDirectly = false,
  });

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late NavTab _currentTab;
  
  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab ?? NavTab.kaart;
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
    if (tab == NavTab.kaart) _requestLocationPermissionIfKaartTab(context);
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
          const RecentSightingsScreen(),
          ProfileScreen(onBackPressed: _onBackFromTab),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomNavBar(
          currentTab: _currentTab,
          onTabSelected: _onTabSelected,
        ),
      ),
    );
  }
}
