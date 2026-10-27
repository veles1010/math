import 'dart:convert';
import 'dart:io';

import 'package:math_puzzle/medium_generator.dart';
import 'package:math_puzzle/medium_fallback.dart';
import 'package:math_puzzle/logical_solver.dart';
import 'package:math_puzzle/generated_puzzle.dart';
import 'package:math_puzzle/puzzle_solver.dart';

void main(List<String> args) {
  final n = args.isEmpty ? 200 : int.parse(args.first),
      times = <int>[],
      frozen = <Map<String, dynamic>>[];
  final families = <String, int>{},
      rejects = <String, int>{},
      holes = <String, int>{},
      ops = <String, int>{},
      rules = <String, int>{};
  var failed = 0, fallbackUses = 0, attempts = 0, masks = 0;
  for (var seed = 0; seed < n; seed++) {
    final r = const MediumGenerator().generate(seed);
    var p = r.puzzle;
    attempts += r.report.attempts;
    masks += (r.report as MediumReport).masks;
    times.add(r.report.elapsedMicros);
    for (final e in r.report.rejected.entries) {
      rejects.update(e.key, (v) => v + e.value, ifAbsent: () => e.value);
    }
    if (p == null) {
      p = pickMediumFallback(MediumGenerator.families[seed % 4], {});
      if (p == null) {
        failed++;
        continue;
      }
      fallbackUses++;
    }
    final logic = const LogicalSolver().solve(p);
    if (!validGeometry(p) ||
        !const PuzzleSolver(maxValue: 60, maxNodes: 30000).solve(p).unique ||
        deduce(p, maxValue: 60).solved ||
        !logic.solved ||
        logic.advanced == 0) {
      throw StateError('seed $seed');
    }
    families.update(p.family, (v) => v + 1, ifAbsent: () => 1);
    holes.update('${p.tiles.length}', (v) => v + 1, ifAbsent: () => 1);
    for (final e in p.lines) {
      ops.update(e.operator, (v) => v + 1, ifAbsent: () => 1);
    }
    for (final e in logic.toJson().entries.where((e) => e.value is int)) {
      rules.update(
        e.key,
        (v) => v + (e.value as int),
        ifAbsent: () => e.value as int,
      );
    }
    if (seed < 8) frozen.add(p.toDefinition());
  }
  times.sort();
  final report = {
    'sample': n,
    'accepted': n - failed,
    'failed': failed,
    'fallbackUses': fallbackUses,
    'fallbackRate': fallbackUses / n,
    'attempts': attempts,
    'maskAttempts': masks,
    'rejections': rejects,
    'families': families,
    'holes': holes,
    'operators': ops,
    'ruleTotals': rules,
    'micros': {
      'median': times[n ~/ 2],
      'p95': times[(n * .95).floor()],
      'max': times.last,
    },
  };
  Directory('build/medium-work').createSync(recursive: true);
  File('build/medium-work/measurement.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
  if (failed == 0 && frozen.length == 8) {
    File('build/medium-work/fallback.json')
        .writeAsStringSync(jsonEncode(frozen));
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
}
