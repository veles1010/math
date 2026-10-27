import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Math Puzzle'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Find the numbers. Connect the equations.'**
  String get tagline;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {number}'**
  String level(int number);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell, then a number. Or drag a number onto the board. Return it to the pool or undo a move whenever you need.'**
  String get instructions;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @returnTile.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnTile;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Puzzle complete!'**
  String get completed;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Every equation is correct.'**
  String get wellDone;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get close;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @incomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get incomplete;

  /// No description provided for @equation.
  ///
  /// In en, this message translates to:
  /// **'Equation {number}'**
  String equation(int number);

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Progress is saved automatically.'**
  String get saved;

  /// No description provided for @saveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Your progress is available for this session.'**
  String get saveError;

  /// No description provided for @solved.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get solved;

  /// No description provided for @cell.
  ///
  /// In en, this message translates to:
  /// **'Cell {number}'**
  String cell(int number);

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get resume;

  /// No description provided for @tutorialTap.
  ///
  /// In en, this message translates to:
  /// **'Tap the empty cell after +, then tap 2 below.'**
  String get tutorialTap;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @viewLevels.
  ///
  /// In en, this message translates to:
  /// **'View levels'**
  String get viewLevels;

  /// No description provided for @allComplete.
  ///
  /// In en, this message translates to:
  /// **'You have finished all three levels!'**
  String get allComplete;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next level'**
  String get nextLevel;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort remaining numbers'**
  String get sort;

  /// No description provided for @chooseLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose a level'**
  String get chooseLevel;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @recoveryNotice.
  ///
  /// In en, this message translates to:
  /// **'An unreadable save was preserved in a recovery copy. This level starts with an empty board.'**
  String get recoveryNotice;

  /// No description provided for @editable.
  ///
  /// In en, this message translates to:
  /// **'Editable'**
  String get editable;

  /// No description provided for @largeNumbers.
  ///
  /// In en, this message translates to:
  /// **'Large numbers'**
  String get largeNumbers;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @showTimer.
  ///
  /// In en, this message translates to:
  /// **'Show timer'**
  String get showTimer;

  /// No description provided for @tutorialDrag.
  ///
  /// In en, this message translates to:
  /// **'Now drag 3 from the pool into the last empty cell.'**
  String get tutorialDrag;

  /// No description provided for @completedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} levels completed'**
  String completedCount(int count, int total);

  /// No description provided for @poolTile.
  ///
  /// In en, this message translates to:
  /// **'Number {number} in the pool'**
  String poolTile(int number);

  /// No description provided for @divisionSymbol.
  ///
  /// In en, this message translates to:
  /// **'Division symbol'**
  String get divisionSymbol;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @tutorialStep.
  ///
  /// In en, this message translates to:
  /// **'Step {number} of 2'**
  String tutorialStep(int number);

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @elapsedTime.
  ///
  /// In en, this message translates to:
  /// **'Play time'**
  String get elapsedTime;

  /// No description provided for @legacyTimeNotice.
  ///
  /// In en, this message translates to:
  /// **'The previous version did not record time. Only play time since this update is measured.'**
  String get legacyTimeNotice;

  /// No description provided for @replay.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get replay;

  /// No description provided for @viewResult.
  ///
  /// In en, this message translates to:
  /// **'View result'**
  String get viewResult;

  /// No description provided for @replayEasy.
  ///
  /// In en, this message translates to:
  /// **'Play this easy puzzle again'**
  String get replayEasy;

  /// No description provided for @startNew.
  ///
  /// In en, this message translates to:
  /// **'Start new'**
  String get startNew;

  /// No description provided for @newEasyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'New puzzle — Easy'**
  String get newEasyPuzzle;

  /// No description provided for @keepPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Keep current puzzle'**
  String get keepPuzzle;

  /// No description provided for @generationFailed.
  ///
  /// In en, this message translates to:
  /// **'A new puzzle could not be created. Your current game is safe. Please try again.'**
  String get generationFailed;

  /// No description provided for @easyPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Easy puzzle'**
  String get easyPuzzle;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Creating puzzle…'**
  String get generating;

  /// No description provided for @replacePuzzleTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new puzzle?'**
  String get replacePuzzleTitle;

  /// No description provided for @easyCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'Easy puzzles completed: {count}'**
  String easyCompletedCount(int count);

  /// No description provided for @continueEasy.
  ///
  /// In en, this message translates to:
  /// **'Continue easy puzzle'**
  String get continueEasy;

  /// No description provided for @fallbackNotice.
  ///
  /// In en, this message translates to:
  /// **'A verified reserve puzzle was used because generation did not finish.'**
  String get fallbackNotice;

  /// No description provided for @replacePuzzleBody.
  ///
  /// In en, this message translates to:
  /// **'Your unfinished puzzle will be replaced. The three practice levels are kept.'**
  String get replacePuzzleBody;

  /// No description provided for @practiceLevels.
  ///
  /// In en, this message translates to:
  /// **'Practice levels'**
  String get practiceLevels;

  /// No description provided for @qaBanner.
  ///
  /// In en, this message translates to:
  /// **'Banner area · QA'**
  String get qaBanner;

  /// No description provided for @easyDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easyDifficulty;

  /// No description provided for @mediumDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumDifficulty;

  /// No description provided for @mediumPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Medium puzzle'**
  String get mediumPuzzle;

  /// No description provided for @newMediumPuzzle.
  ///
  /// In en, this message translates to:
  /// **'New puzzle — Medium'**
  String get newMediumPuzzle;

  /// No description provided for @replayMedium.
  ///
  /// In en, this message translates to:
  /// **'Play this medium puzzle again'**
  String get replayMedium;

  /// No description provided for @mediumCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'Medium puzzles completed: {count}'**
  String mediumCompletedCount(int count);
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
