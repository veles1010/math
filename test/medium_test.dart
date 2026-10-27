import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/easy_generator.dart';
import 'package:math_puzzle/generated_puzzle.dart';
import 'package:math_puzzle/medium_generator.dart';
import 'package:math_puzzle/medium_fallback.dart';
import 'package:math_puzzle/logical_solver.dart';
import 'package:math_puzzle/puzzle_solver.dart';
import 'package:math_puzzle/store.dart';
import 'package:math_puzzle/main.dart';
import 'package:math_puzzle/board.dart';

import 'generator_test.dart' show SolverFixture;
import 'generated_ui_test.dart' show prefsFor;
import 'banner_layout_test.dart' show showGame, resetView;

class IntersectionFixture extends Puzzle {
  const IntersectionFixture() : super('intersection', const [], const []);
  @override
  Map<String, (int, int)> get positions => const {
    'a': (0, 0),
    'b': (0, 2),
    'c': (0, 4),
    'd': (2, 0),
    'e': (4, 0),
  };
  @override
  Map<String, int> get fixed => const {'c': 8, 'e': 10};
  @override
  List<NumberTile> get tiles => const [
    NumberTile('two', 2),
    NumberTile('four', 4),
    NumberTile('six', 6),
  ];
  @override
  List<Equation> get equations => const [
    Equation(['a', 'b', 'c'], '+'),
    Equation(['a', 'd', 'e'], '+'),
  ];
}

void solveGame(Game game) {
  final p = game.puzzle as GeneratedPuzzle, remaining = p.tiles.toList();
  for (final k in p.positions.keys.where((k) => !p.clues.contains(k))) {
    final tile = remaining.firstWhere((t) => t.value == p.solution[k]);
    remaining.remove(tile);
    game.transfer(tile.id, k);
  }
}

