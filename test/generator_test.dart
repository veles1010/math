import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/easy_generator.dart';
import 'package:math_puzzle/generated_puzzle.dart';
import 'package:math_puzzle/puzzle_solver.dart';
import 'package:math_puzzle/easy_fallback.dart';
import 'package:math_puzzle/store.dart';

class SolverFixture extends Puzzle {
  final List<int> pool;
  final Map<String, int> hints;
  SolverFixture(this.pool, {this.hints = const {}})
    : super('solver', const [], const []);
  @override
  Map<String, (int, int)> get positions => const {
    'a': (0, 0),
    'b': (0, 2),
    'c': (0, 4),
  };
  @override
  List<Equation> get equations => const [
    Equation(['a', 'b', 'c'], '+'),
  ];
  @override
  Map<String, int> get fixed => hints;
  @override
  List<NumberTile> get tiles => [
    for (var i = 0; i < pool.length; i++) NumberTile('tile$i', pool[i]),
  ];
}

void main() {
  test('independent solver: impossible, unique with repeated numbers, multiple numeric answers', () {
    final solver = const PuzzleSolver();
    expect(solver.solve(SolverFixture([1, 1, 3])).solutions, isEmpty);
    final repeated = solver.solve(SolverFixture([2, 2, 4]));
    expect(repeated.unique, isTrue);
    expect(repeated.solutions.single, {'a': 2, 'b': 2, 'c': 4});
    final multiple = solver.solve(SolverFixture([1, 2, 3]));
    expect(multiple.solutions.length, 2);
    expect(multiple.unique, isFalse);
    expect(multiple.solutions[0], isNot(multiple.solutions[1]));
    expect(solver.solve(SolverFixture([2, 3], hints: {'a': 1})).unique, isTrue);
    expect(
      solver.solve(SolverFixture([2, 2], hints: {'a': 1})).solutions,
      isEmpty,
    );
  });
  test('search budget exhaustion never claims uniqueness; deduction rejects guessing', () {
    final limited = const PuzzleSolver(maxNodes: 1)
        .solve(SolverFixture([2, 2, 4]));
    expect(limited.budgetExceeded, isTrue);
    expect(limited.unique, isFalse);
    expect(deduce(SolverFixture([1, 2, 3])).solved, isFalse);
    final failed = const EasyGenerator(maxAttempts: 0).generate(42);
    expect(failed.puzzle, isNull);
    expect(failed.report.attempts, 0);
    final budget = const EasyGenerator(
      maxAttempts: 2,
      solverNodes: 0,
    ).generate(0);
    expect(budget.puzzle, isNull);
    expect(budget.report.rejected['solverBudget'], greaterThan(0));
  });
  test('200 seeds: full arithmetic, geometry, inventory, uniqueness, easy deduction, determinism', () {
    final fingerprints = <String>{}, familyCounts = <String, int>{};
    for (var seed = 0; seed < 200; seed++) {
      final result = const EasyGenerator().generate(seed), p = result.puzzle!;
      if (seed < 8) {
        expect(
          canonicalDefinition(p),
          canonicalDefinition(fallbackCatalog()[seed]),
          reason: 'v2 frozen golden',
        );
      }
      expect(result.report.attempts, lessThanOrEqualTo(80));
      expect(result.report.fallback, isFalse);
      expect(validGeometry(p), isTrue, reason: 'seed $seed');
      expect(p.generatorVersion, 2);
      expect(p.columns, lessThanOrEqualTo(5));
      expect(p.rows, lessThanOrEqualTo(9));
      expect(
        p.positions.values.map((p) => p.$1).reduce((a, b) => a < b ? a : b),
        0,
      );
      expect(
        p.positions.values.map((p) => p.$2).reduce((a, b) => a < b ? a : b),
        0,
      );
      expect(p.positions.values.toSet().length, p.positions.length);
      expect(p.equations.length, inInclusiveRange(4, 6));
      expect(p.tiles.length, inInclusiveRange(5, 8));
      expect(p.solution.values.every((v) => v >= 1 && v <= 30), isTrue);
      expect(
        p.equations.every((e) => e.check((k) => p.solution[k]) == true),
        isTrue,
      );
      final expected = [
        for (final e in p.solution.entries)
          if (!p.clues.contains(e.key)) e.value,
      ]..sort();
      final actual = p.tiles.map((t) => t.value).toList()..sort();
      expect(actual, expected);
      final solved = const PuzzleSolver().solve(p);
      expect(solved.unique, isTrue);
      expect(deduce(p).solved, isTrue);
      expect(deduce(p).steps.length, p.tiles.length);
      expect(
        fingerprints.add(p.fingerprint),
        isTrue,
        reason: 'exact repeat $seed',
      );
      familyCounts.update(p.family, (n) => n + 1, ifAbsent: () => 1);
      if (seed < 12) {
        expect(
          canonicalDefinition(const EasyGenerator().generate(seed).puzzle!),
          canonicalDefinition(p),
        );
      }
    }
    expect(familyCounts.values.toSet(), {50});
    expect(familyCounts.length, 4);
  });
  test(
    'frozen reserves independently verify and honor recent fingerprints',
    () {
      final catalog = fallbackCatalog();
      expect(catalog.length, 8);
      for (final p in catalog) {
        expect(validGeometry(p), isTrue);
        expect(const PuzzleSolver().solve(p).unique, isTrue);
        expect(deduce(p).solved, isTrue);
      }
      final family = EasyGenerator.families.first;
      expect(
        pickFallback(family, {catalog.first.fingerprint})!.fingerprint,
        isNot(catalog.first.fingerprint),
      );
      expect(
        pickFallback(family, catalog.map((p) => p.fingerprint).toSet()),
        isNull,
      );
    },
  );
  test('session saves full definition, replay and completion independently of fixed levels', () async {
    SharedPreferences.setMockInitialValues({
      'game-one': '{"placed":{"b":"one-1"},"history":[{}]}',
      'appearance': 'dark',
    });
    final store = AppStore();
    await store.load();
    final p = const EasyGenerator().generate(1).puzzle!;
    await store.installGenerated(p, fallback: false);
    final game = store.generatedGame!;
    final first = p.tiles.first;
    final target = p.positions.keys.firstWhere(
      (k) => !p.clues.contains(k) && p.solution[k] == first.value,
    );
    game.transfer(first.id, target);
    game.clock.restore(const Duration(seconds: 37));
    await store.save();
    final loaded = AppStore();
    await loaded.load();
    final restored = loaded.generatedGame!,
        definition = restored.puzzle as GeneratedPuzzle;
    expect(canonicalDefinition(definition), canonicalDefinition(p));
    expect(restored.placed, game.placed);
    expect(restored.clock.elapsed.inSeconds, 37);
    expect(restored.canUndo, isTrue);
    expect(loaded.games.first.value('b'), 4);
    expect(loaded.completedCount, 0);
    final available = restored.available.toList();
    for (final key in definition.positions.keys.where(
      (k) => !definition.clues.contains(k) && restored.value(k) == null,
    )) {
      final tile = available.firstWhere(
        (t) => t.value == definition.solution[key],
      );
      available.remove(tile);
      restored.transfer(tile.id, key);
    }
    expect(restored.complete, isTrue);
    await loaded.save();
    expect(loaded.generatedCompletedCount, 1);
    expect(loaded.completedCount, 0);
    await loaded.replayGenerated();
    expect(loaded.generatedCompletedCount, 1);
    expect(loaded.generatedGame!.placed, isEmpty);
    expect(loaded.generatedGame!.clock.elapsed, Duration.zero);
    expect(identical(restored, loaded.generatedGame), isFalse);
    expect(
      canonicalDefinition(loaded.generatedGame!.puzzle as GeneratedPuzzle),
      canonicalDefinition(p),
    );
    final prefs = await SharedPreferences.getInstance();
    final repeat = loaded.generatedGame!,
        same = repeat.puzzle as GeneratedPuzzle;
    final repeatTiles = repeat.available.toList();
    for (final key in same.positions.keys.where(
      (k) => !same.clues.contains(k),
    )) {
      final tile = repeatTiles.firstWhere((t) => t.value == same.solution[key]);
      repeatTiles.remove(tile);
      repeat.transfer(tile.id, key);
    }
    await loaded.save();
    expect(loaded.generatedCompletedCount, 1);
    expect(loaded.generatedGame!.complete, isTrue);
    final raw =
        jsonDecode(prefs.getString('easy-session-v1')!) as Map<String, dynamic>;
    // Simulates a later generator version: load the saved board, do not rerun v1.
    raw['definition']['generatorVersion'] = 999;
    await prefs.setString('easy-session-v1', jsonEncode(raw));
    final future = AppStore();
    await future.load();
    expect(
      (future.generatedGame!.puzzle as GeneratedPuzzle).generatorVersion,
      999,
    );
    expect(future.generatedCompletedCount, 1);
  });
  test('family selection balances history, avoids consecutive geometry and preserves fixed saves', () async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    String? previous;
    for (var i = 0; i < 16; i++) {
      final result = const EasyGenerator().generate(store.reserveEasySeed());
      final p = result.puzzle!;
      expect(p.family, isNot(previous));
      expect(store.recentGenerated.contains(p.fingerprint), isFalse);
      await store.installGenerated(p, fallback: false);
      previous = p.family;
    }
    expect(store.familyCounts.values.toSet(), {4});
    expect(store.games.every((g) => g.placed.isEmpty), isTrue);
    final loaded = AppStore();
    await loaded.load();
    expect(loaded.lastFamily, previous);
    expect(loaded.recentGenerated.length, 16);
  });
}
