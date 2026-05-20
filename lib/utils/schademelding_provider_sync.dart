import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/beta_models/location_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/providers/belonging_damage_report_provider.dart';

/// Fills [BelongingDamageReportProvider] from the schademelding wizard
/// ([AnimalSightingModel]) before [BelongingDamageReportManager.postInteraction].
class SchademeldingProviderSync {
  SchademeldingProviderSync._();

  static const Set<String> _livestockBelongingNames = {
    'Rund',
    'Runderen',
    'Schapen',
    'Geiten',
    'Paarden',
    'Pluimvee',
    'Varkens',
    'Ree',
    'Ander',
  };

  static void applyToProvider(
    BelongingDamageReportProvider provider,
    AnimalSightingModel sighting, {
    String? fallbackBelongingName,
  }) {
    final belonging = resolveBelongingName(
      sighting,
      fallback: fallbackBelongingName,
    );
    if (belonging.isEmpty) {
      throw StateError(
        'Geen beschadigd object geselecteerd. Ga terug en kies gewas, vee of eigendom.',
      );
    }

    final location = firstLocationWithCoordinates(sighting.locations);
    if (location == null) {
      throw StateError('Geen locatie beschikbaar voor deze schademelding.');
    }

    final reportLocation = ReportLocation(
      latitude: location.latitude,
      longtitude: location.longitude,
      cityName: location.cityName,
      streetName: location.streetName,
      houseNumber: location.houseNumber,
    );

    final isLivestock = _isLivestockDamage(belonging);
    final impactCount = sighting.animalCount;
    final impactValue = isLivestock
        ? (impactCount != null && impactCount > 0 ? impactCount : 1)
        : 1;

    provider.setImpactedCrop(belonging);
    provider.setDamageCategory(isLivestock ? 'livestock' : 'crops');
    provider.setImpactedAreaType(isLivestock ? 'units' : 'vierkante meters');
    provider.setImpactedArea(impactValue.toDouble());
    provider.setDescription(
      (sighting.additionalInfo?.trim().isNotEmpty ?? false)
          ? sighting.additionalInfo!.trim()
          : (sighting.description?.trim() ?? ''),
    );
    provider.setSuspectedAnimal(sighting.animalSelected?.animalId ?? '');
    provider.setSystemLocation(reportLocation);
    provider.setUserLocation(reportLocation);
    provider.setEstimatedLossBucket(
      _mapExpectedLossToApiBucket(sighting.expectedLoss),
    );
    provider.setPreventiveMeasures(sighting.preventiveMeasures ?? false);
    provider.setPreventiveMeasuresDescription(
      sighting.preventiveMeasuresDescription?.trim() ?? '',
    );
    provider.setReportMoment(sighting.dateTime?.dateTime ?? DateTime.now());

    if (isLivestock) {
      provider.setLivestockAmount(impactValue);
    }
  }

  /// Best-effort name for API field `reportOfDamage.belonging`.
  static String resolveBelongingName(
    AnimalSightingModel sighting, {
    String? fallback,
  }) {
    final crop = sighting.cropType?.trim();
    if (crop != null && crop.isNotEmpty) {
      return crop;
    }
    final fb = fallback?.trim();
    if (fb != null && fb.isNotEmpty) {
      return fb;
    }
    final desc = sighting.description?.trim();
    if (desc != null && desc.isNotEmpty) {
      return desc;
    }
    return '';
  }

  static LocationModel? firstLocationWithCoordinates(
    List<LocationModel>? locations,
  ) {
    if (locations == null) return null;
    for (final loc in locations) {
      if (loc.latitude != null && loc.longitude != null) {
        return loc;
      }
    }
    return null;
  }

  static String mapExpectedLossToApiBucket(String? uiLabel) =>
      _mapExpectedLossToApiBucket(uiLabel);

  static bool _isLivestockDamage(String belonging) {
    if (_livestockBelongingNames.contains(belonging)) return true;
    final lower = belonging.toLowerCase();
    return lower == 'vee' || lower.contains('vee');
  }

  static String _mapExpectedLossToApiBucket(String? uiLabel) {
    switch (uiLabel) {
      case '€0-€250':
        return '0-250';
      case '€250-€500':
        return '250-500';
      case '€500-€1000':
        return '500-1000';
      case '€1000-€2000':
        return '1000-2000';
      case '€2000-€5000':
        return '2000-5000';
      case '€5000+':
        return '5000+';
      default:
        return 'unknown';
    }
  }
}
