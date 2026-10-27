import 'game.dart';
import 'puzzle_solver.dart';

class LogicResult {
  final Map<String, int> values;
  final bool solved, budgetExceeded;
  final int singles,
      poolPlacements,
      intersectionPlacements,
      inventoryPlacements,
      candidateEliminations,
      intersectionEliminations,
      tupleChecks;
  const LogicResult(
    this.values,
    this.solved,
    this.budgetExceeded,
    this.singles,
    this.poolPlacements,
    this.intersectionPlacements,
    this.inventoryPlacements,
    this.candidateEliminations,
    this.intersectionEliminations,
    this.tupleChecks,
  );
  int get advanced =>
      poolPlacements + intersectionPlacements + inventoryPlacements;
  Map<String, dynamic> toJson() => {
    'solved': solved,
    'budgetExceeded': budgetExceeded,
    'singles': singles,
    'poolPlacements': poolPlacements,
    'intersectionPlacements': intersectionPlacements,
    'inventoryPlacements': inventoryPlacements,
    'candidateEliminations': candidateEliminations,
    'intersectionEliminations': intersectionEliminations,
    'tupleChecks': tupleChecks,
  };
}

/// Monotone domain propagation, never a guessed assignment or backtracking.
/// Tuple enumeration is local to one equation and obeys remaining tile counts.
class LogicalSolver {
  final int maxChecks, maxPasses, maxValue;
  const LogicalSolver({
    this.maxChecks = 100000,
    this.maxPasses = 128,
    this.maxValue = 60,
  });
  LogicResult solve(Puzzle p) {
    final values = Map<String, int>.of(p.fixed), bag = <int, int>{};
    for (final tile in p.tiles) {
      bag.update(tile.value, (n) => n + 1, ifAbsent: () => 1);
    }
    final domains = {
      for (final k in p.positions.keys.where((k) => !values.containsKey(k)))
        k: bag.keys.toSet(),
    };
    var singles = 0,
        pool = 0,
        cross = 0,
        inventory = 0,
        eliminated = 0,
        crossEliminated = 0,
        checks = 0,
        exceeded = false;
    LogicResult finish(bool solved) => LogicResult(
      Map.unmodifiable(values),
      solved,
      exceeded,
      singles,
      pool,
      cross,
      inventory,
      eliminated,
      crossEliminated,
      checks,
    );
    bool assign(String key, int value) {
      if ((bag[value] ?? 0) <= 0) return false;
      values[key] = value;
      bag[value] = bag[value]! - 1;
      domains.remove(key);
      return true;
    }

    for (var pass = 0; pass < maxPasses; pass++) {
      var changed = false;
      // Prefer the same easy rule first; advanced placements are only counted
      // after no further two-known-value equation can progress.
      var singleProgress = true;
      while (singleProgress) {
        singleProgress = false;
        for (final e in p.equations) {
          final missing = e.cells.where((k) => !values.containsKey(k)).toList();
          if (missing.isEmpty && e.check((k) => values[k]) != true) {
            return finish(false);
          }
          if (missing.length != 1) continue;
          final v = inferMissing(e, values, maxValue: maxValue);
          if (v == null ||
              !domains[missing.single]!.contains(v) ||
              !assign(missing.single, v)) {
            return finish(false);
          }
          singles++;
          singleProgress = true;
          changed = true;
        }
      }
      if (domains.isEmpty) {
        return finish(
          bag.values.every((n) => n == 0) &&
              p.equations.every((e) => e.check((k) => values[k]) == true),
        );
      }
      final local = <String, List<Set<int>>>{
        for (final k in domains.keys) k: [],
      };
      for (final e in p.equations) {
        final missing = e.cells.where((k) => !values.containsKey(k)).toList();
        if (missing.isEmpty) continue;
        final projection = {for (final k in missing) k: <int>{}};
        List<int> options(String k) =>
            values.containsKey(k)
                  ? [values[k]!]
                  : domains[k]!.where((v) => (bag[v] ?? 0) > 0).toList()
              ..sort();
        final aKey = e.cells[0], bKey = e.cells[1], cKey = e.cells[2];
        final cOptions = options(cKey).toSet();
        for (final a in options(aKey)) {
          for (final b in options(bKey)) {
            if (++checks > maxChecks) {
              exceeded = true;
              return finish(false);
            }
            final c = inferMissing(e, {aKey: a, bKey: b}, maxValue: maxValue);
            if (c == null || !cOptions.contains(c)) continue;
            final tuple = {aKey: a, bKey: b, cKey: c}, used = <int, int>{};
            for (final key in missing) {
              used.update(tuple[key]!, (n) => n + 1, ifAbsent: () => 1);
            }
            if (used.entries.any(
              (entry) => entry.value > (bag[entry.key] ?? 0),
            )) {
              continue;
            }
            for (final key in missing) {
              projection[key]!.add(tuple[key]!);
            }
          }
        }
        if (projection.values.any((d) => d.isEmpty)) return finish(false);
        for (final k in missing) {
          local[k]!.add(projection[k]!);
        }
      }
      final crossReduced = <String>{};
      for (final k in domains.keys.toList()) {
        var next = domains[k]!.where((v) => (bag[v] ?? 0) > 0).toSet();
        for (final projection in local[k]!) {
          next = next.intersection(projection);
        }
        if (next.isEmpty) return finish(false);
        final removed = domains[k]!.length - next.length;
        if (removed > 0) {
          eliminated += removed;
          changed = true;
          if (local[k]!.length > 1 &&
              local[k]!.every((s) => s.length > next.length)) {
            crossReduced.add(k);
            final bestSingle = local[k]!
                .map((s) => s.length)
                .reduce((a, b) => a < b ? a : b);
            crossEliminated += bestSingle - next.length;
          }
          domains[k] = next;
        }
      }
      final inventoryForced = <String>{};
      for (final entry in bag.entries.where((e) => e.value > 0)) {
        final places = domains.keys
            .where((k) => domains[k]!.contains(entry.key))
            .toList();
        if (places.length < entry.value) return finish(false);
        if (places.length == entry.value) {
          for (final k in places) {
            if (domains[k]!.length > 1) {
              eliminated += domains[k]!.length - 1;
              domains[k] = {entry.key};
              inventoryForced.add(k);
              changed = true;
            }
          }
        }
      }
      final forced = domains.keys
          .where((k) => domains[k]!.length == 1)
          .toList();
      for (final k in forced) {
        final v = domains[k]!.single;
        if (!assign(k, v)) return finish(false);
        if (inventoryForced.contains(k)) {
          inventory++;
        } else if (crossReduced.contains(k)) {
          cross++;
        } else {
          pool++;
        }
        changed = true;
      }
      if (!changed) return finish(false);
    }
    exceeded = true;
    return finish(false);
  }
}
