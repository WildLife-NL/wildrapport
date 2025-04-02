import 'package:wildrapport/models/filter_button_model.dart';

abstract class CategoryInterface {
  List<Map<String, String>> getAnimalCategories();
}

abstract class FilterInterface {
  List<T> filterByCategory<T>(
    List<T> items,
    String category,
    bool Function(T item, String category) filterFunction,
  );

  List<FilterButtonModel> getAvailableFilters(String currentFilter);
}

abstract class SortInterface {
  List<T> sortAlphabetically<T>(
    List<T> items,
    String Function(T item) getComparisonString,
  );

  List<T> sortByMostViewed<T>(
    List<T> items,
    int Function(T item) getViewCount,
  );
}


