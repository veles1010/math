import 'game.dart';
import 'generated_puzzle.dart';
import 'puzzle_solver.dart';
import 'easy_fallback.dart';
import 'logical_solver.dart';
import 'easy_generator.dart'
    show SeedRandom, GenerationReport, GenerationResult;

class MediumReport extends GenerationReport {
  int masks = 0;
  @override
  Map<String, dynamic> toJson() => {...super.toJson(), 'maskAttempts': masks};
}

class MediumGenerator {
  static const version = 1;
  static const families = [
    'medium-doubleFork',
    'medium-loopBranch',
    'medium-longFork',
    'medium-mesh',
  ];
  static final _legacy = fallbackCatalog(version: 1);
  static final templates = [
    for (final family in families)
      _legacy.firstWhere((p) => 'medium-${p.family}' == family),
  ];
  final int maxAttempts, solverNodes;
  const MediumGenerator({this.maxAttempts = 160, this.solverNodes = 30000});
  GenerationResult generate(int seed) {
    final watch = Stopwatch()..start(),
        report = MediumReport(),
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
      if (candidate.columns > 11 ||
          candidate.rows > 11 ||
          !validGeometry(candidate)) {
        report.reject('geometry');
        continue;
      }
      if (candidate.lines
              .where((e) => e.operator == '×' || e.operator == '÷')
              .length <
          2) {
        report.reject('operationMix');
        continue;
      }
      final keys = candidate.solution.keys.toList();
      GeneratedPuzzle? hidden;
      for (var mask = 0; mask < 8 && hidden == null; mask++) {
        report.masks++;
        rng.shuffle(keys);
        final count = 8 + rng.nextInt(3);
        final test = _copy(candidate, keys.skip(count).toSet());
        if (deduce(test, maxValue: 60).solved) {
          report.reject('easyOnly');
          continue;
        }
        final grade = const LogicalSolver().solve(test);
        if (grade.budgetExceeded) {
          report.reject('logicBudget');
          continue;
        }
        if (!grade.solved || grade.advanced == 0) {
          report.reject('logicStalled');
          continue;
        }
        hidden = test;
      }
      if (hidden == null) continue;
      final solved = PuzzleSolver(
        maxNodes: solverNodes,
        maxValue: 60,
      ).solve(hidden);
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
        id: 'medium-v$version-${seed.toRadixString(16)}-${_hash(hidden.fingerprint)}',
        seed: seed,
        generatorVersion: version,
        family: hidden.family,
        difficulty: 'medium',
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
        difficulty: 'medium',
        cells: p.cells,
        solution: p.solution,
        clues: clues,
        lines: p.lines,
        paths: p.paths,
      );
  GeneratedPuzzle? _candidate(int seed, int family, SeedRandom rng) {
    final rawPaths = templates[family].paths;
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
      final options = ['+', '+', '−', '−', '×', '×', '×', '÷', '÷', '÷'];
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
      difficulty: 'medium',
      cells: {for (final k in ordered) k: cells[k]!},
      solution: {for (final k in ordered) k: values[k]!},
      clues: ordered.toSet(),
      lines: [for (var i = 0; i < paths.length; i++) Equation(ids[i], ops[i]!)],
      paths: paths,
    );
  }

  static final Map<String, List<(int, int, int)>> _triples = {
    '+': [
      for (var a = 1; a <= 60; a++)
        for (var b = 1; b <= 60; b++)
          if (a + b <= 60) (a, b, a + b),
    ],
    '−': [
      for (var a = 1; a <= 60; a++)
        for (var b = 1; b < a; b++) (a, b, a - b),
    ],
    '×': [
      for (var a = 1; a <= 12; a++)
        for (var b = 1; b <= 12; b++)
          if (a * b <= 60) (a, b, a * b),
    ],
    '÷': [
      for (var b = 1; b <= 12; b++)
        for (var c = 1; c <= 12; c++)
          if (b * c <= 60) (b * c, b, c),
    ],
  };
}

/// Isolate entrypoint: JSON-friendly data only, no Flutter binding or storage.
Map<String, dynamic> generateMediumMessage(int seed) {
  final result = const MediumGenerator().generate(seed);
  return {
    'definition': result.puzzle?.toDefinition(),
    'report': {
      ...result.report.toJson(),
      if (result.puzzle != null)
        'logic': const LogicalSolver().solve(result.puzzle!).toJson(),
    },
  };
}
