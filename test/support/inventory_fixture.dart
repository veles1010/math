import 'package:math_puzzle/game.dart';

/// Layout-only stress fixture, not a generated level: nine independent valid
/// horizontal equations densely fill 9x5. Inventory exactly matches missing cells.
class InventoryFixture extends Puzzle {
  final int count;
  const InventoryFixture(this.count)
    : super('qa-inventory', const [], const []);
  Map<String, int> get solution => {
    for (var r = 0; r < 9; r++) ...{
      'r${r}a': r % 3 + 1,
      'r${r}b': 2,
      'r${r}c': r % 3 + 3,
    },
  };
  @override
  Map<String, (int, int)> get positions => {
    for (var r = 0; r < 9; r++) ...{
      'r${r}a': (r, 0),
      'r${r}b': (r, 2),
      'r${r}c': (r, 4),
    },
  };
  @override
  Map<String, int> get fixed => Map.fromEntries(solution.entries.skip(count));
  @override
  List<NumberTile> get tiles => [
    for (final e in solution.entries.take(count))
      NumberTile('qa-${e.key}', e.value),
  ];
  @override
  List<Equation> get equations => [
    for (var r = 0; r < 9; r++) Equation(['r${r}a', 'r${r}b', 'r${r}c'], '+'),
  ];
  @override
  Map<(int, int), String> get symbols => {
    for (var r = 0; r < 9; r++) ...{(r, 1): '+', (r, 3): '='},
  };
  @override
  List<(int, int)> equationCoordinates(int index) => [
    for (var c = 0; c < 5; c++) (index, c),
  ];
}
