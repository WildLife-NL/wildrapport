import 'package:flutter/material.dart';
import 'package:wildrapport/interfaces/location_screen_interface.dart';
import 'package:wildrapport/models/date_time_model.dart';
import 'package:wildrapport/models/enums/location_source.dart';
import 'package:wildrapport/models/enums/location_type.dart';
import 'package:wildrapport/models/enums/date_time_type.dart';
import 'package:wildrapport/interfaces/animal_sighting_reporting_interface.dart';
import 'package:provider/provider.dart';
import 'package:wildrapport/models/location_model.dart';
import 'package:wildrapport/screens/animal_condition_screen.dart';
import 'package:wildrapport/providers/map_provider.dart';
import 'package:wildrapport/utils/sighting_api_transformer.dart';

class LocationScreenManager implements LocationScreenInterface {
  // Private state variables
  bool _isLocationDropdownExpanded = false;
  bool _isDateTimeDropdownExpanded = false;
  String _selectedLocation = LocationType.current.displayText;
  String _selectedDateTime = DateTimeType.current.displayText;
  String _currentLocationText = 'Huidige locatie wordt geladen...';

  @override
  bool get isLocationDropdownExpanded => _isLocationDropdownExpanded;

  @override
  bool get isDateTimeDropdownExpanded => _isDateTimeDropdownExpanded;

  @override
  String get selectedLocation => _selectedLocation;

  @override
  String get selectedDateTime => _selectedDateTime;

  @override
  String get currentLocationText => _currentLocationText;

  Future<void> handleNextPressed(BuildContext context) async {
    final animalSighting = context.read<AnimalSightingReportingInterface>();
    final mapProvider = context.read<MapProvider>();

    debugPrint('\x1B[32m[LocationScreen] Current state before updates: ${animalSighting.getCurrentanimalSighting()?.toJson()}\x1B[0m');
    
    // Update both system and manual locations
    if (mapProvider.selectedPosition != null) {
      // Add system location (current GPS position)
      if (mapProvider.currentPosition != null) {
        final systemLocation = LocationModel(
          latitude: mapProvider.currentPosition!.latitude,
          longitude: mapProvider.currentPosition!.longitude,
          source: LocationSource.system
        );
        animalSighting.updateLocation(systemLocation);
      } else {
        debugPrint('\x1B[31m[LocationScreen] Error: No system location available\x1B[0m');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Systeem locatie is vereist'),
            backgroundColor: Colors.red,
          )
        );
        return;
      }

      // Add manual location (user selected position)
      final manualLocation = LocationModel(
        latitude: mapProvider.selectedPosition!.latitude,
        longitude: mapProvider.selectedPosition!.longitude,
        source: LocationSource.manual
      );
      animalSighting.updateLocation(manualLocation);
    } else {
      debugPrint('\x1B[31m[LocationScreen] Error: No selected location\x1B[0m');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecteer een locatie'),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    if (_selectedDateTime == DateTimeType.current.displayText) {
      final dateTimeModel = DateTimeModel(
        dateTime: DateTime.now(),
        isUnknown: false,
      );
      animalSighting.updateDateTimeModel(dateTimeModel);
    } else if (_selectedDateTime == DateTimeType.unknown.displayText) {
      final dateTimeModel = DateTimeModel(isUnknown: true);
      animalSighting.updateDateTimeModel(dateTimeModel);
    }

    debugPrint('\x1B[32m[LocationScreen] Final state after updates: ${animalSighting.getCurrentanimalSighting()?.toJson()}\x1B[0m');
    
    // Verify API payload before navigation
    try {
      final currentSighting = animalSighting.getCurrentanimalSighting();
      if (currentSighting != null) {
        debugPrint('\x1B[33m[LocationScreen] Verifying API payload...\x1B[0m');
        final apiPayload = SightingApiTransformer.transformForApi(currentSighting);
        debugPrint('\x1B[32m[LocationScreen] API payload verification successful!\x1B[0m');
      }
    } catch (e) {
      debugPrint('\x1B[31m[LocationScreen] API payload verification failed: $e\x1B[0m');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Validation Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const AnimalConditionScreen())
    );
  }
}




