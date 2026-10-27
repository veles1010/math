import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_puzzle/board.dart';
import 'package:math_puzzle/game.dart';

import 'banner_layout_test.dart' show showGame, resetView;
import 'support/inventory_fixture.dart';

void main() {
  for (final count in [5, 10, 15, 20]) {
    for (final size in [
      const Size(320, 568),
      const Size(360, 640),
      const Size(390, 844),
    ]) {
      for (final dark in [false, true]) {
        for (final banner in [50.0, 90.0]) {
          testWidgets('square and inventory $count $size $dark $banner', (
            tester,
          ) async {
            resetView(tester);
            final puzzle = InventoryFixture(count),
                game = Game(InventoryFixture(count));
            expect(puzzle.tiles.length, count);
            expect(
              puzzle.equations.every(
                (e) => e.check((key) => puzzle.solution[key]) == true,
              ),
              isTrue,
            );
            expect(puzzle.positions.length - puzzle.fixed.length, count);
            await showGame(
              tester,
              game,
              size,
              banner,
              dark: dark,
              language: 'tr',
            );
            expect(tester.takeException(), isNull);
            if (find
                .byKey(const ValueKey('board-zoom'))
                .evaluate()
                .isNotEmpty) {
              await tester.tap(find.byKey(const ValueKey('board-zoom')));
              await tester.pumpAndSettle();
            }
            final square = tester.getRect(
              find.byKey(const ValueKey('board-square')),
            );
            final grid = tester.getRect(
              find.byKey(const ValueKey('board-grid')),
            );
            final pool = tester.getRect(find.byKey(const ValueKey('pool')));
            final controls = tester.getRect(
              find.byKey(const ValueKey('pool-controls')),
            );
            final viewport = tester.getRect(
              find.byKey(const ValueKey('pool-viewport')),
            );
            final ad = tester.getRect(find.byKey(const ValueKey('qa-banner')));
            expect(square.width, closeTo(square.height, .01));
            expect(grid.top, greaterThanOrEqualTo(square.top - .01));
            expect(grid.bottom, lessThanOrEqualTo(square.bottom + .01));
            expect(square.bottom, lessThanOrEqualTo(pool.top));
            expect(viewport.bottom, lessThanOrEqualTo(controls.top));
            expect(controls.bottom, lessThanOrEqualTo(ad.top - 8));
            expect(ad.bottom, lessThanOrEqualTo(size.height - 24));
            for (final cell in puzzle.positions.keys) {
              final r = tester.getRect(find.byKey(ValueKey('cell-$cell')));
              expect(r.width, closeTo(r.height, .01));
              expect(r.left, greaterThanOrEqualTo(square.left - .01));
              expect(r.right, lessThanOrEqualTo(square.right + .01));
            }
            for (final tile in puzzle.tiles) {
              expect(
                tester.getSize(find.byKey(ValueKey('slot-${tile.id}'))).width,
                greaterThanOrEqualTo(36),
              );
            }
            // Stable slots/height after a placement, including duplicate values.
            final slots = {
              for (final tile in puzzle.tiles)
                tile.id: tester.getRect(
                  find.byKey(ValueKey('slot-${tile.id}')),
                ),
            };
            if (find
                .byKey(const ValueKey('board-zoom'))
                .evaluate()
                .isNotEmpty) {
              await tester.tap(find.byKey(const ValueKey('board-zoom')));
              await tester.pumpAndSettle();
            }
            await tester.tap(find.byKey(const ValueKey('cell-r0a')));
            await tester.pump();
            await tester.tap(find.byKey(const ValueKey('tile-qa-r0a')));
            await tester.pumpAndSettle();
            expect(game.placed['r0a'], 'qa-r0a');
            expect(tester.getRect(find.byKey(const ValueKey('pool'))), pool);
            for (final tile in puzzle.tiles) {
              expect(
                tester.getRect(find.byKey(ValueKey('slot-${tile.id}'))),
                slots[tile.id],
              );
            }
            // The last slot can always be brought into the inventory viewport.
            await tester.ensureVisible(
              find.byKey(ValueKey('slot-${puzzle.tiles.last.id}')),
            );
            await tester.pumpAndSettle();
            final last = tester.getRect(
              find.byKey(ValueKey('slot-${puzzle.tiles.last.id}')),
            );
            expect(last.bottom, lessThanOrEqualTo(viewport.bottom + .01));
            expect(
              tester.getRect(find.byKey(const ValueKey('board-square'))),
              square,
            );
          });
        }
      }
    }
  }
  testWidgets(
    'small target accepts visible center, rejects adjacent symbol, replaces and undoes',
    (tester) async {
      resetView(tester);
      final game = Game(const InventoryFixture(20));
      await showGame(tester, game, const Size(320, 568), 90);
      Future<void> drop(String tile, Finder target, {bool valid = true}) async {
        final from = tester.getCenter(find.byKey(ValueKey('tile-$tile')));
        final to = tester.getCenter(target);
        final gesture = await tester.startGesture(from);
        await gesture.moveBy(const Offset(0, -12));
        await tester.pump();
        for (var i = 1; i <= 16; i++) {
          await gesture.moveTo(
            Offset.lerp(
              from + const Offset(0, -12),
              to - TileDrag.feedbackCenterOffset,
              i / 16,
            )!,
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        expect(
          (tester.getCenter(find.byKey(const ValueKey('drag-feedback'))) - to)
              .distance,
          lessThan(.1),
        );
        expect(tester.widget<Stone>(target).hover, valid);
        await gesture.up();
        await tester.pumpAndSettle();
      }

      await drop(
        'qa-r0a',
        find.byKey(const ValueKey('symbol-0-1')),
        valid: false,
      );
      expect(game.placed, isEmpty);
      expect(game.canUndo, isFalse);
      final target = find.byKey(const ValueKey('cell-r0a'));
      await drop('qa-r0a', target);
      expect(game.placed['r0a'], 'qa-r0a');
      await drop('qa-r0b', target);
      expect(game.placed['r0a'], 'qa-r0b');
      expect(game.available.any((t) => t.id == 'qa-r0a'), isTrue);
      await tester.tap(find.byKey(const ValueKey('undo')));
      await tester.pumpAndSettle();
      expect(game.placed['r0a'], 'qa-r0a');
    },
  );
}
