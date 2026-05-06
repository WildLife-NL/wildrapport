import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/waarneming_flow/animal_interface.dart';
import 'package:wildrapport/interfaces/filters/dropdown_interface.dart';
import 'package:wildrapport/interfaces/filters/filter_interface.dart';
import 'package:wildrapport/managers/waarneming_flow/animal_manager.dart';
import 'package:wildrapport/models/ui_models/brown_button_model.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/brown_button.dart';
import 'package:wildrapport/widgets/shared_ui_widgets/circle_icon_container.dart';

class DropdownManager implements DropdownInterface {
  final FilterInterface _filterManager;

  DropdownManager(this._filterManager);

  Widget _buildFilterDropdown({
    required String selectedValue,
    required bool isExpanded,
    required Function(bool) onExpandChanged,
    required Function(String) onOptionSelected,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BrownButton(
          model: BrownButtonModel(
            text:
                selectedValue == FilterType.none.displayText
                    ? 'Filteren'
                    : selectedValue,
            leftIconPath: _getSelectedFilterIcon(selectedValue),
            rightIconPath:
                isExpanded
                    ? 'circle_icon:keyboard_arrow_up'
                    : 'circle_icon:keyboard_arrow_down',
            leftIconSize: 38.0,
            rightIconSize: 38.0,
            leftIconPadding: 5,
          ),
          onPressed: () => onExpandChanged(!isExpanded),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          ..._buildFilterOptions(
            selectedValue: selectedValue,
            onOptionSelected: onOptionSelected,
            onExpandChanged: onExpandChanged,
            context: context,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildFilterOptions({
    required String selectedValue,
    required Function(String) onOptionSelected,
    required Function(bool) onExpandChanged,
    required BuildContext context,
  }) {
    final List<Widget> options = [];

    options.addAll(
      _filterManager.getAvailableFilters(selectedValue).map((filterModel) {
        if (filterModel.text == FilterType.search.displayText) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.brown,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: CircleIconContainer(
                      icon: Icons.search,
                      iconColor: AppColors.brown,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      decoration: const InputDecoration(
                        label: Text('Zoek een dier...'),
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.white70),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (value) {
                        final animalManager =
                            Provider.of<AnimalManagerInterface>(
                              context,
                              listen: false,
                            );
                        if (animalManager is AnimalManager) {
                          animalManager.updateSearchTerm(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Special handling for "Meest gezien" option
        if (filterModel.text == FilterType.mostViewed.displayText) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BrownButton(
              model: filterModel,
              onPressed: () {
                // Show snackbar but don't select this option
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deze functie komt binnenkort beschikbaar'),
                    duration: Duration(seconds: 2),
                  ),
                );
                // Don't close dropdown or update selection
              },
            ),
          );
        }

        // Normal handling for other options
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BrownButton(
            model: filterModel,
            onPressed: () {
              onOptionSelected(filterModel.text ?? '');
              onExpandChanged(false);
            },
          ),
        );
      }).toList(),
    );

    if (selectedValue != FilterType.none.displayText &&
        selectedValue != 'Filteren' &&
        selectedValue.isNotEmpty) {
      options.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: BrownButton(
            model: BrownButtonModel(
              text: 'Reset filter',
              leftIconPath: 'circle_icon:restart_alt',
              leftIconSize: 38.0,
            ),
            onPressed: () {
              onOptionSelected(FilterType.none.displayText);
              onExpandChanged(false);
            },
          ),
        ),
      );
    }

    return options;
  }

  String _getSelectedFilterIcon(String selectedValue) {
    if (selectedValue == FilterType.none.displayText ||
        selectedValue == 'Filteren') {
      return FilterType.none.iconPath;
    }

    final filterType = FilterType.values.firstWhere(
      (type) => type.displayText == selectedValue,
      orElse: () => FilterType.none,
    );

    return filterType.iconPath;
  }

  Widget _buildLocationDropdown({
    required String selectedValue,
    required bool isExpanded,
    required Function(bool) onExpandChanged,
    required Function(String) onOptionSelected,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.primaryGreen, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onExpandChanged(!isExpanded),
              borderRadius: BorderRadius.circular(25),
              hoverColor: AppColors.primaryGreen.withValues(alpha:0.15),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedValue == LocationType.current.displayText
                            ? LocationType.current.displayText
                            : selectedValue,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          ..._buildLocationOptions(
            selectedValue: selectedValue,
            onOptionSelected: onOptionSelected,
            onExpandChanged: onExpandChanged,
            backgroundColor: Colors.white,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildLocationOptions({
    required String selectedValue,
    required Function(String) onOptionSelected,
    required Function(bool) onExpandChanged,
    required Color backgroundColor,
  }) {
    return LocationType.values
        .where((type) => type.displayText != selectedValue)
        .map((type) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.primaryGreen, width: 1.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    onOptionSelected(type.displayText);
                    onExpandChanged(false);
                  },
                  borderRadius: BorderRadius.circular(25),
                  hoverColor: AppColors.primaryGreen.withValues(alpha:0.15),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      type.displayText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        })
        .toList();
  }

  @override
  Widget buildDropdown({
    required DropdownType type,
    required String selectedValue,
    required bool isExpanded,
    required Function(bool) onExpandChanged,
    required Function(String) onOptionSelected,
    required BuildContext context,
  }) {
    switch (type) {
      case DropdownType.filter:
        return _buildFilterDropdown(
          selectedValue: selectedValue,
          isExpanded: isExpanded,
          onExpandChanged: onExpandChanged,
          onOptionSelected: onOptionSelected,
          context: context,
        );
      case DropdownType.location:
        return _buildLocationDropdown(
          selectedValue: selectedValue,
          isExpanded: isExpanded,
          onExpandChanged: onExpandChanged,
          onOptionSelected: onOptionSelected,
          context: context,
        );
      default:
        throw UnimplementedError('Dropdown type not implemented');
    }
  }
}
