enum LocationType {
  current,
  map,
  unknown;

  String get displayText {
    switch (this) {
      case LocationType.current:
        return 'Huidige locatie';
      case LocationType.map:
        return 'Kies op de kaart';
      case LocationType.unknown:
        return 'Onbekend';
    }
  }

  String get iconPath {
    switch (this) {
      case LocationType.current:
        return 'circle_icon:my_location';
      case LocationType.map:
        return 'circle_icon:place';
      case LocationType.unknown:
        return 'circle_icon:close';  // Changed to close icon
    }
  }
}

