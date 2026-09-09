// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'MCU Tracker';

  @override
  String get missionLogTitle => 'MISSIEDOSSIER';

  @override
  String errorCouldNotRefresh(String error) {
    return 'Kon niet verversen: $error';
  }

  @override
  String get filterAll => 'Alles';

  @override
  String get filterCritical => 'Kritiek';

  @override
  String get filterCriticalHigh => 'Kritiek+Hoog';

  @override
  String get filterUnwatched => 'Nog te kijken';

  @override
  String get filterMovies => 'Films';

  @override
  String get filterSeries => 'Series';

  @override
  String get noTitlesMatchFilter => 'Geen titels binnen dit filter.';

  @override
  String get missionProgress => 'Missievoortgang';

  @override
  String hoursWatched(String hours) {
    return '$hours bekeken';
  }

  @override
  String hoursRemaining(String hours) {
    return '$hours te gaan';
  }

  @override
  String hoursTotal(String hours) {
    return '$hours totaal';
  }

  @override
  String get bulkSkipTitle => 'Massaal overslaan';

  @override
  String get sortSectionTitle => 'Sorteervolgorde';

  @override
  String get sortSectionDescription =>
      'Kies hoe de lijst geordend wordt. Puur lokaal, beïnvloedt alleen jouw eigen weergave.';

  @override
  String get sortStoryOrder => 'Chronologisch (verhaalvolgorde)';

  @override
  String get sortReleaseOrder => 'Releasevolgorde';

  @override
  String get bulkSkipDescription =>
      'Sluit hele importantie-niveaus uit van je watchbar en \"nog te kijken\"-filter. Dit is puur lokaal en persoonlijk — niemand anders ziet jouw keuzes.';

  @override
  String get skipOptionalLow => 'Optioneel (low)';

  @override
  String get skipMediumOptional => 'Gemiddeld + Optioneel';

  @override
  String get skipEverythingExceptCritical => 'Alles behalve Kritiek';

  @override
  String get reenableEverything => 'Alles weer inschakelen';

  @override
  String skippedSnackbar(String label) {
    return '$label uitgeschakeld';
  }

  @override
  String skipButtonLabel(String label) {
    return 'Sla over: $label';
  }

  @override
  String get estimatedPlacement => '⚠️ gegokte plaatsing';

  @override
  String get noSynopsisFound =>
      'Geen synopsis gevonden op TMDB voor deze titel.';

  @override
  String get noSynopsisAvailable => 'Geen synopsis beschikbaar.';
}
