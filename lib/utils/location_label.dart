import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/managers/map/living_lab_manager.dart';

class City {
  final String name;
  final double lat;
  final double lon;
  const City(this.name, this.lat, this.lon);
}

// Major Dutch cities with approximate coordinates
const List<City> _cities = [
  City('Amsterdam', 52.3676, 4.9041),
  City('Rotterdam', 51.9225, 4.4792),
  City('Den Haag', 52.0705, 4.2993),
  City('Utrecht', 52.0907, 5.1214),
  City('Eindhoven', 51.4416, 5.4697),
  City('Groningen', 53.2194, 6.5665),
  City('Zwolle', 52.5092, 6.0921),
  City('Maastricht', 50.8513, 5.6869),
  City('Haarlem', 52.3894, 4.6369),
  City('Arnhem', 51.9851, 5.8987),
  City('Almere', 52.3667, 5.2333),
  City('Enschede', 52.2215, 6.8936),
  City('Apeldoorn', 52.2100, 5.9700),
  City('Nijmegen', 51.8452, 5.8520),
  City('Tilburg', 51.5603, 5.0878),
  City('Breda', 51.5897, 4.7789),
  City('s-Hertogenbosch', 51.6927, 5.3012),
  City('Dordrecht', 51.8133, 4.6697),
  City('Leiden', 52.1601, 4.4852),
  City('Leeuwarden', 53.2012, 5.7878),
  City('Almelo', 52.3567, 6.6656),
  City('Delft', 52.0116, 4.3571),
  City('Gouda', 51.9719, 4.7119),
  City('Alkmaar', 52.6328, 4.7353),
  City('Middelburg', 51.4987, 3.6142),
  City('Deventer', 52.2565, 6.1617),
  City('Kampen', 52.5599, 5.8883),
  City('Winterswijk', 52.1039, 6.7656),
  City('Venlo', 51.3639, 6.1689),
  City('Roermond', 51.1924, 5.9881),
];

double _distance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295;
  final a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

String _findNearestCity(double lat, double lon) {
  if (_cities.isEmpty) return '';
  
  City nearest = _cities[0];
  double minDist = _distance(lat, lon, nearest.lat, nearest.lon);
  
  for (final city in _cities) {
    final dist = _distance(lat, lon, city.lat, city.lon);
    if (dist < minDist) {
      minDist = dist;
      nearest = city;
    }
  }
  
  // Only return city if within ~15 km
  return minDist < 15 ? nearest.name : '';
}

String formatFriendlyLocation(double lat, double lon) {
  final coords = '${lat.toStringAsFixed(3)}/${lon.toStringAsFixed(3)}';

  // Try to use Living Lab name if within any polygon
  final manager = LivingLabManager();
  final lab = manager.getLivingLabByLocation(LatLng(lat, lon));
  if (lab != null) {
    return '${lab.name} $coords';
  }

  // Fallback: nearest city within ~15km
  final city = _findNearestCity(lat, lon);
  return city.isNotEmpty ? '$city $coords' : coords;
}