import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/screens/rapporteren.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/bottom_app_bar.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isExpanded = false;
  String _selectedLocation = LocationType.current.displayText;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _handleLocationSelection(String location) {
    setState(() {
      _selectedLocation = location;
    });
    // Handle location selection logic here
  }

  @override
  Widget build(BuildContext context) {
    final dropdownInterface = context.read<DropdownInterface>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              leftIcon: Icons.arrow_back_ios,
              centerText: 'Locatie',
              rightIcon: Icons.menu,
              onLeftIconPressed: () => context.read<NavigationStateInterface>().pushReplacementBack(context, const Rapporteren()),
              onRightIconPressed: () {/* Handle menu */},
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: dropdownInterface.buildDropdown(
                type: DropdownType.location,
                selectedValue: _selectedLocation,
                isExpanded: _isExpanded,
                onExpandChanged: (_) => _toggleExpanded(),
                onOptionSelected: _handleLocationSelection,
                context: context,
              ),
            ),
            // Add map widget or other location-related content here
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        onBackPressed: () => context.read<NavigationStateInterface>().pushReplacementBack(context, const Rapporteren()),
        onNextPressed: () {
          // Handle next action
        },
        showNextButton: true,
        showBackButton: true,
      ),
    );
  }
}

