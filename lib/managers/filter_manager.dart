import 'package:wildrapport/interfaces/filter_interface.dart';
import 'package:wildrapport/models/enums/filter_type.dart';
import 'package:wildrapport/models/brown_button_model.dart';
import 'package:wildrapport/models/animal_model.dart';

class FilterManager implements CategoryInterface, FilterInterface, SortInterface {
  static final List<BrownButtonModel> _filterOptions = [
    BrownButtonModel(
      text: FilterType.alphabetical.displayText,
      leftIconPath: 'circle_icon:sort_by_alpha',  // Using Flutter icon
      leftIconSize: 38.0,
      rightIconSize: 24.0,
      leftIconPadding: 5,
    ),
    BrownButtonModel(
      text: FilterType.mostViewed.displayText,
      leftIconPath: 'circle_icon:visibility',  // Using Flutter icon
      leftIconSize: 38.0,
      rightIconSize: 24.0,
      leftIconPadding: 5,
    ),
    BrownButtonModel(
      text: FilterType.search.displayText,
      leftIconPath: 'circle_icon:search',  // Using Flutter icon
      leftIconSize: 38.0,
      rightIconSize: 24.0,
      leftIconPadding: 5,
    ),
  ];

  List<BrownButtonModel> getAvailableFilters(String currentFilter) {
    if (currentFilter == FilterType.none.displayText || 
        currentFilter == 'Filteren' ||
        currentFilter.isEmpty) {
      return _filterOptions;
    }
    
    return _filterOptions.where((filter) =>
      filter.text != currentFilter &&
      !getAnimalCategories().any((category) => category['text'] == currentFilter)
    ).toList();
  }

  @override
  List<AnimalModel> filterAnimalsAlphabetically(List<AnimalModel> animals) {
    // Separate "Onbekend" from other animals
    final unknown = animals.where((animal) => animal.animalName == 'Onbekend').toList();
    final regularAnimals = animals.where((animal) => animal.animalName != 'Onbekend').toList();

    // Sort regular animals
    final sortedRegularAnimals = sortAlphabetically(
      regularAnimals,
      (animal) => animal.animalName.toLowerCase(),
    );

    // Combine sorted regular animals with unknown at the bottom
    return [...sortedRegularAnimals, ...unknown];
  }

  @override
  List<Map<String, String>> getAnimalCategories() {
    return [
      {'icon': 'circle_icon:pets', 'text': 'Evenhoevigen'},  // Using Flutter icon
      {'icon': 'circle_icon:pets', 'text': 'Knaagdieren'},   // Using Flutter icon
      {'icon': 'circle_icon:pets', 'text': 'Roofdieren'},    // Using Flutter icon
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

  @override
  List<AnimalModel> searchAnimals(List<AnimalModel> animals, String searchTerm) {
    if (searchTerm.isEmpty) return animals;
    
    final searchTermLower = searchTerm.toLowerCase();
    return animals.where((animal) {
      final animalNameLower = animal.animalName.toLowerCase();
      return animalNameLower.contains(searchTermLower);
    }).toList();
  }
}












