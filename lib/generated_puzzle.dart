import 'dart:collection';

import 'game.dart';

/// Frozen, self-contained puzzle data; saves never regenerate from a seed.
class GeneratedPuzzle extends Puzzle {
  final int seed, generatorVersion;
  final String family;
  final String difficulty;
  final Map<String, (int, int)> cells;
  final Map<String, int> solution;
  final Set<String> clues;
  final List<Equation> lines;
  final List<List<(int, int)>> paths;
  GeneratedPuzzle({
    required String id,
    required this.seed,
    required this.generatorVersion,
    required this.family,
    this.difficulty = 'easy',
    required Map<String, (int, int)> cells,
    required Map<String, int> solution,
    required Set<String> clues,
    required List<Equation> lines,
    required List<List<(int, int)>> paths,
  }) : cells = Map.unmodifiable(cells),
       solution = Map.unmodifiable(solution),
       clues = Set.unmodifiable(clues),
       lines = List.unmodifiable(
         lines.map((e) => Equation(List.unmodifiable(e.cells), e.operator)),
       ),
       paths = List.unmodifiable(
         paths.map((p) => List<(int, int)>.unmodifiable(p)),
       ),
       super(id, const [], const []);
  @override
  Map<String, (int, int)> get positions => cells;
  @override
  Map<String, int> get fixed => {for (final key in clues) key: solution[key]!};
  @override
  List<NumberTile> get tiles => [
    for (final entry
        in solution.entries.where((e) => !clues.contains(e.key)).indexed)
      NumberTile('$id-t${entry.$1}', entry.$2.value),
  ];
  @override
  List<Equation> get equations => lines;
  @override
  List<(int, int)> equationCoordinates(int index) => paths[index];
  @override
  Map<(int, int), String> get symbols => {
    for (var i = 0; i < lines.length; i++) paths[i][1]: lines[i].operator,
    for (final path in paths) path[3]: '=',
  };
  String get fingerprint {
    // Canonical numerical/geometry identity, independent of seed and tile IDs.
    final keys = cells.keys.toList()..sort();
    return '${[for (final key in keys) '${cells[key]}:${solution[key]}:${clues.contains(key) ? 1 : 0}'].join(';')}|${lines.map((e) => '${e.cells.join(',')}${e.operator}').join(';')}';
  }

  Map<String, dynamic> toDefinition() => {
    'id': id,
    if (difficulty != 'easy') 'difficulty': difficulty,
    'seed': seed,
    'generatorVersion': generatorVersion,
    'family': family,
    'cells': {
      for (final e in cells.entries) e.key: [e.value.$1, e.value.$2],
    },
    'solution': solution,
    'clues': clues.toList(),
    'equations': [
      for (var i = 0; i < lines.length; i++)
        {
          'cells': lines[i].cells,
          'operator': lines[i].operator,
          'path': [
            for (final p in paths[i]) [p.$1, p.$2],
          ],
        },
    ],
  };
  factory GeneratedPuzzle.fromDefinition(Map<String, dynamic> data) {
    final difficulty = data['difficulty'] as String? ?? 'easy';
    if (!['easy', 'medium'].contains(difficulty)) {
      throw const FormatException('difficulty');
    }
    final medium = difficulty == 'medium';
    final rawCells = (data['cells'] as Map).cast<String, dynamic>();
    final rawLines = data['equations'] as List;
    if (rawCells.length > 30 || rawLines.length > (medium ? 8 : 6)) {
      throw const FormatException('definition bounds');
    }
    final result = GeneratedPuzzle(
      id: data['id'] as String,
      difficulty: difficulty,
      seed: data['seed'] as int,
      generatorVersion: data['generatorVersion'] as int,
      family: data['family'] as String,
      cells: {
        for (final e in rawCells.entries)
          e.key: ((e.value as List)[0] as int, e.value[1] as int),
      },
      solution: (data['solution'] as Map).cast<String, int>(),
      clues: (data['clues'] as List).cast<String>().toSet(),
      lines: [
        for (final e in rawLines)
          Equation(
            (e['cells'] as List).cast<String>(),
            e['operator'] as String,
          ),
      ],
      paths: [
        for (final e in rawLines)
          [
            for (final p in e['path'] as List)
              ((p as List)[0] as int, p[1] as int),
          ],
      ],
    );
    if (result.lines.length < (medium ? 6 : 4) ||
        result.tiles.length < (medium ? 8 : 5) ||
        result.tiles.length > (medium ? 12 : 8) ||
        !validGeometry(result) ||
        (medium && (result.rows > 11 || result.columns > 11)) ||
        result.solution.keys
            .toSet()
            .difference(result.cells.keys.toSet())
            .isNotEmpty ||
        result.solution.length != result.cells.length ||
        result.clues.any((k) => !result.cells.containsKey(k)) ||
        result.solution.values.any((v) => v < 1 || v > (medium ? 60 : 30)) ||
        result.lines.any((e) => e.check((k) => result.solution[k]) != true)) {
      throw const FormatException('invalid definition');
    }
    return result;
  }
}

