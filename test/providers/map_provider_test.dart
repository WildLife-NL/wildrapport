import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wildrapport/interfaces/data_apis/tracking_api_interface.dart';
import 'package:wildrapport/interfaces/data_apis/vicinity_api_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_pin.dart';
import 'package:wildrapport/models/api_models/detection_pin.dart';
import 'package:wildrapport/models/api_models/interaction_query_result.dart';
import 'package:wildrapport/models/api_models/vicinity.dart';
import 'package:wildrapport/providers/map_provider.dart';

// Mock Position for testing
class MockPosition implements Position {
  final double lat;
  final double lng;
  final DateTime time;

  MockPosition({required this.lat, required this.lng, required this.time});

  @override
  double get latitude => lat;

  @override
  double get longitude => lng;

  @override
  DateTime get timestamp => time;

  @override
  double get accuracy => 0;

  @override
  double get altitude => 0;

  @override
  double get altitudeAccuracy => 0;

  @override
  double get heading => 0;

  @override
  double get headingAccuracy => 0;

  @override
  double get speed => 0;

  @override
  double get speedAccuracy => 0;

  @override
  bool get isMocked => true;

  @override
  int? get floor => null;

  @override
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'accuracy': accuracy,
    'altitude': altitude,
    'altitudeAccuracy': altitudeAccuracy,
    'heading': heading,
    'headingAccuracy': headingAccuracy,
    'speed': speed,
    'speedAccuracy': speedAccuracy,
    'floor': floor,
    'isMocked': isMocked,
  };
}

class FakeTrackingApi implements TrackingApiInterface {
  int calls = 0;

  @override
  Future<TrackingNotice?> addTrackingReading({
    required double lat,
    required double lon,
    required DateTime timestampUtc,
  }) async {
    calls++;
    return null;
  }

  @override
  Future<List<TrackingReadingResponse>> getMyTrackingReadings() async => [];
}

class FakeVicinityApi implements VicinityApiInterface {
  final Vicinity vicinity;
  FakeVicinityApi(this.vicinity);

  @override
  Future<Vicinity> getMyVicinity() async => vicinity;
}

