import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_puzzle/board.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/easy_generator.dart';
import 'package:math_puzzle/easy_fallback.dart';
import 'package:math_puzzle/generated_puzzle.dart';
import 'package:math_puzzle/main.dart';
import 'package:math_puzzle/store.dart';
import 'package:math_puzzle/l10n/app_localizations.dart';
import 'package:math_puzzle/theme.dart';

import 'interaction_test.dart' show mount;
import 'drag_replay_test.dart' show moveVisibleStone;
import 'generated_ui_test.dart' show prefsFor;

void main() {
  test(
    'v1 wide saved definition and progress are loaded verbatim under v2',
    () async {
      final legacy = fallbackCatalog(version: 1).first;
      final game = Game(legacy)..beginSession();
      final tile = legacy.tiles.first;
      final target = legacy.positions.keys.firstWhere(
        (k) => !legacy.clues.contains(k) && legacy.solution[k] == tile.value,
      );
      game.transfer(tile.id, target);
      game.clock.restore(const Duration(seconds: 79));
      SharedPreferences.setMockInitialValues({
        ...prefsFor(game: game),
        'game-one': '{"placed":{"b":"one-1"},"history":[{}]}',
      });
      final store = AppStore();
      await store.load();
      final loaded = store.generatedGame!;
      expect((loaded.puzzle as GeneratedPuzzle).generatorVersion, 1);
      expect(loaded.puzzle.columns, 9);
      expect(
        canonicalDefinition(loaded.puzzle as GeneratedPuzzle),
        canonicalDefinition(legacy),
      );
      expect(loaded.placed, game.placed);
      expect(loaded.canUndo, isTrue);
      expect(loaded.clock.elapsed.inSeconds, 79);
      expect(store.games.first.value('b'), 4);
      await store.save();
      final second = AppStore();
      await second.load();
      expect(
        canonicalDefinition(second.generatedGame!.puzzle as GeneratedPuzzle),
        canonicalDefinition(legacy),
      );
      expect(second.generatedGame!.placed, game.placed);
    },
  );
  test('v2 families have distinct equation graphs and no unused outer rows or columns', () {
    final signatures = <String>{};
    for (var seed = 0; seed < 4; seed++) {
      final p = const EasyGenerator().generate(seed).puzzle!;
      final degrees = [
        for (var i = 0; i < p.lines.length; i++)
          p.lines.indexed
              .where(
                (e) => e.$1 != i && e.$2.cells.any(p.lines[i].cells.contains),
              )
              .length,
      ]..sort();
      signatures.add(degrees.join(','));
      expect(p.columns, 5);
      expect(p.rows, seed == 1 ? 5 : 9);
      expect(p.generatorVersion, 2);
      final occupied = [...p.positions.values, ...p.symbols.keys];
      expect(occupied.any((p) => p.$1 == 0), isTrue);
      expect(occupied.any((p) => p.$2 == 0), isTrue);
      expect(occupied.any((pos) => pos.$1 == p.rows - 1), isTrue);
      expect(occupied.any((pos) => pos.$2 == p.columns - 1), isTrue);
    }
    expect(signatures.length, 4);
  });
  testWidgets(
    'legacy wide puzzle retains horizontal scroll, while v2 has none',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await mount(tester, Game(fallbackCatalog(version: 1).first), width: 320);
      final horizontal = find.descendant(
        of: find.byType(PuzzleBoard),
        matching: find.byType(Scrollable),
      );
      expect(horizontal, findsOneWidget);
      expect(
        tester.state<ScrollableState>(horizontal).position.maxScrollExtent,
        greaterThan(0),
      );
      await tester.pumpWidget(const SizedBox());
      await mount(
        tester,
        Game(const EasyGenerator().generate(0).puzzle!),
        width: 320,
      );
      expect(
        find.descendant(
          of: find.byType(PuzzleBoard),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
    },
  );
  testWidgets(
    'short phone with large text scrolls only vertically and keeps pool accessible',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final game = Game(const EasyGenerator().generate(0).puzzle!);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          theme: ThemePalette.night.build(Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.6)),
            child: child!,
          ),
          home: GameScreen(
            game: game,
            number: 0,
            onChanged: () {},
            settings: AppSettings()..largeNumbers = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final pool = tester.getRect(find.byKey(const ValueKey('pool')));
      expect(pool.bottom, lessThanOrEqualTo(568));
      final positions = tester
          .stateList<ScrollableState>(find.byType(Scrollable))
          .map((s) => s.position)
          .toList();
      expect(positions.every((p) => p.axis == Axis.vertical), isTrue);
      expect(positions.any((p) => p.maxScrollExtent > 0), isTrue);
      final grid = tester.getRect(find.byKey(const ValueKey('board-grid')));
      expect(grid.left, greaterThanOrEqualTo(0));
      expect(grid.right, lessThanOrEqualTo(320));
      final before = pool.top;
      await tester.drag(find.byType(PuzzleBoard), const Offset(0, -100));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byKey(const ValueKey('pool'))).top, before);
    },
  );
  testWidgets('height-fitted v2 board uses visible feedback center for drops', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final p = const EasyGenerator().generate(0).puzzle!,
        game = Game(const EasyGenerator().generate(0).puzzle!);
    await mount(tester, game, width: 320, large: true);
    final tile = p.tiles.first;
    final target = p.positions.keys.firstWhere(
      (k) => !p.clues.contains(k) && p.solution[k] == tile.value,
    );
    final cell = find.byKey(ValueKey('cell-$target'));
    final gesture = await moveVisibleStone(
      tester,
      find.byKey(ValueKey('tile-${tile.id}')),
      tester.getCenter(cell),
    );
    expect(tester.widget<Stone>(cell).hover, isTrue);
    expect(game.placed, isEmpty);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(game.placed[target], tile.id);
  });
  testWidgets(
    'entire nine-row result fits the preview bounds without clipping',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final p = const EasyGenerator().generate(0).puzzle!,
          game = Game(const EasyGenerator().generate(0).puzzle!);
      final tiles = game.available.toList();
      for (final key in p.positions.keys.where((k) => !p.clues.contains(k))) {
        final tile = tiles.firstWhere((t) => t.value == p.solution[key]);
        tiles.remove(tile);
        game.transfer(tile.id, key);
      }
      await mount(tester, game, width: 320);
      final preview = tester.getRect(
        find.byKey(const ValueKey('result-preview')),
      );
      final grid = tester.getRect(find.byKey(const ValueKey('board-grid')));
      expect(grid.height, lessThanOrEqualTo(240));
      for (final key in p.positions.keys) {
        final r = tester.getRect(find.byKey(ValueKey('cell-$key')));
        expect(r.left, greaterThanOrEqualTo(preview.left - .01));
        expect(r.right, lessThanOrEqualTo(preview.right + .01));
        expect(r.top, greaterThanOrEqualTo(preview.top - .01));
        expect(r.bottom, lessThanOrEqualTo(preview.bottom + .01));
      }
      expect(
        find.descendant(
          of: find.byType(PuzzleBoard),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
    },
  );
  testWidgets(
    'home prioritizes easy play even when a practice session is unfinished',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        ...prefsFor(),
        'game-one': '{"placed":{"b":"one-1"},"history":[{}]}',
      });
      await tester.pumpWidget(const MathPuzzleApp());
      await tester.pumpAndSettle();
      final primary = tester.widget<FilledButton>(
        find.byKey(const ValueKey('primary-play')),
      );
      expect(
        find.descendant(
          of: find.byWidget(primary),
          matching: find.text('New puzzle — Easy'),
        ),
        findsOneWidget,
      );
      expect(find.text('Easy puzzles completed: 0'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Practice levels'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Practice levels'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(jsonDecode(prefs.getString('game-one')!)['placed']['b'], 'one-1');
    },
  );
}
