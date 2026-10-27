import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_puzzle/board.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/generated_puzzle.dart';
import 'package:math_puzzle/medium_generator.dart';
import 'package:math_puzzle/puzzle_solver.dart';
import 'package:math_puzzle/store.dart';

import 'banner_layout_test.dart' show showGame, resetView;

GeneratedPuzzle reported() => GeneratedPuzzle.fromDefinition(
  jsonDecode(
    File('test/fixtures/reported_medium_definition.json').readAsStringSync(),
  ) as Map<String, dynamic>,
);

// Preserve the reported mathematical case, never a raw user's save. Rebuild
// its problematic placement using synthetic transfers/time/history/counters.
Map<String, dynamic> syntheticSession() {
  final p = reported(), game = Game(reported());
  for (final (cell, suffix) in [
    ('n2_0', 't1'),
    ('n2_4', 't3'),
    ('n2_2', 't2'),
    ('n4_4', 't8'),
    ('n6_4', 't6'),
    ('n4_2', 't4'),
    ('n6_2', 't7'),
    ('n0_0', 't0'),
    ('n6_6', 't5'),
    ('n4_6', 't9'),
  ]) {
    game.transfer('${p.id}-$suffix', cell);
  }
  game.clock.restore(const Duration(seconds: 73));
  return {
    'definition': p.toDefinition(),
    'difficulty': 'medium',
    'session': game.toJson(),
    'completedIds': <String>[],
    'mediumCompletedIds': ['synthetic-previous-medium'],
    'recent': [p.fingerprint],
    'familyCounts': {p.family: 1},
    'lastFamily': null,
    'mediumLastFamily': p.family,
    'seedCounter': 0,
    'fallback': false,
  };
}

// Independent exhaustive oracle: no hidden solution, production inference,
// Equation.check, or production solver. Only fixed clues, equations and bag.
List<Map<String, int>> oracle(Puzzle p) {
  final bag = <int, int>{};
  for (final t in p.tiles) {
    bag.update(t.value, (n) => n + 1, ifAbsent: () => 1);
  }
  final values = Map<String, int>.of(p.fixed);
  final unknown = p.positions.keys
      .where((k) => !values.containsKey(k))
      .toList();
  final answers = <Map<String, int>>[];
  bool valid() {
    for (final e in p.equations) {
      final a = values[e.cells[0]],
          b = values[e.cells[1]],
          c = values[e.cells[2]];
      if (a == null || b == null || c == null) continue;
      final ok = switch (e.operator) {
        '+' => a + b == c,
        '−' => a - b == c,
        '×' => a * b == c,
        '÷' => b != 0 && a == b * c,
        _ => false,
      };
      if (!ok) return false;
    }
    return true;
  }

  void visit(int index) {
    if (answers.length == 2 || !valid()) return;
    if (index == unknown.length) {
      if (bag.values.every((n) => n == 0)) answers.add(Map.of(values));
      return;
    }
    for (final v in bag.keys) {
      if (bag[v] == 0) continue;
      values[unknown[index]] = v;
      bag[v] = bag[v]! - 1;
      visit(index + 1);
      bag[v] = bag[v]! + 1;
      values.remove(unknown[index]);
    }
  }

  visit(0);
  return answers;
}

class WrongBag extends Puzzle {
  final Puzzle source;
  WrongBag(this.source) : super('wrong-bag', const [], const []);
  @override
  Map<String, (int, int)> get positions => source.positions;
  @override
  Map<String, int> get fixed => source.fixed;
  @override
  List<Equation> get equations => source.equations;
  @override
  List<NumberTile> get tiles => [
    for (final t in source.tiles)
      NumberTile(t.id, t.value == 52 ? 51 : t.value),
  ];
}

void assertDefinition(Game g, GeneratedPuzzle p) {
  expect((g.puzzle as GeneratedPuzzle).toDefinition(), p.toDefinition());
  expect(g.puzzle.fixed, p.fixed);
  expect(
    [
      for (final t in g.puzzle.tiles) [t.id, t.value],
    ],
    [
      for (final t in p.tiles) [t.id, t.value],
    ],
  );
}

