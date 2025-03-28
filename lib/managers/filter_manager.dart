class FilterManager {
  static List<Map<String, String>> getAnimalCategories() {
    return [
      {
        'icon': 'assets/icons/filter_dropdown/evenhoevigen.png',  // lowercase 'e'
        'text': 'Evenhoevigen'
      },
      {
        'icon': 'assets/icons/filter_dropdown/knaagdieren.png',   // lowercase 'k'
        'text': 'Knaagdieren'
      },
      {
        'icon': 'assets/icons/filter_dropdown/roofdieren.png',    // lowercase 'r'
        'text': 'Roofdieren'
      },
    ];
  }

  static List<T> filterByCategory<T>(
    List<T> items,
    String category,
    bool Function(T item, String category) filterFunction,
  ) {
    if (category.isEmpty) {
      return items;
    }
    return items.where((item) => filterFunction(item, category)).toList();
  }

  static List<T> sortAlphabetically<T>(
    List<T> items,
    String Function(T item) getComparisonString,
  ) {
    return List<T>.from(items)
      ..sort((a, b) => getComparisonString(a).compareTo(getComparisonString(b)));
  }

  static List<T> sortByMostViewed<T>(
    List<T> items,
    int Function(T item) getViewCount,
  ) {
    return List<T>.from(items)
      ..sort((a, b) => getViewCount(b).compareTo(getViewCount(a)));
  }
}
