import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/board.dart';
import 'package:math_puzzle/store.dart';
import 'package:math_puzzle/main.dart';
import 'package:math_puzzle/game_screen.dart' show ResultView;

import 'interaction_test.dart' show mount;

Future<TestGesture> moveVisibleStone(
  WidgetTester tester,
  Finder from,
  Offset target,
) async {
  final origin = tester.getCenter(from);
  final gesture = await tester.startGesture(origin);
  await gesture.moveBy(const Offset(0, -12));
  await tester.pump();
  final pointer = origin + const Offset(0, -12);
  final visibleOffset =
      tester.getRect(find.byType(Stone).last).center - pointer;
  for (var i = 1; i <= 16; i++) {
    await gesture.moveTo(Offset.lerp(pointer, target - visibleOffset, i / 16)!);
    await tester.pump(const Duration(milliseconds: 16));
  }
  expect(
    (tester.getRect(find.byType(Stone).last).center - target).distance,
    lessThan(.1),
  );
  return gesture;
}

Future<void> tapPlace(WidgetTester tester, String cell, String tile) async {
  await tester.ensureVisible(find.byKey(ValueKey('cell-$cell')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(ValueKey('cell-$cell')));
  await tester.pump();
  await tester.tap(find.byKey(ValueKey('tile-$tile')));
  await tester.pumpAndSettle();
}

void solve(Game game) {
  for (final e in {
    'b': 'one-1',
    'c': 'one-2',
    'e': 'one-4',
    'f': 'one-5',
    'g': 'one-6',
  }.entries) {
    game.transfer(e.value, e.key);
  }
}

void main() {
  testWidgets(
    'visible feedback center, not invisible pointer, selects tutorial target',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final game = Game(const TutorialPuzzle());
      bool? done;
      await mount(tester, game, tutorial: (value) => done = value);
      await tapPlace(tester, 'b', 'tutorial-1');
      final before = jsonEncode(game.toJson());
      // Invalid drop at the fixed clue must preserve exactly one used tile.
      var gesture = await moveVisibleStone(
        tester,
        find.byKey(const ValueKey('tile-tutorial-2')),
        tester.getCenter(find.byKey(const ValueKey('cell-a'))),
      );
      expect(
        tester.widget<Stone>(find.byKey(const ValueKey('cell-a'))).hover,
        isFalse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(done, isNull);
      expect(jsonEncode(game.toJson()), before);
      // Actual rendered center reaches target while finger remains below it.
      gesture = await moveVisibleStone(
        tester,
        find.byKey(const ValueKey('tile-tutorial-2')),
        tester.getCenter(find.byKey(const ValueKey('cell-c'))),
      );
      expect(
        tester.widget<Stone>(find.byKey(const ValueKey('cell-c'))).hover,
        isTrue,
      );
      expect(game.value('c'), isNull); // drag is still transient
      await gesture.up();
      await tester.pumpAndSettle();
      expect(game.complete, isTrue);
      expect(done, isTrue);
      expect(game.available, isEmpty);
    },
  );
  testWidgets(
    'visible targeting is disjoint at adjacent operator and number cells',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final game = Game(puzzles.first);
      await mount(tester, game, width: 320);
      final rect = tester.getRect(find.byKey(const ValueKey('cell-b')));
      expect(rect.width, greaterThanOrEqualTo(48));
      // Just inside the left edge accepts; the neighboring + square does not.
      var gesture = await moveVisibleStone(
        tester,
        find.byKey(const ValueKey('tile-one-1')),
        Offset(rect.left + 1, rect.center.dy),
      );
      expect(
        tester.widget<Stone>(find.byKey(const ValueKey('cell-b'))).hover,
        isTrue,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(game.placed['b'], 'one-1');
      await tester.tap(find.byKey(const ValueKey('undo')));
      await tester.pumpAndSettle();
      gesture = await moveVisibleStone(
        tester,
        find.byKey(const ValueKey('tile-one-1')),
        tester.getCenter(find.text('+').first),
      );
      expect(
        tester.widget<Stone>(find.byKey(const ValueKey('cell-b'))).hover,
        isFalse,
      );
      await gesture.up();
      await tester.pumpAndSettle();
      expect(game.placed, isEmpty);
      expect(game.available.length, 5);
    },
  );
  test('replay resets only session and persists completion across reload and re-solve', () async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    final game = store.games.first;
    solve(game);
    game.clock.restore(const Duration(minutes: 3));
    game.resultPresented = true;
    await store.save();
    expect(store.completedCount, 1);
    await store.replayLevel(0);
    expect(game.placed, isEmpty);
    expect(game.canUndo, isFalse);
    expect(game.clock.elapsed, Duration.zero);
    expect(game.resultPresented, isFalse);
    expect(game.completedOnce, isTrue);
    expect(game.canContinue, isTrue);
    expect(store.completedCount, 1);
    final reloaded = AppStore();
    await reloaded.load();
    expect(reloaded.completedCount, 1);
    expect(reloaded.games.first.canContinue, isTrue);
    expect(reloaded.games.first.placed, isEmpty);
    expect(reloaded.games.first.resultPresented, isFalse);
    reloaded.games.first.transfer('one-1', 'b');
    await reloaded.save();
    final continued = AppStore();
    await continued.load();
    expect(continued.games.first.value('b'), 4);
    solve(continued.games.first);
    await continued.save();
    expect(continued.completedCount, 1);
    final finished = AppStore();
    await finished.load();
    expect(finished.completedCount, 1);
    expect(finished.games.first.complete, isTrue);
  });
  test(
    'version two completed records migrate without erasing other levels',
    () async {
      final old = Game(puzzles.first);
      solve(old);
      SharedPreferences.setMockInitialValues({
        'game-one': jsonEncode({
          'version': 2,
          'placed': old.placed,
          'history': [],
          'elapsedMs': 99,
          'resultPresented': true,
        }),
        'game-two': jsonEncode({
          'placed': {'b': 'two-1'},
          'history': [{}],
        }),
      });
      final store = AppStore();
      await store.load();
      expect(store.completedCount, 1);
      await store.replayLevel(0);
      final reloaded = AppStore();
      await reloaded.load();
      expect(reloaded.completedCount, 1);
      expect(reloaded.games[1].value('b'), 3);
      expect(reloaded.games[1].canUndo, isTrue);
    },
  );
  testWidgets(
    'completed level offers explicit replay; Continue reloads partial replay',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final old = Game(puzzles.first);
      solve(old);
      old.resultPresented = true;
      SharedPreferences.setMockInitialValues({
        'settings-v2': '{"tutorial":"skipped","language":"en"}',
        'game-one': jsonEncode(old.toJson()),
      });
      await tester.pumpWidget(const MathPuzzleApp());
      await tester.pumpAndSettle();
      expect(find.text('1 of 3 levels completed'), findsOneWidget);
      final level = find.textContaining('1 ·');
      await tester.ensureVisible(level);
      await tester.pumpAndSettle();
      await tester.tap(level);
      await tester.pumpAndSettle();
      expect(find.byType(GameScreen), findsNothing);
      expect(find.byType(ResultView), findsNothing);
      await tester.tap(find.byKey(const ValueKey('replay')));
      await tester.pumpAndSettle();
      var game = tester.widget<GameScreen>(find.byType(GameScreen)).game;
      expect(game.placed, isEmpty);
      expect(game.canUndo, isFalse);
      expect(game.resultPresented, isFalse);
      expect(game.completedOnce, isTrue);
      await tapPlace(tester, 'b', 'one-1');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('1 of 3 levels completed'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(const MathPuzzleApp());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('primary-play')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('primary-play')));
      await tester.pumpAndSettle();
      game = tester.widget<GameScreen>(find.byType(GameScreen)).game;
      expect(game.value('b'), 4);
      expect(game.canUndo, isTrue);
      for (final e in {
        'c': 'one-2',
        'e': 'one-4',
        'f': 'one-5',
        'g': 'one-6',
      }.entries) {
        await tapPlace(tester, e.key, e.value);
      }
      expect(find.byType(ResultView), findsOneWidget);
      final home = find.widgetWithText(OutlinedButton, 'Home');
      await tester.ensureVisible(home);
      await tester.pumpAndSettle();
      await tester.tap(home);
      await tester.pumpAndSettle();
      expect(find.text('1 of 3 levels completed'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