void main() {
  test('exact reported session is uniquely solvable independently of hidden solution', () {
    final p = reported();
    expect(p.seed, 1494227917);
    expect(p.tiles.map((t) => t.value).toList()..sort(), [
      1,
      1,
      2,
      2,
      4,
      10,
      11,
      42,
      44,
      52,
    ]);
    final answers = oracle(p);
    expect(answers, hasLength(1));
    final result = const PuzzleSolver(maxValue: 60, maxNodes: 100000).solve(p);
    expect(result.budgetExceeded, isFalse);
    expect(result.unique, isTrue);
    expect(result.solutions.single, answers.single);
    final current = Game(p)..restore(syntheticSession()['session']);
    expect(current.complete, isFalse);
    expect(current.equationStates, [true, true, false, true, true, false]);
    final bag = p.tiles.toList();
    final solved = Game(p);
    for (final key in p.positions.keys.where((k) => !p.fixed.containsKey(k))) {
      final tile = bag.firstWhere((t) => t.value == answers.single[key]);
      bag.remove(tile);
      expect(solved.transfer(tile.id, key), isTrue);
    }
    expect(bag, isEmpty);
    expect(solved.complete, isTrue);
    expect(solved.available, isEmpty);
    // Only four placements differ; fix on a COPY, preserving the source save.
    for (final (cell, suffix) in [
      ('n4_4', 't5'),
      ('n6_4', 't8'),
      ('n6_6', 't9'),
      ('n4_6', 't6'),
    ]) {
      current.transfer('${p.id}-$suffix', cell);
    }
    expect(current.complete, isTrue);
  });
  test(
    'known bad multiset is rejected by independent and production solvers',
    () {
      final bad = WrongBag(reported());
      expect(oracle(bad), isEmpty);
      final result = const PuzzleSolver(
        maxValue: 60,
        maxNodes: 100000,
      ).solve(bad);
      expect(result.budgetExceeded, isFalse);
      expect(result.solutions, isEmpty);
      expect(
        const PuzzleSolver(
          maxValue: 60,
          maxNodes: 0,
        ).solve(reported()).budgetExceeded,
        isTrue,
      );
    },
  );
  test('exact generation, game, save and reload preserve clues equations bag and history', () async {
    final p = reported();
    final generated = const MediumGenerator().generate(p.seed).puzzle!;
    expect(generated.toDefinition(), p.toDefinition());
    SharedPreferences.setMockInitialValues({
      'easy-session-v1': jsonEncode(syntheticSession()),
    });
    final store = AppStore();
    await store.load();
    expect(store.recovered, isFalse);
    final game = store.generatedGame!;
    assertDefinition(game, p);
    expect(game.toJson(), syntheticSession()['session']);
    final before = Map.of(game.placed);
    game.transfer('${p.id}-t9', 'n4_4'); // replace occupied target
    game.transfer('${p.id}-t9', null); // return
    game.sortPool();
    game.undo();
    game.undo();
    expect(game.placed, before);
    assertDefinition(game, p);
    await store.save();
    final loaded = AppStore();
    await loaded.load();
    assertDefinition(loaded.generatedGame!, p);
    expect(loaded.generatedGame!.toJson(), game.toJson());
    final answer = oracle(p).single, remaining = p.tiles.toList();
    for (final key in p.positions.keys.where((k) => !p.fixed.containsKey(k))) {
      final t = remaining.firstWhere((t) => t.value == answer[key]);
      remaining.remove(t);
      loaded.generatedGame!.transfer(t.id, key);
    }
    expect(loaded.generatedGame!.complete, isTrue);
    await loaded.save();
    final finished = AppStore();
    await finished.load();
    expect(finished.generatedGame!.complete, isTrue);
    expect(finished.mediumCompletedCount, 2);
  });
  testWidgets(
    'reported UI renders every saved identity coordinate symbol and value',
    (tester) async {
      resetView(tester);
      final p = reported(),
          game = Game(reported())..restore(syntheticSession()['session']);
      await showGame(tester, game, const Size(390, 844), 0, language: 'tr');
      for (final e in p.positions.entries) {
        final stone = find.byKey(ValueKey('cell-${e.key}'));
        expect(stone, findsOneWidget);
        expect(
          find.descendant(
            of: stone,
            matching: find.text('${game.value(e.key)}'),
          ),
          findsOneWidget,
        );
      }
      for (final e in p.symbols.entries) {
        expect(
          find.descendant(
            of: find.byKey(ValueKey('symbol-${e.key.$1}-${e.key.$2}')),
            matching: find.text(e.value),
          ),
          findsOneWidget,
        );
      }
      expect(find.byType(PuzzleBoard), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
