import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MCU Tracker'**
  String get appTitle;

  /// No description provided for @missionLogTitle.
  ///
  /// In en, this message translates to:
  /// **'MISSION LOG'**
  String get missionLogTitle;

  /// No description provided for @errorCouldNotRefresh.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh: {error}'**
  String errorCouldNotRefresh(String error);

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get filterCritical;

  /// No description provided for @filterCriticalHigh.
  ///
  /// In en, this message translates to:
  /// **'Critical+High'**
  String get filterCriticalHigh;

  /// No description provided for @filterUnwatched.
  ///
  /// In en, this message translates to:
  /// **'Unwatched'**
  String get filterUnwatched;

  /// No description provided for @filterMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get filterMovies;

  /// No description provided for @filterSeries.
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get filterSeries;

  /// No description provided for @noTitlesMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No titles match this filter.'**
  String get noTitlesMatchFilter;

  /// No description provided for @missionProgress.
  ///
  /// In en, this message translates to:
  /// **'Mission Progress'**
  String get missionProgress;

  /// No description provided for @hoursWatched.
  ///
  /// In en, this message translates to:
  /// **'{hours} watched'**
  String hoursWatched(String hours);

  /// No description provided for @hoursRemaining.
  ///
  /// In en, this message translates to:
  /// **'{hours} remaining'**
  String hoursRemaining(String hours);

  /// No description provided for @hoursTotal.
  ///
  /// In en, this message translates to:
  /// **'{hours} total'**
  String hoursTotal(String hours);

  /// No description provided for @bulkSkipTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk Skip'**
  String get bulkSkipTitle;

  /// No description provided for @sortSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort Order'**
  String get sortSectionTitle;

  /// No description provided for @sortSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose how the list is ordered. Purely local, only affects your own view.'**
  String get sortSectionDescription;

  /// No description provided for @sortStoryOrder.
  ///
  /// In en, this message translates to:
  /// **'Chronological (story order)'**
  String get sortStoryOrder;

  /// No description provided for @sortReleaseOrder.
  ///
  /// In en, this message translates to:
  /// **'Release order'**
  String get sortReleaseOrder;

  /// No description provided for @bulkSkipDescription.
  ///
  /// In en, this message translates to:
  /// **'Exclude whole importance levels from your watchbar and \"unwatched\" filter. This is purely local and personal — nobody else sees your choices.'**
  String get bulkSkipDescription;

  /// No description provided for @skipOptionalLow.
  ///
  /// In en, this message translates to:
  /// **'Optional (low)'**
  String get skipOptionalLow;

  /// No description provided for @skipMediumOptional.
  ///
  /// In en, this message translates to:
  /// **'Medium + Optional'**
  String get skipMediumOptional;

  /// No description provided for @skipEverythingExceptCritical.
  ///
  /// In en, this message translates to:
  /// **'Everything except Critical'**
  String get skipEverythingExceptCritical;

  /// No description provided for @reenableEverything.
  ///
  /// In en, this message translates to:
  /// **'Re-enable everything'**
  String get reenableEverything;

  /// No description provided for @skippedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Skipped: {label}'**
  String skippedSnackbar(String label);

  /// No description provided for @skipButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip: {label}'**
  String skipButtonLabel(String label);

  /// No description provided for @estimatedPlacement.
  ///
  /// In en, this message translates to:
  /// **'⚠️ estimated placement'**
  String get estimatedPlacement;

  /// No description provided for @noSynopsisFound.
  ///
  /// In en, this message translates to:
  /// **'No synopsis found on TMDB for this title.'**
  String get noSynopsisFound;

  /// No description provided for @noSynopsisAvailable.
  ///
  /// In en, this message translates to:
  /// **'No synopsis available.'**
  String get noSynopsisAvailable;

  /// No description provided for @supportSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportSectionTitle;

  /// No description provided for @viewOnGithub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGithub;

  /// No description provided for @buyMeAMonster.
  ///
  /// In en, this message translates to:
  /// **'Buy me a Monster'**
  String get buyMeAMonster;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
