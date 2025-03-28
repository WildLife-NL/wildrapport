enum FilterType {
  none,
  alphabetical,
  category,
  mostViewed;

  String get displayText {
    switch (this) {
      case FilterType.none:
        return 'Filteren';
      case FilterType.alphabetical:
        return 'Sorteer alfabetisch';
      case FilterType.category:
        return 'Sorteer op Categorie';
      case FilterType.mostViewed:
        return 'Meest gezien';
    }
  }

  String get iconPath {
    switch (this) {
      case FilterType.none:
        return 'circle_icon:filter_list';
      case FilterType.alphabetical:
        return 'circle_icon:sort_by_alpha';
      case FilterType.category:
        return 'circle_icon:category';
      case FilterType.mostViewed:
        return 'circle_icon:visibility';
    }
  }
}


