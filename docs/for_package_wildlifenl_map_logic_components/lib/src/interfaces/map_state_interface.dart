// Stub alleen voor analyse in deze docs-map. In de echte package
// staat de volledige MapStateInterface.

abstract class MapStateInterface {
  static const String standardTileUrl =
      'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
  static const List<String> standardTileSubdomains = ['a', 'b', 'c'];
  static const String satelliteTileUrl =
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  static const String standardAttributionText =
      '© OpenTopoMap · © OpenStreetMap contributors';
}
