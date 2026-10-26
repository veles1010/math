import 'package:flutter_test/flutter_test.dart';
import 'package:math_puzzle/game.dart';

void main() {
  test('all authored crossing equations are mathematically correct', () {
    for (final puzzle in puzzles) {
      final values = Map.fromIterables([
        'a',
        'b',
        'c',
        'd',
        'e',
        'f',
        'g',
      ], puzzle.numbers);
      for (final equation in puzzle.equations) {
        expect(equation.check((id) => values[id]), isTrue);
      }
      expect(puzzle.equations[0].cells.last, puzzle.equations[1].cells.first);
      expect(puzzle.equations[1].cells.last, puzzle.equations[2].cells.first);
    }
  });
  test('equations reject invalid arithmetic and non-exact division', () {
    expect(
      const Equation([
        'a',
        'b',
        'c',
      ], '÷').check((id) => {'a': 7, 'b': 2, 'c': 3}[id]),
      isFalse,
    );
    expect(
      const Equation([
        'a',
        'b',
        'c',
      ], '÷').check((id) => {'a': 0, 'b': 0, 'c': 0}[id]),
      isFalse,
    );
    expect(const Equation(['a', 'b', 'c'], '+').check((id) => null), isNull);
    expect(
      const Equation([
        'a',
        'b',
        'c',
      ], '−').check((id) => {'a': 2, 'b': 3, 'c': -1}[id]),
      isTrue,
    );
  });
  test(
    'equal-value tiles have independent identities and cannot be reused',
    () {
      final game = Game(puzzles.first);
      expect(game.place('b', 'one-1'), isTrue);
      expect(game.place('e', 'one-1'), isFalse);
      expect(game.place('e', 'one-4'), isTrue);
      expect(game.value('b'), 4);
      expect(game.value('e'), 4);
      expect(game.available.length, 3);
      expect(game.place('a', 'one-5'), isFalse);
      expect(game.place('invalid', 'one-5'), isFalse);
      expect(game.place('f', 'unknown'), isFalse);
    },
  );
  test('replacement, return and undo preserve the entire inventory', () {
    final game = Game(puzzles.first);
    game.place('b', 'one-1');
    game.place('b', 'one-2');
    expect(game.available.any((t) => t.id == 'one-1'), isTrue);
    game.remove('b');
    expect(game.available.length, 5);
    game.undo();
    expect(game.value('b'), 12);
    game.undo();
    expect(game.placed['b'], 'one-1');
    game.undo();
    expect(game.available.length, 5);
    game.undo();
    expect(game.canUndo, isFalse);
  });
  test(
    'completion evaluates equations instead of a hidden tile assignment',
    () {
      final game = Game(puzzles.first);
      // Swap identical tiles relative to their authored positions.
      for (final entry in {
        'b': 'one-5',
        'c': 'one-2',
        'e': 'one-1',
        'f': 'one-4',
        'g': 'one-6',
      }.entries) {
        game.place(entry.key, entry.value);
      }
      expect(game.complete, isTrue);
      game.remove('c');
      expect(game.complete, isFalse);
    },
  );
  test('a different valid numeric solution is accepted', () {
    const puzzle = Puzzle('alt', [10, 4, 6, 2, 8, 6, 14], ['−', '+', '+']);
    final game = Game(puzzle);
    // Authored: 10-4=6, 6+2=8, 8+6=14.
    // Alternative: 10-6=4, 4+2=6, 6+8=14.
    for (final entry in {
      'b': 'alt-2',
      'c': 'alt-1',
      'e': 'alt-5',
      'f': 'alt-4',
      'g': 'alt-6',
    }.entries) {
      game.place(entry.key, entry.value);
    }
    expect(game.complete, isTrue);
  });
  test('save round trip preserves undo; corrupt inventory is rejected', () {
    final game = Game(puzzles.first)..place('b', 'one-1');
    final restored = Game(puzzles.first)..restore(game.toJson());
    expect(restored.placed, game.placed);
    restored.undo();
    expect(restored.available.length, 5);
    restored.restore({
      'placed': {'b': 'one-1', 'e': 'one-1'},
    });
    expect(restored.placed, isEmpty);
  });
}
