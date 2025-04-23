enum LocationType {
  current,
  npZuidKennemerland,
  grensparkKempenbroek,
  unknown;

  String get displayText {
    switch (this) {
      case LocationType.current:
        return 'Huidige locatie';
      case LocationType.npZuidKennemerland:
        return 'Nationaal Park Zuid-Kennemerland';
      case LocationType.grensparkKempenbroek:
        return 'Grenspark Kempen~Broek';
      case LocationType.unknown:
        return 'Onbekend';
    }
  }

  String get iconPath {
    switch (this) {
      case LocationType.current:
        return 'circle_icon:my_location';
      case LocationType.npZuidKennemerland:
        return 'circle_icon:park';
      case LocationType.grensparkKempenbroek:
        return 'circle_icon:park';
      case LocationType.unknown:
        return 'circle_icon:close';
    }
  }
}



