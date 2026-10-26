import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/board.dart';
import 'package:math_puzzle/game_screen.dart' show ResultView, ConfettiBurst;
import 'package:math_puzzle/store.dart';
import 'package:math_puzzle/main.dart';
import 'package:math_puzzle/theme.dart';
import 'package:math_puzzle/l10n/app_localizations.dart';

Future<void> mount(
  WidgetTester tester,
  Game game, {
  double width = 390,
  bool dark = false,
  String language = 'en',
  bool large = false,
  bool slash = false,
  ValueChanged<bool>? tutorial,
  VoidCallback? changed,
}) async {
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: (dark ? ThemePalette.night : ThemePalette.warm).build(
        dark ? Brightness.dark : Brightness.light,
      ),
      home: GameScreen(
        game: game,
        number: 1,
        settings: AppSettings()
          ..largeNumbers = large
          ..slash = slash,
        onChanged: changed ?? () {},
        onTutorialDone: tutorial,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> dragTo(WidgetTester tester, Finder from, Finder to) async {
  final gesture = await tester.startGesture(tester.getCenter(from));
  await gesture.moveBy(const Offset(0, -12));
  await tester.pump();
  await gesture.moveTo(tester.getCenter(to) - TileDrag.feedbackCenterOffset);
  await tester.pump();
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  test('atomic board move, replacement, return and no-op drops', () {
    final game = Game(puzzles.first);
    expect(game.transfer('one-1', 'b'), isTrue);
    expect(game.transfer('one-4', 'e'), isTrue);
    final old = Map.of(game.placed);
    expect(game.transfer('one-1', 'e'), isTrue);
    expect(game.placed, {'e': 'one-1'});
    expect(game.available.any((t) => t.id == 'one-4'), isTrue);
    game.undo();
    expect(game.placed, old);
    expect(game.transfer('one-1', null), isTrue);
    expect(game.value('b'), isNull);
    game.undo();
    expect(game.placed, old);
    final before = jsonEncode(game.toJson());
    for (final target in ['a', 'operator', 'outside', 'b']) {
      expect(game.transfer('one-1', target), isFalse);
    }
    expect(jsonEncode(game.toJson()), before);
  });
  test('stable pool sort preserves used slots and undo', () {
    final game = Game(puzzles[1]);
    game.transfer('two-2', 'c');
    final used = game.poolOrder.indexOf('two-2');
    final history = jsonEncode(game.toJson()['history']);
    game.sortPool();
    expect(game.poolOrder[used], 'two-2');
    expect(game.available.map((t) => t.value), [3, 5, 12, 17]);
    expect(jsonEncode(game.toJson()['history']), history);
    game.undo();
    expect(game.available.length, 5);
    final equal = Game(puzzles.first)..sortPool();
    expect(equal.available.where((t) => t.value == 4).map((t) => t.id), [
      'one-1',
      'one-4',
      'one-5',
    ]);
  });
  test('legacy save migration retains progress and undo', () {
    final game = Game(puzzles.first);
    expect(
      game.restore({
        'placed': {'b': 'one-1'},
        'history': [{}],
      }),
      isTrue,
    );
    expect(game.value('b'), 4);
    expect(game.clock.elapsed, Duration.zero);
    game.undo();
    expect(game.placed, isEmpty);
    final complete = Game(puzzles.first);
    for (final e in {
      'b': 'one-1',
      'c': 'one-2',
      'e': 'one-4',
      'f': 'one-5',
      'g': 'one-6',
    }.entries) {
      complete.transfer(e.value, e.key);
    }
    final loaded = Game(puzzles.first)
      ..restore({'placed': complete.placed, 'history': []});
    expect(loaded.resultPresented, isTrue);
  });
  test('monotonic time stops, resumes and survives save', () {
    var now = Duration.zero;
    final clock = PlayClock(now: () => now);
    clock.start();
    now += const Duration(seconds: 12);
    clock.stop();
    now += const Duration(minutes: 8);
    expect(clock.elapsed.inSeconds, 12);
    clock.start();
    now += const Duration(seconds: 3);
    clock.stop();
    final game = Game(puzzles.first, clock: clock);
    final loaded = Game(puzzles.first)..restore(game.toJson());
    expect(loaded.clock.elapsed.inSeconds, 15);
    expect(loaded.clock.running, isFalse);
  });
  test('unreadable saved bytes are backed up and reported', () async {
    SharedPreferences.setMockInitialValues({
      'game-one': 'unreadable',
      'appearance': 'dark',
    });
    final store = AppStore();
    await store.load();
    expect(store.recovered, isTrue);
    expect(store.settings.theme, ThemeMode.dark);
    await store.save();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('recovery-game-one'), 'unreadable');
  });
  for (final width in [320.0, 390.0]) {
    for (final language in ['en', 'tr']) {
      for (final dark in [false, true]) {
        for (final large in [false, true]) {
          testWidgets('layout $width $language dark=$dark large=$large', (
            tester,
          ) async {
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            await mount(
              tester,
              Game(puzzles.first),
              width: width,
              dark: dark,
              language: language,
              large: large,
            );
            expect(tester.takeException(), isNull);
            final first = tester.getRect(
              find.byKey(const ValueKey('slot-one-1')),
            );
            final last = tester.getRect(
              find.byKey(const ValueKey('slot-one-6')),
            );
            expect(first.left, greaterThanOrEqualTo(0));
            expect(last.right, lessThanOrEqualTo(width));
            expect(find.text('Equation 1: Incomplete'), findsNothing);
          });
        }
      }
    }
  }
  testWidgets('tap and drag use the same transaction, retain slots and undo', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final game = Game(puzzles.first);
    await mount(tester, game);
    final slotBefore = tester.getRect(find.byKey(const ValueKey('slot-one-2')));
    await tester.tap(find.byKey(const ValueKey('cell-b')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-one-1')));
    await tester.pumpAndSettle();
    final tapped = Map.of(game.placed);
    await tester.tap(find.byKey(const ValueKey('undo')));
    await tester.pumpAndSettle();
    await dragTo(
      tester,
      find.byKey(const ValueKey('tile-one-1')),
      find.byKey(const ValueKey('cell-b')),
    );
    expect(game.placed, tapped);
    expect(
      tester.getRect(find.byKey(const ValueKey('slot-one-2'))),
      slotBefore,
    );
    await dragTo(
      tester,
      find.byKey(const ValueKey('tile-one-4')),
      find.byKey(const ValueKey('cell-e')),
    );
    await dragTo(
      tester,
      find.byKey(const ValueKey('cell-b')),
      find.byKey(const ValueKey('cell-e')),
    );
    expect(game.placed, {'e': 'one-1'});
    expect(find.byKey(const ValueKey('tile-one-4')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('undo')));
    await tester.pumpAndSettle();
    expect(game.placed, {'b': 'one-1', 'e': 'one-4'});
    await dragTo(
      tester,
      find.byKey(const ValueKey('cell-b')),
      find.byKey(const ValueKey('slot-one-1')),
    );
    expect(game.placed, {'e': 'one-4'});
    await tester.tap(find.byKey(const ValueKey('undo')));
    await tester.pumpAndSettle();
    expect(game.placed, {'b': 'one-1', 'e': 'one-4'});
    final unchanged = jsonEncode(game.toJson()['history']);
    await dragTo(
      tester,
      find.byKey(const ValueKey('tile-one-2')),
      find.byKey(const ValueKey('cell-a')),
    );
    expect(jsonEncode(game.toJson()['history']), unchanged);
    expect(game.placed, {'b': 'one-1', 'e': 'one-4'});
    expect(tester.takeException(), isNull);
  });
  testWidgets('active drag is transient and navigation cannot lose a tile', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final game = Game(puzzles.first);
    var saves = 0;
    await mount(tester, game, changed: () => saves++);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('tile-one-1'))),
    );
    await gesture.moveBy(const Offset(0, -100));
    await tester.pump();
    expect(game.placed, isEmpty);
    expect(game.canUndo, isFalse);
    expect(saves, 0);
    await tester.pumpWidget(const SizedBox());
    await gesture.up();
    await tester.pumpAndSettle();
    expect(game.available.length, 5);
    expect(game.canUndo, isFalse);
  });
  testWidgets(
    'background and explicit pause stop time; visibility does not reset it',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var now = Duration.zero;
      final game = Game(puzzles.first, clock: PlayClock(now: () => now));
      await mount(tester, game);
      now += const Duration(seconds: 9);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      now += const Duration(minutes: 2);
      expect(game.clock.elapsed.inSeconds, 9);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(game.clock.running, isFalse);
      await tester.tap(find.byKey(const ValueKey('resume')));
      await tester.pump();
      now += const Duration(seconds: 4);
      await tester.tap(find.byKey(const ValueKey('pause')));
      await tester.pump();
      now += const Duration(seconds: 100);
      expect(game.clock.elapsed.inSeconds, 13);
      final loaded = Game(puzzles.first)..restore(game.toJson());
      expect(loaded.clock.elapsed.inSeconds, 13);
      final screen = tester.widget<GameScreen>(find.byType(GameScreen));
      screen.settings!.timer = false;
      await tester.pump();
      expect(game.clock.elapsed.inSeconds, 13);
    },
  );
  testWidgets('tutorial requires tap then drag and uses a separate game', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final game = Game(const TutorialPuzzle());
    bool? finished;
    await mount(tester, game, tutorial: (value) => finished = value);
    await dragTo(
      tester,
      find.byKey(const ValueKey('tile-tutorial-1')),
      find.byKey(const ValueKey('cell-b')),
    );
    expect(game.placed, isEmpty);
    await tester.tap(find.byKey(const ValueKey('cell-b')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-tutorial-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cell-c')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('tile-tutorial-2')));
    await tester.pumpAndSettle();
    expect(game.value('c'), isNull);
    await dragTo(
      tester,
      find.byKey(const ValueKey('tile-tutorial-2')),
      find.byKey(const ValueKey('cell-c')),
    );
    expect(finished, isTrue);
    expect(Game(puzzles.first).placed, isEmpty);
  });
  testWidgets('first launch offers tutorial and skipping persists', (
    tester,
  ) async {
    await tester.pumpWidget(const MathPuzzleApp());
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 2'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('settings-v2')!)['tutorial'], 'skipped');
  });
  testWidgets('shared cell keeps wrong feedback alongside a correct equation', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final game = Game(puzzles.first);
    game.transfer('one-1', 'b');
    game.transfer('one-2', 'c');
    game.transfer('one-6', 'e');
    await mount(tester, game);
    final shared = tester.widget<Stone>(find.byKey(const ValueKey('cell-c')));
    expect(shared.correct, isTrue);
    expect(shared.wrong, isTrue);
    expect(game.equationStates, [true, false, null]);
  });
  testWidgets(
    'completion stops time and celebrates once across rebuild and reload',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var now = Duration.zero;
      final game = Game(puzzles.first, clock: PlayClock(now: () => now));
      for (final e in {
        'b': 'one-1',
        'c': 'one-2',
        'e': 'one-4',
        'f': 'one-5',
      }.entries) {
        game.transfer(e.value, e.key);
      }
      await mount(tester, game);
      now += const Duration(seconds: 23);
      await tester.tap(find.byKey(const ValueKey('cell-g')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tile-one-6')));
      await tester.pump();
      expect(find.byType(ResultView), findsOneWidget);
      expect(find.byType(ConfettiBurst), findsOneWidget);
      await tester.pumpAndSettle();
      expect(game.resultPresented, isTrue);
      expect(game.clock.running, isFalse);
      now += const Duration(minutes: 2);
      expect(game.clock.elapsed.inSeconds, 23);
      final restored = Game(puzzles.first)..restore(game.toJson());
      await tester.pumpWidget(const SizedBox());
      await mount(tester, restored);
      expect(find.byType(ResultView), findsOneWidget);
      expect(find.byType(ConfettiBurst), findsNothing);
      expect(find.textContaining('00:23'), findsWidgets);
    },
  );
  test(
    'preferences, pool order, elapsed time and tutorial survive a full reload',
    () async {
      final store = AppStore();
      await store.load();
      store.settings
        ..theme = ThemeMode.dark
        ..language = 'tr'
        ..largeNumbers = true
        ..slash = true
        ..timer = false
        ..tutorial = 'completed';
      store.games[1].sortPool();
      store.games[0].clock.restore(const Duration(seconds: 42));
      await store.save();
      final restored = AppStore();
      await restored.load();
      expect(restored.settings.toJson(), store.settings.toJson());
      expect(restored.settings.theme, ThemeMode.dark);
      expect(restored.games[1].poolOrder, store.games[1].poolOrder);
      expect(restored.games[0].clock.elapsed.inSeconds, 42);
    },
  );
  testWidgets(
    'invalid operator and outside drops do not write or add history',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var writes = 0;
      final game = Game(puzzles.first);
      await mount(tester, game, changed: () => writes++);
      await dragTo(
        tester,
        find.byKey(const ValueKey('tile-one-1')),
        find.text('+').first,
      );
      expect(game.canUndo, isFalse);
      expect(writes, 0);
      await dragTo(
        tester,
        find.byKey(const ValueKey('tile-one-1')),
        find.text('Level 1'),
      );
      expect(game.canUndo, isFalse);
      expect(writes, 0);
      expect(game.available.length, 5);
    },
  );
}
