// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Math Puzzle';

  @override
  String get tagline => 'Find the numbers. Connect the equations.';

  @override
  String get play => 'Play';

  @override
  String level(int number) {
    return 'Level $number';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get instructions =>
      'Tap a cell, then a number. Or drag a number onto the board. Return it to the pool or undo a move whenever you need.';

  @override
  String get undo => 'Undo';

  @override
  String get returnTile => 'Return';

  @override
  String get completed => 'Puzzle complete!';

  @override
  String get wellDone => 'Every equation is correct.';

  @override
  String get close => 'Continue';

  @override
  String get selected => 'Selected';

  @override
  String get empty => 'Empty';

  @override
  String get fixed => 'Fixed';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get incomplete => 'Incomplete';

  @override
  String equation(int number) {
    return 'Equation $number';
  }

  @override
  String get saved => 'Progress is saved automatically.';

  @override
  String get saveError =>
      'Could not save. Your progress is available for this session.';

  @override
  String get solved => 'Completed';

  @override
  String cell(int number) {
    return 'Cell $number';
  }

  @override
  String get resume => 'Continue';

  @override
  String get tutorialTap => 'Tap the empty cell after +, then tap 2 below.';

  @override
  String get paused => 'Paused';

  @override
  String get viewLevels => 'View levels';

  @override
  String get allComplete => 'You have finished all three levels!';

  @override
  String get nextLevel => 'Next level';

  @override
  String get turkish => 'Turkish';

  @override
  String get sort => 'Sort remaining numbers';

  @override
  String get chooseLevel => 'Choose a level';

  @override
  String get language => 'Language';

  @override
  String get skip => 'Skip';

  @override
  String get recoveryNotice =>
      'An unreadable save was preserved in a recovery copy. This level starts with an empty board.';

  @override
  String get editable => 'Editable';

  @override
  String get largeNumbers => 'Large numbers';

  @override
  String get home => 'Home';

  @override
  String get showTimer => 'Show timer';

  @override
  String get tutorialDrag =>
      'Now drag 3 from the pool into the last empty cell.';

  @override
  String completedCount(int count, int total) {
    return '$count of $total levels completed';
  }

  @override
  String poolTile(int number) {
    return 'Number $number in the pool';
  }

  @override
  String get divisionSymbol => 'Division symbol';

  @override
  String get settings => 'Settings';

  @override
  String tutorialStep(int number) {
    return 'Step $number of 2';
  }

  @override
  String get howToPlay => 'How to play';

  @override
  String get pause => 'Pause';

  @override
  String get english => 'English';

  @override
  String get elapsedTime => 'Play time';

  @override
  String get legacyTimeNotice =>
      'The previous version did not record time. Only play time since this update is measured.';

  @override
  String get replay => 'Play again';

  @override
  String get viewResult => 'View result';

  @override
  String get replayEasy => 'Play this easy puzzle again';

  @override
  String get startNew => 'Start new';

  @override
  String get newEasyPuzzle => 'New puzzle — Easy';

  @override
  String get keepPuzzle => 'Keep current puzzle';

  @override
  String get generationFailed =>
      'A new puzzle could not be created. Your current game is safe. Please try again.';

  @override
  String get easyPuzzle => 'Easy puzzle';

  @override
  String get generating => 'Creating puzzle…';

  @override
  String get replacePuzzleTitle => 'Start a new puzzle?';

  @override
  String easyCompletedCount(int count) {
    return 'Easy puzzles completed: $count';
  }

  @override
  String get continueEasy => 'Continue easy puzzle';

  @override
  String get fallbackNotice =>
      'A verified reserve puzzle was used because generation did not finish.';

  @override
  String get replacePuzzleBody =>
      'Your unfinished puzzle will be replaced. The three practice levels are kept.';

  @override
  String get practiceLevels => 'Practice levels';

  @override
  String get qaBanner => 'Banner area · QA';

  @override
  String get easyDifficulty => 'Easy';

  @override
  String get mediumDifficulty => 'Medium';

  @override
  String get mediumPuzzle => 'Medium puzzle';

  @override
  String get newMediumPuzzle => 'New puzzle — Medium';

  @override
  String get replayMedium => 'Play this medium puzzle again';

  @override
  String mediumCompletedCount(int count) {
    return 'Medium puzzles completed: $count';
  }
}
