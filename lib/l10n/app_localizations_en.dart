// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MCU Tracker';

  @override
  String get missionLogTitle => 'MISSION LOG';

  @override
  String errorCouldNotRefresh(String error) {
    return 'Could not refresh: $error';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterCritical => 'Critical';

  @override
  String get filterCriticalHigh => 'Critical+High';

  @override
  String get filterUnwatched => 'Unwatched';

  @override
  String get filterMovies => 'Movies';

  @override
  String get filterSeries => 'Series';

  @override
  String get noTitlesMatchFilter => 'No titles match this filter.';

  @override
  String get missionProgress => 'Mission Progress';

  @override
  String hoursWatched(String hours) {
    return '$hours watched';
  }

  @override
  String hoursRemaining(String hours) {
    return '$hours remaining';
  }

  @override
  String hoursTotal(String hours) {
    return '$hours total';
  }

  @override
  String get bulkSkipTitle => 'Bulk Skip';

  @override
  String get sortSectionTitle => 'Sort Order';

  @override
  String get sortSectionDescription =>
      'Choose how the list is ordered. Purely local, only affects your own view.';

  @override
  String get sortStoryOrder => 'Chronological (story order)';

  @override
  String get sortReleaseOrder => 'Release order';

  @override
  String get bulkSkipDescription =>
      'Exclude whole importance levels from your watchbar and \"unwatched\" filter. This is purely local and personal — nobody else sees your choices.';

  @override
  String get skipOptionalLow => 'Optional (low)';

  @override
  String get skipMediumOptional => 'Medium + Optional';

  @override
  String get skipEverythingExceptCritical => 'Everything except Critical';

  @override
  String get reenableEverything => 'Re-enable everything';

  @override
  String skippedSnackbar(String label) {
    return 'Skipped: $label';
  }

  @override
  String skipButtonLabel(String label) {
    return 'Skip: $label';
  }

  @override
  String get estimatedPlacement => '⚠️ estimated placement';

  @override
  String get noSynopsisFound => 'No synopsis found on TMDB for this title.';

  @override
  String get noSynopsisAvailable => 'No synopsis available.';
}
