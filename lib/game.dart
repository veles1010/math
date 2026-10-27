import 'dart:collection';

// Arithmetic is independent of the glyph chosen in settings.
enum Arithmetic { add, subtract, multiply, divide }

Arithmetic? arithmetic(String symbol) => switch (symbol) {
  '+' => Arithmetic.add,
  '−' || '-' => Arithmetic.subtract,
  '×' || '*' => Arithmetic.multiply,
  '÷' || '/' => Arithmetic.divide,
  _ => null,
};

class NumberTile {
  final String id;
  final int value;
  const NumberTile(this.id, this.value);
}

class Equation {
  final List<String> cells;
  final String operator;
  const Equation(this.cells, this.operator);
  Arithmetic? get operation => arithmetic(operator);
  bool? check(int? Function(String) value) {
    final a = value(cells[0]), b = value(cells[1]), c = value(cells[2]);
    if (a == null || b == null || c == null) return null;
    return switch (operation) {
      Arithmetic.add => a + b == c,
      Arithmetic.subtract => a - b == c,
      Arithmetic.multiply => a * b == c,
      Arithmetic.divide => b != 0 && a == b * c,
      null => false,
    };
  }
}

class Puzzle {
  final String id;
  final List<int> numbers;
  final List<String> operators;
  const Puzzle(this.id, this.numbers, this.operators);
  List<Equation> get equations => [
    Equation(['a', 'b', 'c'], operators[0]),
    Equation(['c', 'd', 'e'], operators[1]),
    Equation(['e', 'f', 'g'], operators[2]),
  ];
  Map<String, int> get fixed => {'a': numbers[0], 'd': numbers[3]};
  List<NumberTile> get tiles => [
    for (final i in [1, 2, 4, 5, 6]) NumberTile('$id-$i', numbers[i]),
  ];
  Map<String, (int, int)> get positions => const {
    'a': (0, 2),
    'b': (0, 4),
    'c': (0, 0),
    'd': (2, 0),
    'e': (4, 0),
    'f': (4, 2),
    'g': (4, 4),
  };
  Map<(int, int), String> get symbols => {
    (0, 1): '=',
    (0, 3): operators[0],
    (1, 0): operators[1],
    (3, 0): '=',
    (4, 1): operators[2],
    (4, 3): '=',
  };
  List<(int, int)> equationCoordinates(int index) => switch (index) {
    0 => [for (var c = 0; c < 5; c++) (0, c)],
    1 => [for (var r = 0; r < 5; r++) (r, 0)],
    _ => [for (var c = 0; c < 5; c++) (4, c)],
  };
  int get rows =>
      positions.values.map((p) => p.$1).reduce((a, b) => a > b ? a : b) + 1;
  int get columns =>
      positions.values.map((p) => p.$2).reduce((a, b) => a > b ? a : b) + 1;
}

class TutorialPuzzle extends Puzzle {
  const TutorialPuzzle() : super('tutorial', const [1, 2, 3], const ['+']);
  @override
  List<Equation> get equations => const [
    Equation(['a', 'b', 'c'], '+'),
  ];
  @override
  Map<String, int> get fixed => const {'a': 1};
  @override
  List<NumberTile> get tiles => const [
    NumberTile('tutorial-1', 2),
    NumberTile('tutorial-2', 3),
  ];
  @override
  Map<String, (int, int)> get positions => const {
    'a': (0, 0),
    'b': (0, 2),
    'c': (0, 4),
  };
  @override
  Map<(int, int), String> get symbols => const {(0, 1): '+', (0, 3): '='};
}

const puzzles = [
  Puzzle('one', [8, 4, 12, 3, 4, 4, 8], ['+', '÷', '+']),
  Puzzle('two', [9, 3, 6, 2, 12, 5, 17], ['−', '×', '+']),
  Puzzle('three', [6, 3, 18, 9, 9, 3, 3], ['×', '−', '÷']),
];

/// A monotonic active-play clock. Only the screen controls when it runs.
class PlayClock {
  final Duration Function() now;
  Duration _saved = Duration.zero;
  Duration? _started;
  PlayClock({Duration Function()? now}) : now = now ?? _monotonic;
  static final Stopwatch _watch = Stopwatch()..start();
  static Duration _monotonic() => _watch.elapsed;
  Duration get elapsed =>
      _saved + (_started == null ? Duration.zero : now() - _started!);
  bool get running => _started != null;
  void start() {
    _started ??= now();
  }

  void stop() {
    _saved = elapsed;
    _started = null;
  }

  void restore(Duration elapsed) {
    _saved = elapsed;
    _started = null;
  }
}

class Game {
  final Puzzle puzzle;
  final PlayClock clock;
  final Map<String, String> _placed = {};
  final List<Map<String, String>> _history = [];
  late final List<String> _poolOrder = puzzle.tiles.map((t) => t.id).toList();
  bool resultPresented = false;
  bool legacyTime = false;
  bool _completedOnce = false;
  bool sessionStarted = false;
  bool get completedOnce => _completedOnce || complete;
  bool get canContinue => sessionStarted && !complete;
  void beginSession() {
    sessionStarted = true;
  }