class ThrowingVicinityApi implements VicinityApiInterface {
  @override
  Future<Vicinity> getMyVicinity() async {
    throw Exception('vicinity failed');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MapProvider mapProvider;

  setUp(() {
    mapProvider = MapProvider();
  });

  group('MapProvider', () {
    test('should initialize with default values', () {
      expect(mapProvider.selectedPosition, isNull);
      expect(mapProvider.selectedAddress, '');
      expect(mapProvider.currentPosition, isNull);
      expect(mapProvider.currentAddress, '');
      expect(mapProvider.isLoading, isFalse);
      expect(mapProvider.isInitialized, isFalse);
      expect(mapProvider.trackingInterval, MapProvider.defaultTrackingInterval);
    });

    test(
      'should create map controller when accessed before initialization',
      () {
        // Act
        final controller = mapProvider.mapController;

        // Assert
        expect(controller, isA<MapController>());
        // Note: Accessing the controller now sets isInitialized to true
        expect(mapProvider.isInitialized, isTrue);
      },
    );

    test('should initialize map controller explicitly', () async {
      // Act
      await mapProvider.initialize();

      // Assert
      expect(mapProvider.isInitialized, isTrue);
      expect(mapProvider.mapController, isA<MapController>());
      expect(mapProvider.isLoading, isFalse);
    });

    test('should not reinitialize if already initialized', () async {
      // Arrange
      await mapProvider.initialize();
      final initialController = mapProvider.mapController;

      // Act
      await mapProvider.initialize();

      // Assert
      expect(mapProvider.mapController, equals(initialController));
    });

    test('should update position and address', () async {
      // Arrange
      final position = MockPosition(
        lat: 52.3676,
        lng: 4.9041,
        time: DateTime.now(),
      );
      const address = 'Amsterdam, Netherlands';

      // Act
      await mapProvider.updatePosition(position, address);

      // Assert
      // The provider should update its internal state
      expect(mapProvider.currentAddress, equals(address));
      expect(mapProvider.isLoading, isFalse);
    });

    test(
      'should not update selected position if it is set to unknown',
      () async {
        // Arrange
        mapProvider.selectedAddress = '';
        final position = MockPosition(
          lat: 52.3676,
          lng: 4.9041,
          time: DateTime.now(),
        );
        const address = 'Amsterdam, Netherlands';

        // Act
        await mapProvider.updatePosition(position, address);

        // Assert
        expect(mapProvider.currentPosition, equals(position));
        expect(mapProvider.currentAddress, equals(address));
        expect(mapProvider.selectedPosition, isNot(equals(position)));
        expect(mapProvider.selectedAddress, equals(''));
      },
    );

    test('should set selected location', () {
      // Arrange
      final position = MockPosition(
        lat: 52.3676,
        lng: 4.9041,
        time: DateTime.now(),
      );
      const address = 'Amsterdam, Netherlands';

      // Act
      mapProvider.setSelectedLocation(position, address);

      // Assert
      expect(mapProvider.selectedPosition, equals(position));
      expect(mapProvider.selectedAddress, equals(address));
    });

    test('should reset to current location', () async {
      final position = MockPosition(
        lat: 51.9,
        lng: 4.5,
        time: DateTime.now(),
      );

      await mapProvider.resetToCurrentLocation(position, 'Rotterdam');

      expect(mapProvider.currentPosition, equals(position));
      expect(mapProvider.selectedPosition, equals(position));
      expect(mapProvider.currentAddress, 'Rotterdam');
      expect(mapProvider.selectedAddress, 'Rotterdam');
    });

    test('should reset state fields', () async {
      final position = MockPosition(
        lat: 52.1,
        lng: 5.1,
        time: DateTime.now(),
      );
      mapProvider.setSelectedLocation(position, 'Utrecht');
      await mapProvider.updatePosition(position, 'Utrecht');

      await mapProvider.resetState();

      expect(mapProvider.currentPosition, isNull);
      expect(mapProvider.selectedPosition, isNull);
      expect(mapProvider.currentAddress, '');
      expect(mapProvider.selectedAddress, '');
    });

    test('should set loading state', () {
      // Act
      mapProvider.setLoading(true);

      // Assert
      expect(mapProvider.isLoading, isTrue);

      // Act again
      mapProvider.setLoading(false);

      // Assert again
      expect(mapProvider.isLoading, isFalse);
    });

    test('should not start tracking when no tracking backend configured', () {
      mapProvider.startTracking();
      expect(mapProvider.isTracking, isFalse);
    });

    test('should start tracking when tracking api configured', () {
      mapProvider.setTrackingApi(FakeTrackingApi());
      mapProvider.startTracking(interval: const Duration(minutes: 10));

      expect(mapProvider.isTracking, isTrue);
      expect(mapProvider.trackingInterval, const Duration(minutes: 10));
    });

    test('should stop tracking after start', () {
      mapProvider.setTrackingApi(FakeTrackingApi());
      mapProvider.startTracking(interval: const Duration(minutes: 10));
      mapProvider.stopTracking();

      expect(mapProvider.isTracking, isFalse);
    });

    test('should clear user location and stop tracking', () async {
      final position = MockPosition(
        lat: 52.2,
        lng: 4.3,
        time: DateTime.now(),
      );
      mapProvider.setTrackingApi(FakeTrackingApi());
      mapProvider.startTracking();
      await mapProvider.updatePosition(position, 'Den Haag');
      mapProvider.setSelectedLocation(position, 'Den Haag');

      mapProvider.clearUserLocationAndStopTracking();

      expect(mapProvider.isTracking, isFalse);
      expect(mapProvider.currentPosition, isNull);
      expect(mapProvider.selectedPosition, isNull);
      expect(mapProvider.currentAddress, '');
      expect(mapProvider.selectedAddress, '');
    });

    test('should set mock vicinity data', () {
      final animals = [
        AnimalPin(
          id: 'a1',
          lat: 52.0,
          lon: 5.0,
          seenAt: DateTime.now().toUtc(),
          speciesName: 'Vos',
        ),
      ];
      final detections = [
        DetectionPin(
          id: 'd1',
          lat: 52.0,
          lon: 5.0,
          detectedAt: DateTime.now().toUtc(),
        ),
      ];
      final interactions = [
        InteractionQueryResult(
          id: 'i1',
          lat: 52.0,
          lon: 5.0,
          moment: DateTime.now().toUtc(),
        ),
      ];

      mapProvider.setMockVicinity(
        animals: animals,
        detections: detections,
        interactions: interactions,
      );

      expect(mapProvider.animalPins.length, 1);
      expect(mapProvider.detectionPins.length, 1);
      expect(mapProvider.interactions.length, 1);
    });

    test('should load vicinity data from api', () async {
      final vicinity = Vicinity(
        animals: [
          AnimalPin(
            id: 'a1',
            lat: 52.0,
            lon: 5.0,
            seenAt: DateTime.now().toUtc(),
          ),
        ],
        detections: [
          DetectionPin(
            id: 'd1',
            lat: 52.0,
            lon: 5.0,
            detectedAt: DateTime.now().toUtc(),
          ),
        ],
        interactions: [
          InteractionQueryResult(
            id: 'i1',
            lat: 52.0,
            lon: 5.0,
            moment: DateTime.now().toUtc(),
          ),
        ],
      );
      mapProvider.setVicinityApi(FakeVicinityApi(vicinity));
      mapProvider.setVicinityNotificationsEnabled(false);

      await mapProvider.loadAllPinsFromVicinity();

      expect(mapProvider.animalPins.length, 1);
      expect(mapProvider.detectionPins.length, 1);
      expect(mapProvider.interactions.length, 1);
      expect(mapProvider.animalPinsError, isNull);
      expect(mapProvider.detectionPinsError, isNull);
      expect(mapProvider.interactionsError, isNull);
    });

    test('should set vicinity errors when api fails', () async {
      mapProvider.setVicinityApi(ThrowingVicinityApi());

      await mapProvider.loadAllPinsFromVicinity();

      expect(mapProvider.animalPinsError, isNotNull);
      expect(mapProvider.detectionPinsError, isNotNull);
      expect(mapProvider.interactionsError, isNotNull);
    });

    test('should send tracking ping once when api exists', () async {
      final fakeApi = FakeTrackingApi();
      mapProvider.setTrackingApi(fakeApi);
      mapProvider.setNowProvider(() => DateTime(2026, 3, 20, 12, 0));
      final pos = MockPosition(lat: 52.0, lng: 5.0, time: DateTime.now());

      await mapProvider.sendTrackingPingFromPosition(pos);

      expect(fakeApi.calls, 1);
    });

    test('should handle dispose correctly', () {
      // Arrange
      mapProvider.initialize();

      // Act
      mapProvider.dispose();

      // Assert - no exceptions should be thrown
      expect(true, isTrue);
    });

    test('should skip sending duplicate tracking location', () async {
      final fakeApi = FakeTrackingApi();
      mapProvider.setTrackingApi(fakeApi);
      mapProvider.setNowProvider(() => DateTime(2026, 3, 20, 12, 0));

      final pos1 = MockPosition(
        lat: 52.3676,
        lng: 4.9041,
        time: DateTime.now(),
      );
      final posSame = MockPosition(
        lat: 52.3676,
        lng: 4.9041,
        time: DateTime.now(),
      );
      final posMoved = MockPosition(
        lat: 52.3677,
        lng: 4.9041,
        time: DateTime.now(),
      );

      await mapProvider.sendTrackingPingFromPosition(pos1);
      await mapProvider.sendTrackingPingFromPosition(posSame);
      await mapProvider.sendTrackingPingFromPosition(posMoved);

      expect(fakeApi.calls, 2);
    });

    test('should disable night-time tracking between 00:00 and 01:00', () async {
      final fakeApi = FakeTrackingApi();
      mapProvider.setTrackingApi(fakeApi);
      mapProvider.setNowProvider(() => DateTime(2026, 3, 20, 0, 30));
      mapProvider.startTracking();

      final pos = MockPosition(
        lat: 52.3676,
        lng: 4.9041,
        time: DateTime.now(),
      );
      await mapProvider.sendTrackingPingFromPosition(pos);

      expect(fakeApi.calls, 0);
      expect(mapProvider.isTracking, isFalse);
    });

    test('should send tracking ping outside nightly window at 01:00', () async {
      final fakeApi = FakeTrackingApi();
      mapProvider.setTrackingApi(fakeApi);
      mapProvider.setNowProvider(() => DateTime(2026, 3, 20, 1, 0));

      final pos = MockPosition(lat: 52.3, lng: 4.9, time: DateTime.now());
      await mapProvider.sendTrackingPingFromPosition(pos);

      expect(fakeApi.calls, 1);
    });

    test('should update selected position when selected address exists', () async {
      final old = MockPosition(lat: 52.1, lng: 5.1, time: DateTime.now());
      mapProvider.setSelectedLocation(old, 'Selected');

      final fresh = MockPosition(lat: 52.2, lng: 5.2, time: DateTime.now());
      await mapProvider.updatePosition(fresh, 'Selected');

      expect(mapProvider.selectedPosition, equals(fresh));
      expect(mapProvider.currentPosition, equals(fresh));
    });

    test('should keep vicinity unchanged when no api configured', () async {
      await mapProvider.loadAllPinsFromVicinity();

      expect(mapProvider.animalPins, isEmpty);
      expect(mapProvider.detectionPins, isEmpty);
      expect(mapProvider.interactions, isEmpty);
      expect(mapProvider.animalPinsError, isNull);
    });

    test('should clear pins and positions on resetMapState', () async {
      mapProvider.setMockVicinity(
        animals: [
          AnimalPin(
            id: 'a',
            lat: 52,
            lon: 5,
            seenAt: DateTime.now().toUtc(),
          ),
        ],
        detections: [
          DetectionPin(
            id: 'd',
            lat: 52,
            lon: 5,
            detectedAt: DateTime.now().toUtc(),
          ),
        ],
        interactions: [
          InteractionQueryResult(
            id: 'i',
            lat: 52,
            lon: 5,
            moment: DateTime.now().toUtc(),
          ),
        ],
      );
      final p = MockPosition(lat: 52.3, lng: 5.3, time: DateTime.now());
      await mapProvider.updatePosition(p, 'X');
      mapProvider.setSelectedLocation(p, 'X');

      await mapProvider.resetMapState();

      expect(mapProvider.animalPins, isEmpty);
      expect(mapProvider.detectionPins, isEmpty);
      expect(mapProvider.interactions, isEmpty);
      expect(mapProvider.currentPosition, isNull);
      expect(mapProvider.selectedPosition, isNull);
    });
  });
}
