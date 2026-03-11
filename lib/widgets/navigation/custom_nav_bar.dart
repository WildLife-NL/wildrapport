import 'package:flutter/material.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/models/enums/nav_tab.dart';

class CustomNavBar extends StatelessWidget {
  final NavTab currentTab;
  final ValueChanged<NavTab> onTabSelected;

  const CustomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  static const double _navBarHeight = 80;
  static const double _centerButtonSize = 60;
  static const double _centerButtonTopOffset = -20;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _navBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                tab: NavTab.zones,
                icon: Icons.add_location_alt,
                label: "Zone's",
              ),
              _buildNavItem(
                tab: NavTab.rapporten,
                icon: Icons.campaign,
                label: 'Rapporten',
              ),
              const SizedBox(width: _centerButtonSize),
              _buildNavItem(
                tab: NavTab.logboek,
                icon: Icons.menu_book,
                label: 'LogBoek',
              ),
              _buildNavItem(
                tab: NavTab.profile,
                icon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
          Positioned(
            top: _centerButtonTopOffset,
            left: MediaQuery.of(context).size.width / 2 - _centerButtonSize / 2,
            child: _buildCenterButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required NavTab tab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentTab == tab;
    final color = isSelected ? AppColors.darkGreen : const Color(0xFFB0B0B0);

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.darkGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    final isSelected = currentTab == NavTab.kaart;

    return GestureDetector(
      onTap: () => onTabSelected(NavTab.kaart),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _centerButtonSize,
            height: _centerButtonSize,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.darkGreen : const Color(0xFF8FBC8F),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.map,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kaart',
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.darkGreen : const Color(0xFFB0B0B0),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
