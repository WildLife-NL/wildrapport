import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wildrapport/interfaces/data_apis/profile_api_interface.dart';
import 'package:wildrapport/interfaces/reporting/interaction_interface.dart';
import 'package:wildrapport/models/animal_waarneming_models/animal_sighting_model.dart';
import 'package:wildrapport/models/beta_models/belonging_damage_report_model.dart';
import 'package:wildrapport/models/beta_models/interaction_response_model.dart';
import 'package:wildrapport/models/beta_models/possesion_model.dart';
import 'package:wildrapport/models/beta_models/report_location_model.dart';
import 'package:wildrapport/models/enums/interaction_type.dart';
import 'package:wildrapport/utils/schademelding_provider_sync.dart';

/// Submits schademelding wizard data to `POST /interaction/` (typeID 2).
class SchademeldingSubmit {
  SchademeldingSubmit._();

  static Future<void> ensureUserIdCached(ProfileApiInterface profileApi) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('userID');
    if (existing != null && existing.isNotEmpty) return;

    final profile = await profileApi.fetchMyProfile();
    await prefs.setString('userID', profile.userID);
  }

  static BelongingDamageReport buildReport(AnimalSightingModel sighting) {
    final belonging = SchademeldingProviderSync.resolveBelongingName(sighting);
    if (belonging.isEmpty) {
      throw StateError(
        'Geen beschadigd object geselecteerd. Ga terug en kies gewas, vee of eigendom.',
      );
    }

    final location = SchademeldingProviderSync.firstLocationWithCoordinates(
      sighting.locations,
    );
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

    final moment = sighting.dateTime?.dateTime ?? DateTime.now();
    final speciesId = sighting.animalSelected?.animalId?.trim() ?? '';

    if (speciesId.isEmpty) {
      throw StateError(
        'Geen verdacht dier geselecteerd. Kies een diersoort en probeer opnieuw.',
      );
    }

    final descriptionRaw = (sighting.additionalInfo?.trim().isNotEmpty ?? false)
        ? sighting.additionalInfo!.trim()
        : (sighting.description?.trim() ?? '');
    final description =
        descriptionRaw.isEmpty ? null : descriptionRaw;

    return BelongingDamageReport(
      possesion: Possesion(possesionID: null, possesionName: belonging, category: null),
      impactedAreaType: 'square-meters',
      impactedArea: 1,
      currentImpactDamages: 0,
      estimatedTotalDamages: 0,
      estimatedLossBucket: SchademeldingProviderSync.mapExpectedLossToApiBucket(
        sighting.expectedLoss,
      ),
      description: description,
      suspectedSpeciesID: speciesId,
      userSelectedLocation: reportLocation,
      systemLocation: reportLocation,
      userSelectedDateTime: moment,
      systemDateTime: moment,
      preventiveMeasures: sighting.preventiveMeasures ?? false,
      preventiveMeasuresDescription:
          _optionalTrim(sighting.preventiveMeasuresDescription),
    );
  }

  static String? _optionalTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static Future<InteractionResponse> submit({
    required BuildContext context,
    required AnimalSightingModel sighting,
  }) async {
    final interactionManager = context.read<InteractionInterface>();
    final profileApi = context.read<ProfileApiInterface>();

    await ensureUserIdCached(profileApi);

    final report = buildReport(sighting);
    final response = await interactionManager.postInteraction(
      report,
      InteractionType.gewasschade,
    );

    if (response == null) {
      throw Exception(
        'Geen verbinding of verzenden mislukt. Controleer internet en probeer opnieuw.',
      );
    }

    return response;
  }
}