  /// Resets only the current session after the player's explicit replay action.
  void replay() {
    _completedOnce = completedOnce;
    clock.restore(Duration.zero);
    _placed.clear();
    _history.clear();
    _poolOrder
      ..clear()
      ..addAll(puzzle.tiles.map((t) => t.id));
    resultPresented = false;
    legacyTime = false;
    sessionStarted = true;
  }

  Game(this.puzzle, {PlayClock? clock}) : clock = clock ?? PlayClock();
  Map<String, String> get placed => UnmodifiableMapView(_placed);
  List<String> get poolOrder => List.unmodifiable(_poolOrder);
  List<NumberTile> get available => [
    for (final id in _poolOrder)
      if (!_placed.containsValue(id)) tile(id)!,
  ];
  bool get canUndo => _history.isNotEmpty;
  NumberTile? tile(String id) =>
      puzzle.tiles.where((t) => t.id == id).firstOrNull;
  int? value(String cell) =>
      puzzle.fixed[cell] ?? tile(_placed[cell] ?? '')?.value;
  bool editable(String cell) =>
      puzzle.positions.containsKey(cell) && !puzzle.fixed.containsKey(cell);
  bool canTransfer(String tileId, String? target) =>
      tile(tileId) != null &&
      (target == null
          ? _placed.containsValue(tileId)
          : editable(target) && _placed[target] != tileId);

  /// Atomic transaction for tap, drag, replacement and returning to the pool.
  /// No call is made until a drop is accepted; cancelled drags cannot mutate it.
  bool transfer(String tileId, String? target) {
    if (!canTransfer(tileId, target)) return false;
    _history.add(Map.of(_placed));
    _placed.removeWhere((_, id) => id == tileId);
    if (target != null) _placed[target] = tileId;
    sessionStarted = true;
    if (complete) _completedOnce = true;
    return true;
  }

  // Preserve the original public tap API and its inventory guards.
  bool place(String cell, String tileId) =>
      available.any((t) => t.id == tileId) && transfer(tileId, cell);
  bool remove(String cell) =>
      _placed[cell] != null && transfer(_placed[cell]!, null);
  void undo() {
    if (!canUndo) return;
    _placed
      ..clear()
      ..addAll(_history.removeLast());
  }

  void sortPool() {
    final slots = [
      for (var i = 0; i < _poolOrder.length; i++)
        if (!_placed.containsValue(_poolOrder[i])) i,
    ];
    final remaining = [for (final i in slots) _poolOrder[i]];
    final ranks = {for (var i = 0; i < remaining.length; i++) remaining[i]: i};
    remaining.sort((a, b) {
      final c = tile(a)!.value.compareTo(tile(b)!.value);
      return c == 0 ? ranks[a]!.compareTo(ranks[b]!) : c;
    });
    for (var i = 0; i < slots.length; i++) {
      _poolOrder[slots[i]] = remaining[i];
    }
  }

  List<bool?> get equationStates =>
      puzzle.equations.map((e) => e.check(value)).toList();
  bool get complete =>
      puzzle.positions.keys.every((c) => value(c) != null) &&
      equationStates.every((s) => s == true);
  Map<String, dynamic> toJson() => {
    'version': 3,
    'completedOnce': completedOnce,
    'sessionStarted': sessionStarted,
    'placed': Map.of(_placed),
    'history': _history.map(Map.of).toList(),
    'poolOrder': _poolOrder,
    'elapsedMs': clock.elapsed.inMilliseconds,
    'resultPresented': resultPresented,
    'legacyTime': legacyTime,
  };
  bool restore(Map<String, dynamic> data) {
    if (data['version'] is int && (data['version'] as int) > 3) return false;
    Map<String, String>? valid(dynamic raw) {
      if (raw is! Map) return null;
      final result = <String, String>{};
      for (final e in raw.entries) {
        if (e.key is! String ||
            e.value is! String ||
            !editable(e.key as String) ||
            tile(e.value as String) == null ||
            result.containsValue(e.value)) {
          return null;
        }
        result[e.key as String] = e.value as String;
      }
      return result;
    }

    final restored = valid(data['placed']);
    if (restored == null) return false;
    final history = <Map<String, String>>[];
    if (data['history'] is List) {
      for (final raw in data['history'] as List) {
        final snapshot = valid(raw);
        if (snapshot == null) return false;
        history.add(snapshot);
      }
    }
    _placed
      ..clear()
      ..addAll(restored);
    _history
      ..clear()
      ..addAll(history);
    final order = data['poolOrder'];
    if (order is List &&
        order.length == puzzle.tiles.length &&
        order.toSet().length == order.length &&
        order.every((id) => id is String && tile(id) != null)) {
      _poolOrder
        ..clear()
        ..addAll(order.cast<String>());
    }
    final elapsed = data['elapsedMs'];
    legacyTime = data['legacyTime'] == true || elapsed is! int;
    clock.restore(
      Duration(milliseconds: elapsed is int && elapsed >= 0 ? elapsed : 0),
    );
    // Existing completed saves must not replay the success ceremony.
    resultPresented = data['resultPresented'] is bool
        ? data['resultPresented'] as bool
        : complete;
    _completedOnce = data['completedOnce'] == true || complete;
    sessionStarted =
        data['sessionStarted'] == true ||
        _placed.isNotEmpty ||
        clock.elapsed > Duration.zero;
    return true;
  }
}
