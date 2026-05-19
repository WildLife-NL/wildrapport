/// API values for `reportOfSighting.humanActivity` and `perceivedAnimalActivity`.
class SightingReportActivityOption {
  final String apiValue;
  final String labelNl;

  const SightingReportActivityOption(this.apiValue, this.labelNl);
}

class SightingReportActivities {
  SightingReportActivities._();

  static const String defaultHumanActivity = 'unknown';
  static const String defaultPerceivedAnimalActivity = 'unknown';

  static const List<SightingReportActivityOption> humanActivities = [
    SightingReportActivityOption('walking', 'Wandelen'),
    SightingReportActivityOption('running', 'Hardlopen'),
    SightingReportActivityOption('cycling', 'Fietsen'),
    SightingReportActivityOption('driving', 'Auto / motor'),
    SightingReportActivityOption('horsebackRiding', 'Paardrijden'),
    SightingReportActivityOption('boating', 'Varen'),
    SightingReportActivityOption('stationary', 'Stilstaan / zitten'),
    SightingReportActivityOption('other', 'Anders'),
    SightingReportActivityOption('unknown', 'Onbekend'),
  ];

  static const List<SightingReportActivityOption> perceivedAnimalActivities = [
    SightingReportActivityOption('resting', 'Rusten'),
    SightingReportActivityOption('moving', 'Bewegen'),
    SightingReportActivityOption('feeding', 'Voeden'),
    SightingReportActivityOption('grooming', 'Verzorgen'),
    SightingReportActivityOption('playing', 'Spelen'),
    SightingReportActivityOption('fighting', 'Vechten'),
    SightingReportActivityOption('fleeing', 'Vluchten'),
    SightingReportActivityOption('other', 'Anders'),
    SightingReportActivityOption('unknown', 'Onbekend'),
  ];
}
