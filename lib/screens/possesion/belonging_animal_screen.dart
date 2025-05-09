import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/permission_interface.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/providers/belonging_damage_report_provider.dart';
import 'package:wildrapport/screens/possesion/belonging_location_screen.dart';
import 'package:wildrapport/widgets/app_bar.dart';
import 'package:wildrapport/widgets/scrollable_animal_grid.dart';

class BelongingAnimalScreen extends StatefulWidget {
  final String appBarTitle;

  const BelongingAnimalScreen({super.key, required this.appBarTitle});

  @override
  State<BelongingAnimalScreen> createState() => _BelongingAnimalScreenState();
}

class _BelongingAnimalScreenState extends State<BelongingAnimalScreen> {
  final ScrollController _scrollController = ScrollController();
  late final BelongingDamageReportProvider _belongingDamageReportProvider;
  bool _isExpanded = false;
  List<AnimalModel> _animals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _belongingDamageReportProvider =
        context.read<BelongingDamageReportProvider>();
    _loadAnimals();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAnimals() async {
    final animalManager = context.read<AnimalManagerInterface>();

    setState(() {
      _isLoading = true;
    });

    try {
      final animals = await animalManager.getAnimals();
      setState(() {
        _animals = animals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[BelongingAnimalScreen] Error loading animals: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
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
              centerText: widget.appBarTitle,
              rightIcon: Icons.menu,
              onLeftIconPressed: () {
                debugPrint('[BelongingAnimalScreen] Back button pressed');
                Navigator.pop(context);
              },
              onRightIconPressed: () {
                debugPrint('[BelongingAnimalScreen] Menu button pressed');
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: dropdownInterface.buildDropdown(
                type: DropdownType.filter,
                selectedValue:
                    context.read<AnimalManagerInterface>().getSelectedFilter(),
                isExpanded: _isExpanded,
                onExpandChanged: (_) => _toggleExpanded(),
                onOptionSelected: (value) {
                  context.read<AnimalManagerInterface>().updateFilter(value);
                  _loadAnimals();
                },
                context: context,
              ),
            ),
            ScrollableAnimalGrid(
              animals: _animals,
              isLoading: _isLoading,
              scrollController: _scrollController,
              onAnimalSelected: (AnimalModel selectedAnimal) async {
                debugPrint('[BelongingAnimalScreen] Next button pressed');
                final permissionManager = context.read<PermissionInterface>();
                final navigationManager =
                    context.read<NavigationStateInterface>();

                // Check if location permission is already granted
                final hasPermission = await permissionManager
                    .isPermissionGranted(PermissionType.location);
                debugPrint(
                  '[BelongingAnimalScreen] Location permission status: $hasPermission',
                );

                if (!hasPermission) {
                  debugPrint(
                    '[BelongingAnimalScreen] Requesting location permission',
                  );
                  // Request permission if not granted
                  final permissionGranted = await permissionManager
                      .requestPermission(
                        context,
                        PermissionType.location,
                        showRationale: true, // Explicitly show rationale
                      );
                  debugPrint(
                    '[BelongingAnimalScreen] Permission request result: $permissionGranted',
                  );
                  if (!permissionGranted) {
                    debugPrint(
                      '[BelongingAnimalScreen] Permission denied, showing error',
                    );
                    // If permission denied, show error message and stay on current screen
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Locatie toegang is nodig om door te gaan',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                }
                // Navigate to LocationScreen if permission is granted
                debugPrint(
                  '[BelongingAnimalScreen] Navigating to LocationScreen',
                );
                if (context.mounted) {
                  debugPrint(
                    '[BelongingAnimalScreen] Selected animal name: ${selectedAnimal.animalName}',
                  );
                  debugPrint(
                    '[BelongingAnimalScreen] Selected animal ID: ${selectedAnimal.animalId!}',
                  );
                  _belongingDamageReportProvider.setSuspectedAnimal(
                    selectedAnimal.animalId!,
                  );
                  navigationManager.pushReplacementForward(
                    context,
                    const BelongingLocationScreen(),
                  );
                }
              },
              onRetry: _loadAnimals,
            ),
          ],
        ),
      ),
    );
  }
}
