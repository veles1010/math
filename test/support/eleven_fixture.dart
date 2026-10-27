import 'package:math_puzzle/game.dart';

import 'crossing_fixture.dart';

/// Hand-authored QA only. Extends the mesh with a connected right/bottom arm;
/// visible bounds are exactly 11x11, with deliberate unoccupied coordinates.
class ElevenFixture extends CrossingFixture {
  const ElevenFixture();
  static const extras = {
    'x0': 10,
    'x1': 90,
    'x2': 100,
    'x3': 75,
    'x4': 25,
    'x5': 100,
    'x6': 2,
    'x7': 98,
  };
  static const extraPositions = <String, (int, int)>{
    'x0': (0, 10),
    'x1': (2, 10),
    'x2': (4, 10),
    'x3': (6, 10),
    'x4': (8, 10),
    'x5': (10, 10),
    'x6': (10, 8),
    'x7': (10, 6),
  };
  @override
  String get id => 'qa-eleven';
  @override
  Map<String, int> get solution => _solution;
  static final Map<String, int> _solution = {
    ...const CrossingFixture().solution,
    ...extras,
  };
  @override
  Map<String, (int, int)> get positions => _positions;
  static final Map<String, (int, int)> _positions = {
    ...const CrossingFixture().positions,
    ...extraPositions,
  };
  @override
  Map<String, int> get fixed => _fixed;
  static final Map<String, int> _fixed = {
    ...const CrossingFixture().fixed,
    'q01': 6,
    'q43': 6,
    for (final e in extras.entries)
      if (e.key != 'x0' && e.key != 'x5') e.key: e.value,
  };
  @override
  List<NumberTile> get tiles => _tiles;
  static final List<NumberTile> _tiles = [
    for (final e in _solution.entries)
      if (!_fixed.containsKey(e.key)) NumberTile('tile-${e.key}', e.value),
  ];
  @override
  List<Equation> get equations => _equations;
  static final List<Equation> _equations = [
    ...const CrossingFixture().equations,
    const Equation(['q03', 'q04', 'x0'], '+'),
    const Equation(['x0', 'x1', 'x2'], '+'),
    const Equation(['x4', 'x3', 'x2'], '+'),
    const Equation(['x3', 'x4', 'x5'], '+'),
    const Equation(['x7', 'x6', 'x5'], '+'),
  ];
  @override
  Map<(int, int), String> get symbols => _symbols;
  static final Map<(int, int), String> _symbols = {
    ...const CrossingFixture().symbols,
    (0, 9): '=',
    (1, 10): '+',
    (3, 10): '=',
    (5, 10): '=',
    (7, 10): '+',
    (9, 10): '=',
    (10, 7): '+',
    (10, 9): '=',
  };
  @override
  List<(int, int)> equationCoordinates(int index) => switch (index) {
    20 => [for (var c = 6; c <= 10; c++) (0, c)],
    21 => [for (var r = 0; r <= 4; r++) (r, 10)],
    22 => [for (var r = 4; r <= 8; r++) (r, 10)],
    23 => [for (var r = 6; r <= 10; r++) (r, 10)],
    24 => [for (var c = 6; c <= 10; c++) (10, c)],
    _ => super.equationCoordinates(index),
  };
}