void main() {
  test(
    'shared arithmetic propagation supports 60 without changing easy defaults',
    () {
      final p = SolverFixture([40, 60], hints: const {'a': 20});
      expect(const PuzzleSolver(maxValue: 60).solve(p).unique, isTrue);
      expect(const LogicalSolver().solve(p).solved, isTrue);
      expect(const PuzzleSolver().solve(p).unique, isFalse);
    },
  );
  test('candidate filtering uses duplicate counts; guessing and budget are not logic', () {
    final repeated = const LogicalSolver().solve(SolverFixture([2, 2, 4]));
    expect(repeated.solved, isTrue);
    expect(repeated.poolPlacements, 3);
    expect(repeated.values, {'a': 2, 'b': 2, 'c': 4});
    expect(
      const LogicalSolver().solve(SolverFixture([2, 4, 4])).solved,
      isFalse,
    );
    expect(
      const LogicalSolver().solve(SolverFixture([1, 2, 3])).solved,
      isFalse,
    );
    final budget = const LogicalSolver(maxChecks: 0)
        .solve(SolverFixture([2, 2, 4]));
    expect(budget.budgetExceeded, isTrue);
    expect(budget.solved, isFalse);
    expect(
      const PuzzleSolver(
        maxValue: 60,
        maxNodes: 0,
      ).solve(SolverFixture([2, 2, 4])).unique,
      isFalse,
    );
  });
  test(
    'horizontal and vertical projections intersect at a shared variable',
    () {
      const p = IntersectionFixture();
      expect(deduce(p).solved, isFalse);
      final grade = const LogicalSolver().solve(p);
      expect(grade.solved, isTrue);
      expect(grade.values['a'], 6);
      expect(grade.values['b'], 2);
      expect(grade.values['d'], 4);
      expect(grade.intersectionPlacements, greaterThan(0));
      expect(grade.intersectionEliminations, greaterThan(0));
    },
  );
  test('200 medium seeds: geometry, multiset, uniqueness, extra inference and determinism', () {
    final families = <String, int>{}, fingerprints = <String>{};
    for (var seed = 0; seed < 200; seed++) {
      final result = const MediumGenerator().generate(seed), p = result.puzzle;
      expect(p, isNotNull, reason: 'seed $seed: ${result.report.toJson()}');
      final puzzle = p!;
      expect(puzzle.difficulty, 'medium');
      expect(puzzle.generatorVersion, 1);
      expect(puzzle.rows, lessThanOrEqualTo(11));
      expect(puzzle.columns, lessThanOrEqualTo(11));
      expect(puzzle.lines.length, inInclusiveRange(6, 8));
      expect(puzzle.tiles.length, inInclusiveRange(8, 12));
      expect(puzzle.solution.values.every((v) => v >= 1 && v <= 60), isTrue);
      expect(validGeometry(puzzle), isTrue);
      expect(puzzle.positions.values.toSet().length, puzzle.positions.length);
      expect(
        puzzle.lines.every((e) => e.check((k) => puzzle.solution[k]) == true),
        isTrue,
      );
      final expected =
          puzzle.solution.entries
              .where((e) => !puzzle.clues.contains(e.key))
              .map((e) => e.value)
              .toList()
            ..sort();
      final actual = puzzle.tiles.map((t) => t.value).toList()..sort();
      expect(actual, expected);
      expect(
        const PuzzleSolver(maxValue: 60, maxNodes: 30000).solve(puzzle).unique,
        isTrue,
      );
      expect(deduce(puzzle, maxValue: 60).solved, isFalse);
      final grade = const LogicalSolver().solve(puzzle);
      expect(grade.solved, isTrue);
      expect(grade.advanced, greaterThan(0));
      expect(grade.singles + grade.advanced, puzzle.tiles.length);
      expect(result.report.attempts, lessThanOrEqualTo(160));
      expect(
        puzzle.lines
            .where((e) => e.operator == '×' || e.operator == '÷')
            .length,
        greaterThanOrEqualTo(2),
      );
      expect(fingerprints.add(puzzle.fingerprint), isTrue);
      families.update(puzzle.family, (n) => n + 1, ifAbsent: () => 1);
      if (seed < 8) {
        expect(
          canonicalDefinition(puzzle),
          canonicalDefinition(mediumFallbackCatalog()[seed]),
        );
        expect(
          canonicalDefinition(const MediumGenerator().generate(seed).puzzle!),
          canonicalDefinition(puzzle),
        );
      }
      expect(
        canonicalDefinition(
          GeneratedPuzzle.fromDefinition(puzzle.toDefinition()),
        ),
        canonicalDefinition(puzzle),
      );
    }
    expect(families.values.toList(), [50, 50, 50, 50]);
    expect(const MediumGenerator(maxAttempts: 0).generate(0).puzzle, isNull);
    expect(
      const MediumGenerator(maxAttempts: 2, solverNodes: 0).generate(0).puzzle,
      isNull,
    );
  });
  test('all frozen reserves satisfy medium rules; exhaustion never falls back to easy', () {
    for (final p in mediumFallbackCatalog()) {
      expect(p.difficulty, 'medium');
      expect(deduce(p, maxValue: 60).solved, isFalse);
      expect(const LogicalSolver().solve(p).solved, isTrue);
      expect(
        const PuzzleSolver(maxValue: 60, maxNodes: 30000).solve(p).unique,
        isTrue,
      );
    }
    expect(
      pickMediumFallback(
        MediumGenerator.families.first,
        mediumFallbackCatalog().map((p) => p.fingerprint).toSet(),
      ),
      isNull,
    );
  });
  test('old easy definitions stay easy; medium resume, full definition, replay and counters persist', () async {
    SharedPreferences.setMockInitialValues(
      prefsFor(
        game: Game(const EasyGenerator().generate(0).puzzle!)..beginSession(),
      ),
    );
    final store = AppStore();
    await store.load();
    expect((store.generatedGame!.puzzle as GeneratedPuzzle).difficulty, 'easy');
    solveGame(store.generatedGame!);
    await store.save();
    expect(store.generatedCompletedCount, 1);
    expect(store.mediumCompletedCount, 0);
    final p = const MediumGenerator().generate(2).puzzle!;
    await store.installGenerated(p, fallback: false);
    final tile = p.tiles.first,
        key = p.positions.keys.firstWhere(
          (k) => !p.clues.contains(k) && p.solution[k] == tile.value,
        );
    store.generatedGame!.transfer(tile.id, key);
    store.generatedGame!.clock.restore(const Duration(seconds: 73));
    await store.save();
    final loaded = AppStore();
    await loaded.load();
    final game = loaded.generatedGame!;
    expect(
      canonicalDefinition(game.puzzle as GeneratedPuzzle),
      canonicalDefinition(p),
    );
    expect(game.value(key), tile.value);
    expect(game.canUndo, isTrue);
    expect(game.clock.elapsed.inSeconds, 73);
    game.undo();
    solveGame(game);
    await loaded.save();
    expect(loaded.mediumCompletedCount, 1);
    expect(loaded.generatedCompletedCount, 1);
    await loaded.replayGenerated();
    expect(loaded.generatedGame!.placed, isEmpty);
    expect(loaded.generatedGame!.clock.elapsed, Duration.zero);
    await loaded.save();
    final replay = AppStore();
    await replay.load();
    expect(replay.generatedGame!.canContinue, isTrue);
    solveGame(replay.generatedGame!);
    await replay.save();
    expect(replay.mediumCompletedCount, 1);
    expect(replay.generatedCompletedCount, 1);
    final prefs = await SharedPreferences.getInstance();
    final data = jsonDecode(prefs.getString('easy-session-v1')!);
    expect(data['difficulty'], 'medium');
    expect(data['definition']['difficulty'], 'medium');
  });
  for (var seed = 0; seed < 4; seed++) {
    for (final size in [const Size(320, 568), const Size(390, 844)]) {
      for (final dark in [false, true]) {
        testWidgets('real medium board seed=$seed $size dark=$dark', (
          tester,
        ) async {
          resetView(tester);
          final p = const MediumGenerator().generate(seed).puzzle!;
          await showGame(tester, Game(p), size, 90, dark: dark, language: 'tr');
          final square = tester.getRect(
            find.byKey(const ValueKey('board-square')),
          );
          for (final key in p.positions.keys) {
            final r = tester.getRect(find.byKey(ValueKey('cell-$key')));
            expect(r.left, greaterThanOrEqualTo(square.left - .01));
            expect(r.right, lessThanOrEqualTo(square.right + .01));
            expect(r.top, greaterThanOrEqualTo(square.top - .01));
            expect(r.bottom, lessThanOrEqualTo(square.bottom + .01));
          }
          expect(
            tester.widget<PuzzleBoard>(find.byType(PuzzleBoard)).interactive,
            isTrue,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  testWidgets(
    'medium selection uses its generator; Continue keeps difficulty and replace asks',
    (tester) async {
      SharedPreferences.setMockInitialValues(prefsFor());
      var called = 0;
      await tester.pumpWidget(
        MathPuzzleApp(
          generateMedium: (seed) async {
            called++;
            return generateMediumMessage(seed);
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('primary-play')));
      await tester.tap(find.byKey(const ValueKey('primary-play')));
      await tester.pumpAndSettle();
      expect(called, 1);
      expect(find.text('Medium puzzle'), findsOneWidget);
      final game = tester.widget<GameScreen>(find.byType(GameScreen)).game;
      expect((game.puzzle as GeneratedPuzzle).difficulty, 'medium');
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('primary-play')));
      await tester.tap(find.byKey(const ValueKey('primary-play')));
      await tester.pumpAndSettle();
      expect(tester.widget<GameScreen>(find.byType(GameScreen)).game, game);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('new-easy')));
      await tester.tap(find.byKey(const ValueKey('new-easy')));
      await tester.pumpAndSettle();
      expect(find.text('Keep current puzzle'), findsOneWidget);
      await tester.tap(find.text('Keep current puzzle'));
      await tester.pumpAndSettle();
      expect(called, 1);
    },
  );
  testWidgets(
    'medium reserve is visible and never installs easy on generation failure',
    (tester) async {
      SharedPreferences.setMockInitialValues(prefsFor());
      await tester.pumpWidget(
        MathPuzzleApp(
          generateMedium: (_) async => {
            'definition': null,
            'report': {'exhausted': true},
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('primary-play')));
      await tester.tap(find.byKey(const ValueKey('primary-play')));
      await tester.pumpAndSettle();
      final game = tester.widget<GameScreen>(find.byType(GameScreen)).game;
      expect((game.puzzle as GeneratedPuzzle).difficulty, 'medium');
      final store = AppStore();
      await store.load();
      expect(store.lastFallback, isTrue);
    },
  );
  testWidgets('medium reserve exhaustion keeps a partial medium game intact', (
    tester,
  ) async {
    final p = const MediumGenerator().generate(0).puzzle!;
    SharedPreferences.setMockInitialValues(
      prefsFor(
        game: Game(p)..beginSession(),
        recent: mediumFallbackCatalog().map((p) => p.fingerprint).toList(),
      ),
    );
    await tester.pumpWidget(
      MathPuzzleApp(
        generateMedium: (_) async => {'definition': null, 'report': {}},
      ),
    );
    await tester.pumpAndSettle();
    // Continue must open the saved medium session despite the default easy selection.
    await tester.ensureVisible(find.byKey(const ValueKey('primary-play')));
    await tester.tap(find.byKey(const ValueKey('primary-play')));
    await tester.pumpAndSettle();
    expect(find.text('Medium puzzle'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('new-easy')));
    await tester.tap(find.byKey(const ValueKey('new-easy')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start new'));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be created'), findsOneWidget);
    final store = AppStore();
    await store.load();
    expect(store.generatedGame!.puzzle.id, p.id);
    expect(
      (store.generatedGame!.puzzle as GeneratedPuzzle).difficulty,
      'medium',
    );
  });
}
