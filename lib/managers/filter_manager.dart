import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
import 'package:wildrapport/models/filter_button_model.dart';

class FilterManager implements CategoryInterface, FilterInterface, SortInterface {
  // These are the DEFAULT options that should show when no filter is selected
  static final List<FilterButtonModel> _filterOptions = [
    FilterButtonModel(type: FilterType.alphabetical),
    FilterButtonModel(
      type: FilterType.category,
      showRightArrow: true,
      keepDropdownOpen: true,
    ),
    FilterButtonModel(type: FilterType.mostViewed),
  ];

  List<FilterButtonModel> getAvailableFilters(String currentFilter) {
    // Only return filter options if we have an actual filter selected
    if (currentFilter == FilterType.none.displayText || 
        currentFilter == 'Filteren' ||
        currentFilter.isEmpty) {
      return _filterOptions;
    }
    
    return _filterOptions.where((filter) =>
      filter.type.displayText != currentFilter &&
      !getAnimalCategories().any((category) => category['text'] == currentFilter)
    ).toList();
  }

  @override
  List<Map<String, String>> getAnimalCategories() {
    return [
      {'icon': 'assets/icons/filter_dropdown/evenhoevigen.png', 'text': 'Evenhoevigen'},
      {'icon': 'assets/icons/filter_dropdown/knaagdieren.png', 'text': 'Knaagdieren'},
      {'icon': 'assets/icons/filter_dropdown/roofdieren.png', 'text': 'Roofdieren'},
    ];
  }

  @override
  List<T> filterByCategory<T>(
    List<T> items,
    String category,
    bool Function(T item, String category) filterFunction,
  ) {
    if (category.isEmpty) return items;
    return items.where((item) => filterFunction(item, category)).toList();
  }

  @override
  List<T> sortAlphabetically<T>(
    List<T> items,
    String Function(T item) getComparisonString,
  ) {
    return List<T>.from(items)
      ..sort((a, b) => getComparisonString(a).compareTo(getComparisonString(b)));
  }

  @override
  List<T> sortByMostViewed<T>(
    List<T> items,
    int Function(T item) getViewCount,
  ) {
    return List<T>.from(items)
      ..sort((a, b) => getViewCount(b).compareTo(getViewCount(a)));
  }
}
























