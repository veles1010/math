import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/main.dart';
import 'package:math_puzzle/easy_generator.dart';
import 'package:math_puzzle/easy_fallback.dart';
import 'package:math_puzzle/generated_puzzle.dart';
import 'package:math_puzzle/store.dart';

import 'interaction_test.dart' show mount;

Map<String, Object> prefsFor({Game? game, List<String> recent = const []}) => {
  'settings-v2': '{"tutorial":"skipped","language":"en"}',
  'easy-session-v1': jsonEncode({
    'definition': (game?.puzzle as GeneratedPuzzle?)?.toDefinition(),
    'session': game?.toJson(),
    'completedIds': [],
    'recent': recent,
    'familyCounts': {},
    'lastFamily': null,
    'seedCounter': 10,
    'fallback': false,
  }),
};
Future<void> pressNew(WidgetTester tester) async {
  final finder = find.byKey(const ValueKey('new-easy'));
  await tester.scrollUntilVisible(
    finder,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  for (var seed = 0; seed < 4; seed++) {
    for (final width in [320.0, 390.0]) {
      for (final dark in [false, true]) {
        for (final large in [false, true]) {
          testWidgets(
            'generated layout seed=$seed width=$width dark=$dark large=$large',
            (tester) async {
              addTearDown(tester.view.resetPhysicalSize);
              addTearDown(tester.view.resetDevicePixelRatio);
              final p = const EasyGenerator().generate(seed).puzzle!;
              await mount(
                tester,
                Game(p),
                width: width,
                dark: dark,
                large: large,
              );
              expect(tester.takeException(), isNull);
              for (final key in p.positions.keys) {
                expect(
                  tester.getSize(find.byKey(ValueKey('cell-$key'))).width,
                  greaterThanOrEqualTo(48),
                );
              }
              final pool = tester.getRect(find.byKey(const ValueKey('pool')));
              final header = tester.getRect(find.byType(AppBar));
              final grid = tester.getRect(
                find.byKey(const ValueKey('board-grid')),
              );
              expect(grid.left, greaterThanOrEqualTo(12 - .01));
              expect(grid.right, lessThanOrEqualTo(width - 12 + .01));
              expect(grid.top, greaterThanOrEqualTo(header.bottom));
              expect(grid.bottom, lessThanOrEqualTo(pool.top));
              expect(
                grid.center.dy,
                closeTo((header.bottom + pool.top) / 2, .01),
              );
              for (final key in p.positions.keys) {
                final rect = tester.getRect(find.byKey(ValueKey('cell-$key')));
                expect(rect.left, greaterThanOrEqualTo(12 - .01));
                expect(rect.right, lessThanOrEqualTo(width - 12 + .01));
                expect(rect.top, greaterThanOrEqualTo(header.bottom));
                expect(rect.bottom, lessThanOrEqualTo(pool.top));
                expect(rect.width, closeTo(rect.height, .01));
              }
              for (final pos in p.symbols.keys) {
                final rect = tester.getRect(
                  find.byKey(ValueKey('symbol-${pos.$1}-${pos.$2}')),
                );
                expect(rect.left, greaterThanOrEqualTo(12 - .01));
                expect(rect.right, lessThanOrEqualTo(width - 12 + .01));
                expect(rect.top, greaterThanOrEqualTo(header.bottom));
                expect(rect.bottom, lessThanOrEqualTo(pool.top));
                final numberSize = tester.getSize(
                  find.byKey(ValueKey('cell-${p.positions.keys.first}')),
                );
                expect(rect.width, closeTo(numberSize.width, .00001));
                expect(rect.height, closeTo(numberSize.height, .00001));
              }
              expect(pool.left, greaterThanOrEqualTo(0));
              expect(pool.right, lessThanOrEqualTo(width));
              // Independent pool-row check at the smaller width, not shrinking numbers.
              final slots = [
                for (final tile in p.tiles)
                  tester.getRect(find.byKey(ValueKey('slot-${tile.id}'))),
              ];
              expect(slots.every((r) => r.width >= 48), isTrue);
              if (width == 320 && p.tiles.length == 6) {
                expect(slots.last.top, greaterThan(slots.first.top));
              }
            },
          );
        }
      }
    }
  }
  testWidgets(
    'new easy -> confirmation keeps a partial game; Continue loads it',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(prefsFor());
      final app = MathPuzzleApp(
        generate: (seed) async => generateEasyMessage(seed),
      );
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      await pressNew(tester);
      final first = tester.widget<GameScreen>(find.byType(GameScreen)).game;
      expect(first.puzzle, isA<GeneratedPuzzle>());
      expect(first.canContinue, isTrue);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await pressNew(tester);
      expect(find.text('Start a new easy puzzle?'), findsOneWidget);
      await tester.tap(find.text('Keep current puzzle'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('primary-play')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('primary-play')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<GameScreen>(find.byType(GameScreen)).game.puzzle.id,
        first.puzzle.id,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('bounded generator failure uses a verified reserve visibly', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(prefsFor());
    await tester.pumpWidget(
      MathPuzzleApp(
        generate: (_) async => {
          'definition': null,
          'report': {'exhausted': true},
        },
      ),
    );
    await tester.pumpAndSettle();
    await pressNew(tester);
    expect(find.byType(GameScreen), findsOneWidget);
    final game = tester.widget<GameScreen>(find.byType(GameScreen)).game;
    expect(fallbackCatalog().any((p) => p.id == game.puzzle.id), isTrue);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('verified reserve puzzle'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('verified reserve puzzle'), findsOneWidget);
  });
  testWidgets(
    'fallback exhaustion exits loading and preserves the old partial session',
    (tester) async {
      final p = const EasyGenerator().generate(1).puzzle!;
      final original = Game(p)..beginSession();
      SharedPreferences.setMockInitialValues(
        prefsFor(
          game: original,
          recent: fallbackCatalog().map((p) => p.fingerprint).toList(),
        ),
      );
      await tester.pumpWidget(
        MathPuzzleApp(generate: (_) async => throw StateError('test failure')),
      );
      await tester.pumpAndSettle();
      await pressNew(tester);
      await tester.tap(find.text('Start new'));
      await tester.pumpAndSettle();
      expect(find.textContaining('could not be created'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final loaded = AppStore();
      await loaded.load();
      expect(loaded.generatedGame!.puzzle.id, p.id);
      expect(loaded.generatedGame!.canContinue, isTrue);
    },
  );
}
