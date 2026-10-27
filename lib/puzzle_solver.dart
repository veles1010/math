import 'game.dart';

/// The only inference allowed by the easy grader: two values determine a third.
int? inferMissing(
  Equation equation,
  Map<String, int> values, {
  int maxValue = 30,
}) {
  final a = values[equation.cells[0]],
      b = values[equation.cells[1]],
      c = values[equation.cells[2]];
  int? divide(int n, int d) => d != 0 && n % d == 0 ? n ~/ d : null;
  if ([a, b, c].where((v) => v == null).length != 1) return null;
  final result = switch (equation.operation) {
    Arithmetic.add =>
      a == null
          ? c! - b!
          : b == null
          ? c! - a
          : a + b,
    Arithmetic.subtract =>
      a == null
          ? c! + b!
          : b == null
          ? a - c!
          : a - b,
    Arithmetic.multiply =>
      a == null
          ? divide(c!, b!)
          : b == null
          ? divide(c!, a)
          : a * b,
    Arithmetic.divide =>
      a == null
          ? b! * c!
          : b == null
          ? divide(a, c!)
          : divide(a, b),
    null => null,
  };
  return result != null && result >= 1 && result <= maxValue ? result : null;
}

class SolveResult {
  final List<Map<String, int>> solutions;
  final bool budgetExceeded;
  final int nodes;
  const SolveResult(this.solutions, this.budgetExceeded, this.nodes);
  bool get unique => !budgetExceeded && solutions.length == 1;
}

class DeductionResult {
  final Map<String, int> values;
  final List<String> steps;
  final bool solved;
  const DeductionResult(this.values, this.steps, this.solved);
}

DeductionResult deduce(Puzzle puzzle, {int maxValue = 30}) {
  final values = Map<String, int>.of(puzzle.fixed), steps = <String>[];
  final counts = <int, int>{};
  for (final tile in puzzle.tiles) {
    counts.update(tile.value, (v) => v + 1, ifAbsent: () => 1);
  }
  var changed = true;
  while (changed) {
    changed = false;
    for (final e in puzzle.equations) {
      final missing = e.cells.where((k) => !values.containsKey(k)).toList();
      if (missing.isEmpty && e.check((k) => values[k]) != true) {
        return DeductionResult(values, steps, false);
      }
      if (missing.length != 1) continue;
      final v = inferMissing(e, values, maxValue: maxValue);
      if (v == null || (counts[v] ?? 0) == 0) {
        return DeductionResult(values, steps, false);
      }
      values[missing.single] = v;
      counts[v] = counts[v]! - 1;
      steps.add(missing.single);
      changed = true;
    }
  }
  return DeductionResult(
    values,
    steps,
    values.length == puzzle.positions.length &&
        counts.values.every((n) => n == 0) &&
        puzzle.equations.every((e) => e.check((k) => values[k]) == true),
  );
}

/// Searches numerical assignments with a value multiset, never tile permutations.
class PuzzleSolver {
  final int maxNodes, maxValue;
  const PuzzleSolver({this.maxNodes = 10000, this.maxValue = 30});
  SolveResult solve(Puzzle puzzle) {
    var nodes = 0, exceeded = false;
    final answers = <Map<String, int>>[];
    final counts = <int, int>{};
    for (final t in puzzle.tiles) {
      counts.update(t.value, (n) => n + 1, ifAbsent: () => 1);
    }
    final unknown = puzzle.positions.keys
        .where((k) => !puzzle.fixed.containsKey(k))
        .toList();
    void search(Map<String, int> assigned, Map<int, int> bag) {
      if (answers.length >= 2 || exceeded) return;
      if (nodes >= maxNodes) {
        exceeded = true;
        return;
      }
      nodes++;
      final values = Map<String, int>.of(assigned),
          left = Map<int, int>.of(bag);
      var changed = true;
      while (changed) {
        changed = false;
        for (final e in puzzle.equations) {
          final missing = e.cells.where((k) => !values.containsKey(k)).toList();
          if (missing.isEmpty) {
            if (e.check((k) => values[k]) != true) return;
          } else if (missing.length == 1) {
            final v = inferMissing(e, values, maxValue: maxValue);
            if (v == null || (left[v] ?? 0) == 0) return;
            values[missing.single] = v;
            left[v] = left[v]! - 1;
            changed = true;
          }
        }
      }
      final remaining = unknown.where((k) => !values.containsKey(k)).toList();
      if (remaining.isEmpty) {
        if (left.values.every((n) => n == 0)) answers.add(values);
        return;
      }
      int score(String key) => puzzle.equations
          .where((e) => e.cells.contains(key))
          .fold(
            0,
            (s, e) => s + 1 + e.cells.where(values.containsKey).length * 3,
          );
      remaining.sort((a, b) {
        final s = score(b).compareTo(score(a));
        return s == 0 ? a.compareTo(b) : s;
      });
      final key = remaining.first,
          options = left.keys.where((v) => left[v]! > 0).toList()..sort();
      for (final value in options) {
        search({...values, key: value}, {...left, value: left[value]! - 1});
        if (answers.length >= 2 || exceeded) return;
      }
    }

    if (unknown.length == puzzle.tiles.length) {
      search(Map.of(puzzle.fixed), counts);
    }
    return SolveResult(answers, exceeded, nodes);
  }
}