/// Validates exact equation runs, shared number identities and all adjacency.
bool validGeometry(GeneratedPuzzle puzzle) {
  if (puzzle.cells.isEmpty || puzzle.lines.length != puzzle.paths.length) {
    return false;
  }
  if (puzzle.cells.values.toSet().length != puzzle.cells.length) return false;
  final occupied = <(int, int), String>{
    for (final e in puzzle.cells.entries) e.value: e.key,
  };
  final edges = <String>{};
  String edge((int, int) a, (int, int) b) => '$a>$b';
  for (var i = 0; i < puzzle.lines.length; i++) {
    final e = puzzle.lines[i], path = puzzle.paths[i];
    if (e.cells.length != 3 || e.operation == null || path.length != 5) {
      return false;
    }
    final dr = path[1].$1 - path[0].$1, dc = path[1].$2 - path[0].$2;
    if (!((dr == 1 && dc == 0) || (dr == 0 && dc == 1))) return false;
    for (var j = 0; j < 5; j++) {
      if (path[j] != (path[0].$1 + j * dr, path[0].$2 + j * dc)) return false;
      if (j.isEven) {
        if (puzzle.cells[e.cells[j ~/ 2]] != path[j]) return false;
      } else {
        if (occupied.containsKey(path[j])) return false;
        occupied[path[j]] = j == 1 ? 'op' : '=';
      }
      if (j > 0) {
        edges.add(edge(path[j - 1], path[j]));
        edges.add(edge(path[j], path[j - 1]));
      }
    }
  }
  if (occupied.keys.any(
    (p) =>
        p.$1 < 0 ||
        p.$2 < 0 ||
        p.$1 > 12 ||
        p.$2 > (puzzle.difficulty == 'medium' ? 10 : 8),
  )) {
    return false;
  }
  for (final p in occupied.keys) {
    for (final delta in [(0, 1), (1, 0)]) {
      final q = (p.$1 + delta.$1, p.$2 + delta.$2);
      if (occupied.containsKey(q) && !edges.contains(edge(p, q))) return false;
      if (!occupied.containsKey((p.$1 - delta.$1, p.$2 - delta.$2))) {
        var n = 1;
        while (occupied.containsKey((
          p.$1 + n * delta.$1,
          p.$2 + n * delta.$2,
        ))) {
          n++;
        }
        if (n != 1 && n != 5) return false;
      }
    }
  }
  final seen = <(int, int)>{},
      todo = Queue<(int, int)>()..add(occupied.keys.first);
  while (todo.isNotEmpty) {
    final p = todo.removeFirst();
    if (!seen.add(p)) continue;
    for (final d in [(0, 1), (1, 0), (0, -1), (-1, 0)]) {
      final q = (p.$1 + d.$1, p.$2 + d.$2);
      if (occupied.containsKey(q) && !seen.contains(q)) todo.add(q);
    }
  }
  return seen.length == occupied.length;
}
