import 'package:math_puzzle/game.dart';

/// QA only: a connected 9x9 mesh, 20 crossings/equations, 20 empty cells.
/// The outer product of [2,3,5,3,2] yields valid chains such as
/// 4+6=10=6+4, with both arms sharing the central result. No generator is involved.
class CrossingFixture extends Puzzle {
  const CrossingFixture() : super('qa-crossing', const [], const []);
  static const values = [2, 3, 5, 3, 2];
  Map<String, int> get solution => {
    for (var r = 0; r < 5; r++)
      for (var c = 0; c < 5; c++) 'q$r$c': values[r] * values[c],
  };
  @override
  Map<String, (int, int)> get positions => {
    for (var r = 0; r < 5; r++)
      for (var c = 0; c < 5; c++) 'q$r$c': (r * 2, c * 2),
  };
  @override
  Map<String, int> get fixed => {
    for (var i = 0; i < 5; i++) 'q$i$i': values[i] * values[i],
  };
  @override
  List<NumberTile> get tiles => [
    for (final e in solution.entries)
      if (!fixed.containsKey(e.key)) NumberTile('tile-${e.key}', e.value),
  ];
  @override
  List<Equation> get equations => [
    for (var r = 0; r < 5; r++)
      for (final arm in [
        const [0, 1, 2],
        const [4, 3, 2],
      ])
        Equation([for (final c in arm) 'q$r$c'], '+'),
    for (var c = 0; c < 5; c++)
      for (final arm in [
        const [0, 1, 2],
        const [4, 3, 2],
      ])
        Equation([for (final r in arm) 'q$r$c'], '+'),
  ];
  @override
  Map<(int, int), String> get symbols => {
    for (var r = 0; r < 9; r += 2)
      for (var c in [1, 3, 5, 7]) (r, c): c == 1 || c == 7 ? '+' : '=',
    for (var c = 0; c < 9; c += 2)
      for (var r in [1, 3, 5, 7]) (r, c): r == 1 || r == 7 ? '+' : '=',
  };
  @override
  List<(int, int)> equationCoordinates(int index) {
    final line = index % 10,
        fixedAxis = (line ~/ 2) * 2,
        start = (line % 2) * 4;
    return [
      for (var i = start; i <= start + 4; i++)
        index < 10 ? (fixedAxis, i) : (i, fixedAxis),
    ];
  }
}
