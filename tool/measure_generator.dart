import 'dart:convert';
import 'dart:io';

import 'package:math_puzzle/easy_generator.dart';
import 'package:math_puzzle/puzzle_solver.dart';
import 'package:math_puzzle/easy_fallback.dart';

void main(List<String> args) {
  final n = args.isEmpty ? 200 : int.parse(args[0]);
  final families = <String, int>{}, rejects = <String, int>{};
  final operators = <String, int>{}, holes = <int, int>{};
  final bounds = <String, String>{};
  var fallbackUses = 0;
  final times = <int>[], fallbacks = <Map<String, dynamic>>[];
  var attempts = 0, failed = 0;
  for (var seed = 0; seed < n; seed++) {
    final result = const EasyGenerator().generate(seed);
    var p = result.puzzle;
    attempts += result.report.attempts;
    times.add(result.report.elapsedMicros);
    for (final e in result.report.rejected.entries) {
      rejects.update(e.key, (n) => n + e.value, ifAbsent: () => e.value);
    }
    if (p == null) {
      p = pickFallback(EasyGenerator.families[seed % 4], {});
      if (p == null) {
        failed++;
        continue;
      }
      fallbackUses++;
    }
    holes.update(p.tiles.length, (n) => n + 1, ifAbsent: () => 1);
    for (final e in p.lines) {
      operators.update(e.operator, (n) => n + 1, ifAbsent: () => 1);
    }
    families.update(p.family, (n) => n + 1, ifAbsent: () => 1);
    bounds[p.family] = '${p.rows}x${p.columns}';
    if (!const PuzzleSolver().solve(p).unique || !deduce(p).solved) {
      throw StateError('verification $seed');
    }
    if (seed < 8) fallbacks.add(p.toDefinition());
  }
  times.sort();
  final report = {
    'sampleSize': n,
    'attempts': attempts,
    'failed': failed,
    'fallbackUses': fallbackUses,
    'fallbackRate': fallbackUses / n,
    'blankCounts': {for (final e in holes.entries) '${e.key}': e.value},
    'operators': operators,
    'rejections': rejects,
    'families': families,
    'boundsRowsColumns': bounds,
    'micros': {
      'min': times.first,
      'median': times[times.length ~/ 2],
      'p95': times[(times.length * .95).floor()],
      'max': times.last,
    },
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(report));
  Directory('build/generator-work').createSync(recursive: true);
  File('build/generator-work/measurement.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(report));
  if (failed == 0 && n >= 8) {
    File('build/generator-work/fallback.json')
        .writeAsStringSync(jsonEncode(fallbacks));
  }
}
