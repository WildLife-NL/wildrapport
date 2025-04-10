import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:wildrapport/models/enums/animal_age.dart';
import 'package:wildrapport/models/enums/animal_gender.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

class AnimalListTable extends StatefulWidget {
  const AnimalListTable({super.key});

  @override
  State<AnimalListTable> createState() => _AnimalListTableState();
}

class _AnimalListTableState extends State<AnimalListTable> {
  List<AnimalGender> _getUsedGenders(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    
    // Get unique genders from all animals in the list
    final usedGenders = currentSighting?.animals
        ?.map((animal) => animal.gender)
        .whereType<AnimalGender>()
        .toSet() ?? {};

    return usedGenders.toList();
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
    
    // Get all animals of the specified gender
    final animalsWithGender = currentSighting?.animals
        ?.where((animal) => animal.gender == gender)
        .toList() ?? [];

    // Sum up the counts for the specified age
    int totalCount = 0;
    for (var animal in animalsWithGender) {
      switch (age) {
        case AnimalAge.pasGeboren:
          totalCount += animal.viewCount.pasGeborenAmount;
        case AnimalAge.onvolwassen:
          totalCount += animal.viewCount.onvolwassenAmount;
        case AnimalAge.volwassen:
          totalCount += animal.viewCount.volwassenAmount;
        case AnimalAge.onbekend:
          totalCount += animal.viewCount.unknownAmount;
      }
    }
    
    return totalCount;
  }

  @override
  Widget build(BuildContext context) {
    final animalSightingManager = context.read<AnimalSightingReportingInterface>();
    final currentSighting = animalSightingManager.getCurrentanimalSighting();
    final usedGenders = _getUsedGenders(context);
    
    // Add debug print to check the description
    debugPrint('Current description: ${currentSighting?.description}');
    
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 409),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(25), // Changed to 25px
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
                  color: AppColors.brown.withOpacity(0.2), // Changed to brown color
                  width: 1,
                  borderRadius: BorderRadius.circular(25), // Changed to 25px
                ),
                columnWidths: {
                  0: const FlexColumnWidth(2.0),
                  for (var i = 0; i < usedGenders.length; i++)
                    i + 1: const FlexColumnWidth(0.8),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.brown.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25), // Changed to 25px
                        topRight: Radius.circular(25), // Changed to 25px
                      ),
                    ),
                    children: [
                      const TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 50.0,  // Added fixed height for the header
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
                      ...usedGenders.map((gender) => TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: SizedBox(
                          height: 50.0,  // Added fixed height for the header
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
                      )),
                    ],
                  ),
                  ...List.generate(4, (index) => _buildDataRow(index + 1, usedGenders, context)),
                ],
              ),
            ),
            if (currentSighting?.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
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
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  height: 150, // Reduced from 200 to 150
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: AppColors.brown.withOpacity(0.3), // Darker border (0.2 -> 0.3)
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          currentSighting!.description!,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
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
        ...usedGenders.map((gender) => TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                _getCountForAgeAndGender(age, gender, context).toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        )),
      ],
    );
  }
}



