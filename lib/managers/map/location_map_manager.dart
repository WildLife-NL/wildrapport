import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:wildrapport/interfaces/map/location_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_service_interface.dart';
import 'package:wildrapport/interfaces/map/map_state_interface.dart';

class LocationMapManager implements LocationServiceInterface, MapServiceInterface, MapStateInterface {
  static const double minLat = 50.75;  // Southern Netherlands border
  static const double maxLat = 53.55;  // Northern Netherlands border
  static const double minLng = 3.35;   // Western Netherlands border
  static const double maxLng = 7.25; 
  
  static const LatLng denBoschCenter = LatLng(51.6988, 5.3041);
  static const String standardTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String satelliteTileUrl = 
      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  @override
  void constrainMapCamera(MapController mapController) {
    final newCenter = constrainLatLng(mapController.camera.center);
    if (newCenter != mapController.camera.center) {
      mapController.move(newCenter, mapController.camera.zoom);
    }
  }

  @override
  void animateToLocation({
    required MapController mapController,
    required LatLng targetLocation,
    required double targetZoom,
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    final latTween = Tween<double>(
      begin: mapController.camera.center.latitude,
      end: targetLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: mapController.camera.center.longitude,
      end: targetLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: mapController.camera.zoom,
      end: targetZoom,
    );

    final controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    controller.addListener(() {
      mapController.move(
        LatLng(
          latTween.evaluate(animation),
          lngTween.evaluate(animation),
        ),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Future<Position?> determinePosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Try to get a quick fix first
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.reduced,
        timeLimit: const Duration(seconds: 5)
      ).catchError((_) => null);
      
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> getAddressFromPosition(Position position) async {
    return _placemarkToString(await placemarkFromCoordinates(position.latitude, position.longitude));
  }

  @override
  Future<String> getAddressFromLatLng(LatLng point) async {
    return _placemarkToString(await placemarkFromCoordinates(point.latitude, point.longitude));
  }

  String _placemarkToString(List<Placemark> placemarks) {
    if (placemarks.isEmpty) return 'Address not found';
    
    final place = placemarks.first;
    final List<String> addressParts = [];
    
    if (place.street?.isNotEmpty ?? false) {
      addressParts.add(place.street!);
    }
    
    if (place.subLocality?.isNotEmpty ?? false) {
      addressParts.add(place.subLocality!);
    }
    
    if (place.locality?.isNotEmpty ?? false) {
      addressParts.add(place.locality!);
    }
    
    if (place.postalCode?.isNotEmpty ?? false) {
      addressParts.add(place.postalCode!);
    }
    
    return addressParts.join(', ');
  }

  @override
  bool isLocationInNetherlands(double lat, double lon) {
    return lat >= minLat && lat <= maxLat && lon >= minLng && lon <= maxLng;
  }

  @override
  LatLng constrainLatLng(LatLng point) {
    return LatLng(
      point.latitude.clamp(minLat, maxLat),
      point.longitude.clamp(minLng, maxLng),
    );
  }
}
