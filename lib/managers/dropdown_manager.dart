import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/constants/app_colors.dart';
import 'package:wildrapport/interfaces/animal_interface.dart';
import 'package:wildrapport/interfaces/dropdown_interface.dart';
import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/managers/animal_manager.dart';
import 'package:wildrapport/managers/filter_manager.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/models/enums/date_time_type.dart';
import 'package:wildrapport/models/enums/dropdown_type.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/widgets/brown_button.dart';
import 'package:wildrapport/widgets/category_filter_options.dart';
import 'package:wildrapport/widgets/circle_icon_container.dart';

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
            text: selectedValue == FilterType.none.displayText ? 'Filteren' : selectedValue,
            leftIconPath: _getSelectedFilterIcon(selectedValue),
            rightIconPath: isExpanded 
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
      _filterManager.getAvailableFilters(selectedValue)
          .map((filterModel) {
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
                        color: Colors.black.withOpacity(0.25),
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
                            hintText: 'Zoek een dier...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onChanged: (value) {
                            final animalManager = Provider.of<AnimalManagerInterface>(context, listen: false);
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
          })
          .toList(),
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
    if (selectedValue == FilterType.none.displayText || selectedValue == 'Filteren') {
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
        BrownButton(
          model: BrownButtonModel(
            text: selectedValue == LocationType.current.displayText 
                ? LocationType.current.displayText 
                : selectedValue,
            leftIconPath: _getLocationIcon(selectedValue),
            rightIconPath: isExpanded 
                ? 'circle_icon:keyboard_arrow_up'
                : 'circle_icon:keyboard_arrow_down',
            leftIconSize: 38.0,
            rightIconSize: 38.0,
            leftIconPadding: 5,
            backgroundColor: AppColors.brown,  // Now this will work
          ),
          onPressed: () => onExpandChanged(!isExpanded),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          ..._buildLocationOptions(
            selectedValue: selectedValue,
            onOptionSelected: onOptionSelected,
            onExpandChanged: onExpandChanged,
            backgroundColor: AppColors.brown,  // Updated to timber300
          ),
        ],
      ],
    );
  }

  String _getLocationIcon(String selectedValue) {
    return LocationType.values.firstWhere(
      (type) => type.displayText == selectedValue,
      orElse: () => LocationType.current,
    ).iconPath;
  }

  List<Widget> _buildLocationOptions({
    required String selectedValue,
    required Function(String) onOptionSelected,
    required Function(bool) onExpandChanged,
    required Color backgroundColor,  // Add this parameter
  }) {
    return LocationType.values
        .where((type) => type.displayText != selectedValue)
        .map((type) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: BrownButton(
          model: BrownButtonModel(
            text: type.displayText,
            leftIconPath: type.iconPath,
            leftIconSize: 38.0,
            leftIconPadding: 5,
            backgroundColor: backgroundColor,  // Add this line
          ),
          onPressed: () {
            onOptionSelected(type.displayText);
            onExpandChanged(false);
          },
        ),
      );
    }).toList();
  }

  Widget _buildDateTimeDropdown({
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
            text: selectedValue,  // Selected value shows here in header
            leftIconPath: DateTimeType.values.firstWhere(
              (type) => type.displayText == selectedValue,
              orElse: () => DateTimeType.current,
            ).iconPath,
            rightIconPath: isExpanded 
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
          ..._buildDateTimeOptions(
            selectedValue: selectedValue,
            onOptionSelected: onOptionSelected,
            onExpandChanged: onExpandChanged,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildDateTimeOptions({
    required String selectedValue,
    required Function(String) onOptionSelected,
    required Function(bool) onExpandChanged,
  }) {
    return DateTimeType.values
        .where((type) => type.displayText != selectedValue) // This excludes the selected value
        .map((type) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BrownButton(
              model: BrownButtonModel(
                text: type.displayText,
                leftIconPath: type.iconPath,
                leftIconSize: 38.0,
                leftIconPadding: 5,
              ),
              onPressed: () {
                onOptionSelected(type.displayText);
                onExpandChanged(false);
              },
            ),
          );
        }).toList();
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
      case DropdownType.dateTime:
        return _buildDateTimeDropdown(
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






























