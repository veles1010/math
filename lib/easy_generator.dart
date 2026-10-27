import 'dart:convert';

import 'game.dart';
import 'generated_puzzle.dart';
import 'puzzle_solver.dart';

class SeedRandom {
  int state;
  SeedRandom(int seed) : state = seed % 4294967296;
  int nextInt(int bound) {
    state = (1664525 * state + 1013904223) % 4294967296;
    return (state >>> 8) % bound;
  }

  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1), v = list[i];
      list[i] = list[j];
      list[j] = v;
    }
  }
}

class GenerationReport {
  int attempts = 0;
  final Map<String, int> rejected = {};
  bool fallback = false;
  int elapsedMicros = 0;
  void reject(String reason) =>
      rejected.update(reason, (n) => n + 1, ifAbsent: () => 1);
  Map<String, dynamic> toJson() => {
    'attempts': attempts,
    'rejected': rejected,
    'fallback': fallback,
    'elapsedMicros': elapsedMicros,
  };
}

class GenerationResult {
  final GeneratedPuzzle? puzzle;
  final GenerationReport report;
  const GenerationResult(this.puzzle, this.report);
}

class EasyGenerator {
  static const version = 2;
  static const families = ['branch', 'ladder', 'zigzag', 'loopTail'];
  // (row, column, vertical): distinct graphs, cropped to at most five columns.
  static const layouts = <List<(int, int, bool)>>[
    [
      (0, 0, false),
      (0, 0, true),
      (4, 0, false),
      (2, 2, true),
      (4, 4, true),
      (8, 0, false),
    ],
    [(0, 0, false), (0, 0, true), (0, 2, true), (0, 4, true), (4, 0, false)],
    [(0, 0, false), (0, 4, true), (4, 0, false), (4, 0, true), (8, 0, false)],
    [(0, 0, false), (0, 0, true), (0, 4, true), (4, 0, false), (4, 2, true)],
  ];
  final int maxAttempts, solverNodes;
  const EasyGenerator({this.maxAttempts = 80, this.solverNodes = 10000});
  GenerationResult generate(int seed) {
    final watch = Stopwatch()..start(),
        report = GenerationReport(),
        rng = SeedRandom(seed),
        family = seed % families.length;
    GeneratedPuzzle? accepted;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      report.attempts++;
      final candidate = _candidate(seed, family, rng);
      if (candidate == null) {
        report.reject('fullBoard');
        continue;
      }
      if (candidate.columns > 5 ||
          candidate.rows > 9 ||
          !validGeometry(candidate)) {
        report.reject('geometry');
        continue;
      }
      final keys = candidate.solution.keys.toList();
      rng.shuffle(keys);
      final clues = keys.toSet();
      // Five slots fit a single pool row even on a 320px phone.
      const target = 5;
      for (final key in keys) {
        if (keys.length - clues.length >= target) break;
        clues.remove(key);
        final hidden = _copy(candidate, clues);
        if (!deduce(hidden).solved) clues.add(key);
      }
      if (keys.length - clues.length < 5) {
        report.reject('deduction');
        continue;
      }
      final hidden = _copy(candidate, clues);
      final solved = PuzzleSolver(maxNodes: solverNodes).solve(hidden);
      if (solved.budgetExceeded) {
        report.reject('solverBudget');
        continue;
      }
      if (!solved.unique) {
        report.reject(
          solved.solutions.isEmpty ? 'noSolution' : 'multipleSolutions',
        );
        continue;
      }
      accepted = GeneratedPuzzle(
        id: 'easy-v$version-${seed.toRadixString(16)}-${_hash(hidden.fingerprint)}',
        seed: seed,
        generatorVersion: version,
        family: hidden.family,
        cells: hidden.cells,
        solution: hidden.solution,
        clues: hidden.clues,
        lines: hidden.lines,
        paths: hidden.paths,
      );
      break;
    }
    report.elapsedMicros = watch.elapsedMicroseconds;
    return GenerationResult(accepted, report);
  }

  static String _hash(String input) {
    var h = 0;
    for (final code in input.codeUnits) {
      h = (h * 31 + code) % 4294967296;
    }
    return h.toRadixString(16);
  }

  GeneratedPuzzle _copy(GeneratedPuzzle p, Set<String> clues) =>
      GeneratedPuzzle(
        id: p.id,
        seed: p.seed,
        generatorVersion: p.generatorVersion,
        family: p.family,
        cells: p.cells,
        solution: p.solution,
        clues: clues,
        lines: p.lines,
        paths: p.paths,
      );
  GeneratedPuzzle? _candidate(int seed, int family, SeedRandom rng) {
    final rawPaths = [
      for (final (r, c, v) in layouts[family])
        [for (var i = 0; i < 5; i++) (r + (v ? i : 0), c + (v ? 0 : i))],
    ];
    final points = rawPaths.expand((p) => p).toList();
    final top = points.map((p) => p.$1).reduce((a, b) => a < b ? a : b);
    final left = points.map((p) => p.$2).reduce((a, b) => a < b ? a : b);
    final paths = [
      for (final path in rawPaths)
        [for (final p in path) (p.$1 - top, p.$2 - left)],
    ];
    String key((int, int) p) => 'n${p.$1}_${p.$2}';
    final cells = <String, (int, int)>{
      for (final path in paths)
        for (final i in [0, 2, 4]) key(path[i]): path[i],
    };
    final ids = [
      for (final path in paths)
        [
          for (final i in [0, 2, 4]) key(path[i]),
        ],
    ];
    final values = <String, int>{}, ops = <int, String>{};
    final remaining = [for (var i = 0; i < paths.length; i++) i];
    while (remaining.isNotEmpty) {
      remaining.sort(
        (a, b) => ids[b]
            .where(values.containsKey)
            .length
            .compareTo(ids[a].where(values.containsKey).length),
      );
      final index = remaining.removeAt(0), keys = ids[index];
      final options = ['+', '+', '+', '+', '−', '−', '−', '×', '÷'];
      rng.shuffle(options);
      (int, int, int)? chosen;
      String? operation;
      for (final op in options) {
        final matches = _triples[op]!
            .where(
              (t) => ![
                (keys[0], t.$1),
                (keys[1], t.$2),
                (keys[2], t.$3),
              ].any((e) => values.containsKey(e.$1) && values[e.$1] != e.$2),
            )
            .toList();
        if (matches.isNotEmpty) {
          chosen = matches[rng.nextInt(matches.length)];
          operation = op;
          break;
        }
      }
      if (chosen == null) return null;
      values[keys[0]] = chosen.$1;
      values[keys[1]] = chosen.$2;
      values[keys[2]] = chosen.$3;
      ops[index] = operation!;
    }
    final ordered = cells.keys.toList()..sort();
    return GeneratedPuzzle(
      id: 'candidate',
      seed: seed,
      generatorVersion: version,
      family: families[family],
      cells: {for (final k in ordered) k: cells[k]!},
      solution: {for (final k in ordered) k: values[k]!},
      clues: ordered.toSet(),
      lines: [for (var i = 0; i < paths.length; i++) Equation(ids[i], ops[i]!)],
      paths: paths,
    );
  }

  static final Map<String, List<(int, int, int)>> _triples = {
    '+': [
      for (var a = 1; a <= 30; a++)
        for (var b = 1; b <= 30; b++)
          if (a + b <= 30) (a, b, a + b),
    ],
    '−': [
      for (var a = 1; a <= 30; a++)
        for (var b = 1; b < a; b++) (a, b, a - b),
    ],
    '×': [
      for (var a = 1; a <= 9; a++)
        for (var b = 1; b <= 9; b++)
          if (a * b <= 30) (a, b, a * b),
    ],
    '÷': [
      for (var b = 1; b <= 9; b++)
        for (var c = 1; c <= 9; c++)
          if (b * c <= 30) (b * c, b, c),
    ],
  };
}

/// Isolate entrypoint: JSON-friendly data only, no Flutter binding or storage.
Map<String, dynamic> generateEasyMessage(int seed) {
  final result = const EasyGenerator().generate(seed);
  return {
    'definition': result.puzzle?.toDefinition(),
    'report': result.report.toJson(),
  };
}

String canonicalDefinition(GeneratedPuzzle puzzle) =>
    jsonEncode(puzzle.toDefinition());
