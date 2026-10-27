import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_puzzle/board.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/l10n/app_localizations.dart';

import 'banner_layout_test.dart' show showGame, resetView;
import 'support/eleven_fixture.dart';

void main() {
  testWidgets(
    'zero-width startup inventory is safe before viewport metrics arrive',
    (tester) async {
      final game = Game(const ElevenFixture());
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Center(
            child: SizedBox(
              width: 0,
              child: PoolPanel(
                game: game,
                onTransfer: (_, _) {},
                onUndo: () {},
                onReturn: () {},
                onSort: () {},
                onDragging: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );
  test(
    '11x11 QA is connected, arithmetic valid and inventory exact; restore/undo',
    () {
      const p = ElevenFixture();
      expect(p.rows, 11);
      expect(p.columns, 11);
      expect(p.tiles.length, 20);
      expect(
        p.equations.every((e) => e.check((k) => p.solution[k]) == true),
        isTrue,
      );
      final reached = {p.positions.keys.first};
      while (true) {
        final n = reached.length;
        for (final e in p.equations) {
          if (e.cells.any(reached.contains)) reached.addAll(e.cells);
        }
        if (n == reached.length) break;
      }
      expect(reached.length, p.positions.length);
      expect(p.tiles.any((t) => t.value >= 100), isTrue);
      expect(p.tiles.any((t) => t.value < 10), isTrue);
      expect(p.tiles.map((t) => t.value).toSet().length, lessThan(20));
      final game = Game(p);
      for (final e in p.solution.entries.where(
        (e) => !p.fixed.containsKey(e.key),
      )) {
        expect(game.transfer('tile-${e.key}', e.key), isTrue);
      }
      expect(game.complete, isTrue);
      expect(game.available, isEmpty);
      final restored = Game(p);
      expect(restored.restore(game.toJson()), isTrue);
      expect(restored.placed, game.placed);
      restored.undo();
      expect(restored.complete, isFalse);
    },
  );
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
  ]) {
    for (final dark in [false, true]) {
      for (final lang in ['en', 'tr']) {
        for (final large in [false, true]) {
          for (final banner in [50.0, 90.0]) {
            testWidgets(
              'full interactive 11x11 $size $dark $lang large=$large banner=$banner',
              (tester) async {
                resetView(tester);
                const p = ElevenFixture();
                final game = Game(p);
                await showGame(
                  tester,
                  game,
                  size,
                  banner,
                  dark: dark,
                  language: lang,
                  large: large,
                );
                expect(tester.takeException(), isNull);
                final square = tester.getRect(
                  find.byKey(const ValueKey('board-square')),
                );
                final pool = tester.getRect(find.byKey(const ValueKey('pool')));
                final viewport = tester.getRect(
                  find.byKey(const ValueKey('pool-viewport')),
                );
                final controls = tester.getRect(
                  find.byKey(const ValueKey('pool-controls')),
                );
                final ad = tester.getRect(
                  find.byKey(const ValueKey('qa-banner')),
                );
                expect(square.width, closeTo(square.height, .01));
                expect(square.bottom, lessThanOrEqualTo(pool.top));
                expect(viewport.bottom, lessThanOrEqualTo(controls.top));
                expect(controls.bottom, lessThanOrEqualTo(ad.top - 8));
                expect(ad.bottom, lessThanOrEqualTo(size.height - 24));
                expect(find.byKey(const ValueKey('board-zoom')), findsNothing);
                expect(
                  tester
                      .widget<PuzzleBoard>(find.byType(PuzzleBoard))
                      .interactive,
                  isTrue,
                );
                final number = tester.getRect(
                  find.byKey(const ValueKey('cell-x0')),
                );
                for (final key in p.positions.keys) {
                  final cell = find.byKey(ValueKey('cell-$key'));
                  final r = tester.getRect(cell);
                  expect(r.width, closeTo(r.height, .01));
                  expect(r.width, closeTo(number.width, .01));
                  expect(r.left, greaterThanOrEqualTo(square.left - .01));
                  expect(r.right, lessThanOrEqualTo(square.right + .01));
                  expect(r.top, greaterThanOrEqualTo(square.top - .01));
                  expect(r.bottom, lessThanOrEqualTo(square.bottom + .01));
                  if (!p.fixed.containsKey(key)) {
                    await tester.tap(cell);
                    await tester.pump();
                    expect(tester.widget<Stone>(cell).selected, isTrue);
                  } else {
                    final label = find.descendant(
                      of: cell,
                      matching: find.byKey(const ValueKey('board-label')),
                    );
                    final text = tester.getRect(label);
                    expect(text.left, greaterThanOrEqualTo(r.left - .01));
                    expect(text.right, lessThanOrEqualTo(r.right + .01));
                  }
                }
                for (final pos in p.symbols.keys) {
                  final r = tester.getRect(
                    find.byKey(ValueKey('symbol-${pos.$1}-${pos.$2}')),
                  );
                  expect(r.width, closeTo(number.width, .01));
                  expect(r.left, greaterThanOrEqualTo(square.left - .01));
                  expect(r.right, lessThanOrEqualTo(square.right + .01));
                  expect(r.top, greaterThanOrEqualTo(square.top - .01));
                  expect(r.bottom, lessThanOrEqualTo(square.bottom + .01));
                }
                final right = tester.getRect(
                  find.byKey(const ValueKey('symbol-0-9')),
                );
                expect(number.left - right.right, closeTo(1, .01));
                expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);
                if (size.width >= 360) {
                  for (final tile in p.tiles) {
                    final r = tester.getRect(
                      find.byKey(ValueKey('slot-${tile.id}')),
                    );
                    expect(r.top, greaterThanOrEqualTo(viewport.top - .01));
                    expect(r.bottom, lessThanOrEqualTo(viewport.bottom + .01));
                  }
                }
                await tester.tap(find.byKey(const ValueKey('cell-x0')));
                await tester.pump();
                // Last selection may already be x0 only if ordering changes; explicitly select via another cell first.
                if (!tester
                    .widget<Stone>(find.byKey(const ValueKey('cell-x0')))
                    .selected) {
                  await tester.tap(find.byKey(const ValueKey('cell-x0')));
                  await tester.pump();
                }
                await tester.ensureVisible(
                  find.byKey(const ValueKey('tile-tile-x0')),
                );
                await tester.tap(find.byKey(const ValueKey('tile-tile-x0')));
                await tester.pumpAndSettle();
                expect(game.placed['x0'], 'tile-x0');
                expect(
                  tester.getRect(find.byKey(const ValueKey('pool'))),
                  pool,
                );
                // Inspect a completed full board and all actual result controls.
                for (final e in p.solution.entries.where(
                  (e) => !p.fixed.containsKey(e.key) && e.key != 'x0',
                )) {
                  game.transfer('tile-${e.key}', e.key);
                }
                await tester.pumpWidget(const SizedBox());
                await showGame(
                  tester,
                  game,
                  size,
                  banner,
                  dark: dark,
                  language: lang,
                  large: large,
                );
                final preview = tester.getRect(
                  find.byKey(const ValueKey('result-preview')),
                );
                final grid = tester.getRect(
                  find.byKey(const ValueKey('board-grid')),
                );
                expect(preview.contains(grid.topLeft), isTrue);
                expect(
                  preview.contains(grid.bottomRight - const Offset(.01, .01)),
                  isTrue,
                );
                expect(
                  tester
                      .getRect(find.byKey(const ValueKey('result-actions')))
                      .bottom,
                  lessThanOrEqualTo(ad.top - 8),
                );
                expect(tester.takeException(), isNull);
              },
            );
          }
        }
      }
    }
  }
  testWidgets(
    'fitted corners drag center, invalid neighbor, replacement, pool return and undo',
    (tester) async {
      resetView(tester);
      final game = Game(const ElevenFixture());
      await showGame(tester, game, const Size(320, 568), 90);
      Future<void> drag(Finder source, Finder target, {bool? hover}) async {
        await tester.ensureVisible(source);
        await tester.pumpAndSettle();
        final from = tester.getCenter(source), to = tester.getCenter(target);
        final gesture = await tester.startGesture(from);
        await gesture.moveBy(const Offset(0, -12));
        await tester.pump();
        for (var i = 1; i <= 20; i++) {
          await gesture.moveTo(
            Offset.lerp(
              from + const Offset(0, -12),
              to - TileDrag.feedbackCenterOffset,
              i / 20,
            )!,
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(
          (tester.getCenter(find.byKey(const ValueKey('drag-feedback'))) - to)
              .distance,
          lessThan(.1),
        );
        if (hover != null) expect(tester.widget<Stone>(target).hover, hover);
        await gesture.up();
        await tester.pumpAndSettle();
      }

      await drag(
        find.byKey(const ValueKey('tile-tile-x0')),
        find.byKey(const ValueKey('symbol-0-9')),
        hover: false,
      );
      expect(game.placed, isEmpty);
      expect(game.canUndo, isFalse);
      await drag(
        find.byKey(const ValueKey('tile-tile-x0')),
        find.byKey(const ValueKey('cell-x0')),
        hover: true,
      );
      expect(game.placed['x0'], 'tile-x0');
      await drag(
        find.byKey(const ValueKey('tile-tile-x5')),
        find.byKey(const ValueKey('cell-x5')),
        hover: true,
      );
      expect(game.placed['x5'], 'tile-x5');
      await drag(
        find.byKey(const ValueKey('cell-x5')),
        find.byKey(const ValueKey('cell-x0')),
        hover: true,
      );
      expect(game.placed['x0'], 'tile-x5');
      expect(game.placed.containsKey('x5'), isFalse);
      await tester.tap(find.byKey(const ValueKey('undo')));
      await tester.pumpAndSettle();
      expect(game.placed['x5'], 'tile-x5');
      expect(game.placed['x0'], 'tile-x0');
      await drag(
        find.byKey(const ValueKey('cell-x0')),
        find.byKey(const ValueKey('pool')),
      );
      expect(game.placed.containsKey('x0'), isFalse);
      await tester.tap(find.byKey(const ValueKey('undo')));
      await tester.pumpAndSettle();
      expect(game.placed['x0'], 'tile-x0');
    },
  );
}
