import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/interfaces/navigation_state_interface.dart';
import 'package:wildrapport/interfaces/permission_interface.dart';
import 'package:wildrapport/models/animal_gender_view_count_model.dart';
import 'package:wildrapport/models/animal_model.dart';
import 'package:wildrapport/models/animal_sighting_model.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/models/factories/button_model_factory.dart';
import 'package:wildrapport/models/view_count_model.dart';
import 'package:wildrapport/screens/location_screen.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

class AnimalListTable extends StatefulWidget {
  const AnimalListTable({super.key});

  @override
  AnimalListTableState createState() => AnimalListTableState();
}

class AnimalListTableState extends State<AnimalListTable> {
  late final AnimalSightingReportingInterface _animalSightingManager;
  bool _isEditing = false;
  final TextEditingController _opmerkingController = TextEditingController();
  final Map<String, int> _tempCounts = {};
  final Map<String, TextEditingController> _controllers = {};

  String getDescription() {
    return _opmerkingController.text;
  }

  @override
  void initState() {
    super.initState();
    _animalSightingManager = context.read<AnimalSightingReportingInterface>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animalSightingManager.addListener(_handleStateChange);
      }
    });
    
    final currentSighting = _animalSightingManager.getCurrentanimalSighting();
    _opmerkingController.text = currentSighting?.description ?? '';
  }

  @override
  void dispose() {
    _opmerkingController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    
    if (mounted) {
      _animalSightingManager.removeListener(_handleStateChange);
    }
    
    super.dispose();
  }

  void _handleStateChange() {
    if (mounted) {
      setState(() {
        // This will trigger a rebuild of the table with new values
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Only update the UI state when exiting edit mode
        // Don't save to the manager here
        _tempCounts.clear();
        _controllers.clear();
      }
    });
  }

  void saveChanges() {
    if (_isEditing) {
      _saveChanges();
    }
  }

  void _saveChanges() {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    debugPrint('Before updates - Current sighting: ${currentSighting?.toJson()}');
    debugPrint('Temporary counts to save: $_tempCounts');
    
    // Save the description
    animalSightingManager.updateDescription(_opmerkingController.text);

    // Update counts for each animal
    if (currentSighting?.animals != null) {
      for (var animal in currentSighting!.animals!) {
        if (animal.gender == null) continue;

        debugPrint('Updating animal: ${animal.animalName}, Gender: ${animal.gender}');
        
        // Create new ViewCountModel with updated values
        final viewCount = ViewCountModel(
          pasGeborenAmount: _tempCounts['${AnimalAge.pasGeboren.name}_${animal.gender!.name}'] ?? 
              animal.viewCount?.pasGeborenAmount ?? 0,
          onvolwassenAmount: _tempCounts['${AnimalAge.onvolwassen.name}_${animal.gender!.name}'] ?? 
              animal.viewCount?.onvolwassenAmount ?? 0,
          volwassenAmount: _tempCounts['${AnimalAge.volwassen.name}_${animal.gender!.name}'] ?? 
              animal.viewCount?.volwassenAmount ?? 0,
          unknownAmount: _tempCounts['${AnimalAge.onbekend.name}_${animal.gender!.name}'] ?? 
              animal.viewCount?.unknownAmount ?? 0,
        );

        debugPrint('New view counts for ${animal.animalName}: ${viewCount.toJson()}');
        
        // Create updated animal with new view count
        final updatedAnimal = AnimalModel(
          animalId: animal.animalId,
          animalImagePath: animal.animalImagePath,
          animalName: animal.animalName,
          genderViewCounts: [AnimalGenderViewCount(gender: animal.gender!, viewCount: viewCount)],
          condition: animal.condition,
        );
        
        // Update the animal in the manager
        animalSightingManager.updateAnimal(updatedAnimal);
      }
    }

    setState(() {
      _isEditing = false;
      _tempCounts.clear();
      _controllers.clear();
    });

    debugPrint('After updates - Current sighting: ${animalSightingManager.getCurrentanimalSighting()?.toJson()}');
  }

  // Helper method to get count from temporary storage
  int? _getUpdatedCount(AnimalAge age, AnimalGender gender) {
    return _tempCounts['${age.name}_${gender.name}'];
  }

  // Helper method to store temporary count
  void _updateTempCount(AnimalAge age, AnimalGender gender, int count) {
    setState(() {
      final key = '${age.name}_${gender.name}';
      _tempCounts[key] = count;
      debugPrint('Updated temp count for $key: $count');
    });
  }

  List<AnimalGender> _getUsedGenders(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    if (currentSighting?.animals == null || currentSighting!.animals!.isEmpty) {
      return [];
    }

    // Get the first animal since all animals should have the same gender counts
    final animal = currentSighting.animals![0];
    
    // Extract all genders from genderViewCounts
    return animal.genderViewCounts
        .map((gvc) => gvc.gender)
        .toList();
  }

  String _getGenderIconPath(AnimalGender gender) {
    switch (gender) {
      case AnimalGender.mannelijk:
        return 'assets/icons/gender/male_gender.png';
      case AnimalGender.vrouwelijk:
        return 'assets/icons/gender/female_gender.png';
      case AnimalGender.onbekend:
        return 'assets/icons/gender/unknown_gender.png';
    }
  }

  double _getIconSize(int rowIndex) {
    switch (rowIndex) {
      case 1: // Kalf (equivalent to pasGeboren)
        return 28.0;  // Reduced from 38.0
      case 2: // Jong (equivalent to onvolwassen)
        return 32.0;  // Reduced from 44.0
      case 3: // Volwassen
        return 36.0;  // Reduced from 50.0
      case 4: // Onbekend
        return 40.0;  // Reduced from 56.0
      default:
        return 28.0;
    }
  }

  Color _getIconColor(int index) {
    switch (index) {
      case 1: // Pas geboren
        return AppColors.brown;
      case 2: // Onvolwassen
        return const Color(0xFF549537);
      case 3: // Volwassen
        return Colors.orange;
      default:
        return AppColors.brown;
    }
  }

  int _getCountForAgeAndGender(AnimalAge age, AnimalGender gender, BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    if (currentSighting?.animals == null || currentSighting!.animals!.isEmpty) {
      return 0;
    }

    // Get the first animal since all animals in the list should have the same counts
    final animal = currentSighting.animals![0];
    
    // Find the gender view count for the specified gender
    final genderViewCount = animal.genderViewCounts.firstWhere(
      (gvc) => gvc.gender == gender,
      orElse: () => AnimalGenderViewCount(gender: gender, viewCount: ViewCountModel()),
    );

    // Return the count for the specified age
    switch (age) {
      case AnimalAge.pasGeboren:
        return genderViewCount.viewCount.pasGeborenAmount;
      case AnimalAge.onvolwassen:
        return genderViewCount.viewCount.onvolwassenAmount;
      case AnimalAge.volwassen:
        return genderViewCount.viewCount.volwassenAmount;
      case AnimalAge.onbekend:
        return genderViewCount.viewCount.unknownAmount;
    }
  }

  // Get or create controller for a specific cell
  TextEditingController _getController(AnimalAge age, AnimalGender gender) {
    final key = '${age.name}_${gender.name}';
    if (!_controllers.containsKey(key)) {
      final currentCount = _getCurrentCount(age, gender);
      _controllers[key] = TextEditingController(text: currentCount.toString());
    }
    return _controllers[key]!;
  }

  int _getCurrentCount(AnimalAge age, AnimalGender gender) {
    final key = '${age.name}_${gender.name}';
    if (_isEditing) {
      // During editing, prefer temp counts but fall back to actual counts
      return _tempCounts[key] ?? _getCountForAgeAndGender(age, gender, context);
    }
    return _getCountForAgeAndGender(age, gender, context);
  }

  // _handleNextPressed method has been removed

  @override
  Widget build(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    final usedGenders = _getUsedGenders(context);
    
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildEditButton(),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Table(
                        border: TableBorder.all(
                          color: AppColors.brown.withOpacity(0.2),
                          width: 1,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        columnWidths: {
                          0: const FlexColumnWidth(2.0),
                          for (var i = 0; i < usedGenders.length; i++)
                            i + 1: const FlexColumnWidth(0.8),
                        },
                        children: [
                          _buildHeaderRow(usedGenders),
                          ...List.generate(4, (index) => _buildDataRow(index + 1, usedGenders, context)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDescriptionSection(currentSighting!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildHeaderRow(List<AnimalGender> usedGenders) {
    return TableRow(
      decoration: BoxDecoration(
        color: AppColors.brown.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      children: [
        const TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: SizedBox(
            height: 50.0,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Center(
                child: Text(
                  'Leeftijdscategorie',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        ...usedGenders.map((gender) => _buildHeaderCell(gender)),
      ],
    );
  }

  Widget _buildHeaderCell(AnimalGender gender) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: 50.0,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Image.asset(
              _getGenderIconPath(gender),
              height: 32,
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildDataRow(int index, List<AnimalGender> usedGenders, BuildContext context) {
    String firstColumnText;
    AnimalAge age;
    
    switch (index) {
      case 1:
        firstColumnText = 'Pas geboren';
        age = AnimalAge.pasGeboren;
        break;
      case 2:
        firstColumnText = 'Onvolwassen';
        age = AnimalAge.onvolwassen;
        break;
      case 3:
        firstColumnText = 'Volwassen';
        age = AnimalAge.volwassen;
        break;
      case 4:
        firstColumnText = 'Onbekend';
        age = AnimalAge.onbekend;
        break;
      default:
        firstColumnText = '';
        age = AnimalAge.onbekend;
    }

    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                if (index != 0) age == AnimalAge.onbekend 
                  ? Image.asset(
                      'assets/icons/gender/unknown_gender.png',
                      height: _getIconSize(index),
                      width: _getIconSize(index),
                    )
                  : Icon(
                      Icons.pets,
                      size: _getIconSize(index),
                      color: _getIconColor(index),
                    ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(firstColumnText),
                ),
              ],
            ),
          ),
        ),
        ...usedGenders.map((gender) => _buildDataCell(age, gender, context)),
      ],
    );
  }

  TableCell _buildDataCell(AnimalAge age, AnimalGender gender, BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: SizedBox(
        height: 50.0,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _isEditing
                ? TextFormField( // Changed to TextFormField for better control
                    controller: _getController(age, gender),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      border: UnderlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (!mounted) return;
                      final count = int.tryParse(value) ?? 0;
                      final key = '${age.name}_${gender.name}';
                      _tempCounts[key] = count;
                      debugPrint('Updated temp count: $key = $count');
                    },
                )
                : Text(
                    _getCurrentCount(age, gender).toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: BrownButton(
        model: ButtonModelFactory.createStandardButton(
          text: _isEditing ? 'Opslaan' : 'Bewerken',
          leftIconPath: _isEditing ? 'circle_icon:done' : 'circle_icon:edit',
        ),
        onPressed: _toggleEditMode,
      ),
    );
  }

  Widget _buildDescriptionSection(AnimalSightingModel currentSighting) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opmerkingen',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.offWhite,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.brown.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _opmerkingController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'typ hier...',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move the listener setup here to prevent multiple attachments
    final manager = context.read<AnimalSightingReportingInterface>();
    manager.removeListener(_handleStateChange); // Remove any existing listener
    manager.addListener(_handleStateChange);
  }
}



