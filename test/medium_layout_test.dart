import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_puzzle/board.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/medium_generator.dart';

import 'banner_layout_test.dart' show showGame, resetView;

void main() {
  final measurements = <Map<String, dynamic>>[];
  tearDownAll(() {
    Directory('build/medium-layout').createSync(recursive: true);
    File('build/medium-layout/widget-bounds.json')
        .writeAsStringSync(jsonEncode(measurements));
  });
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
  ]) {
    for (var seed = 0; seed < 4; seed++) {
      for (final dark in [false, true]) {
        for (final language in ['en', 'tr']) {
          testWidgets(
            'medium actual outer bounds seed=$seed size=$size dark=$dark $language banner50',
            (tester) async {
              resetView(tester);
              final p = const MediumGenerator().generate(seed).puzzle!,
                  game = Game(const MediumGenerator().generate(seed).puzzle!);
              await showGame(
                tester,
                game,
                size,
                50,
                dark: dark,
                language: language,
              );
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
              final banner = tester.getRect(
                find.byKey(const ValueKey('qa-banner')),
              );
              expect(banner.height, 50);
              expect(square.width, square.height);
              expect(grid.left, greaterThanOrEqualTo(square.left - .001));
              expect(grid.right, lessThanOrEqualTo(square.right + .001));
              expect(grid.top, greaterThanOrEqualTo(square.top - .001));
              expect(grid.bottom, lessThanOrEqualTo(square.bottom + .001));
              expect(square.bottom, lessThanOrEqualTo(pool.top + .001));
              expect(pool.bottom, lessThanOrEqualTo(banner.top + .001));
              expect(controls.bottom, lessThanOrEqualTo(banner.top + .001));
              expect(banner.right, lessThanOrEqualTo(size.width));
              final first = tester.getRect(
                find.byKey(ValueKey('cell-${p.positions.keys.first}')),
              );
              for (final entry in p.positions.entries) {
                final finder = find.byKey(ValueKey('cell-${entry.key}'));
                final rect = tester.getRect(finder);
                expect(rect.width, closeTo(rect.height, .001));
                expect(rect.width, closeTo(first.width, .001));
                expect(
                  rect.left,
                  closeTo(grid.left + entry.value.$2 * (first.width + 1), .001),
                );
                expect(
                  rect.top,
                  closeTo(grid.top + entry.value.$1 * (first.height + 1), .001),
                );
                expect(rect.left, greaterThanOrEqualTo(square.left - .001));
                expect(rect.right, lessThanOrEqualTo(square.right + .001));
                expect(rect.top, greaterThanOrEqualTo(square.top - .001));
                expect(rect.bottom, lessThanOrEqualTo(square.bottom + .001));
                if (game.editable(entry.key)) {
                  await tester.tap(finder);
                  await tester.pump();
                  expect(tester.widget<Stone>(finder).selected, isTrue);
                }
              }
              for (final pos in p.symbols.keys) {
                final r = tester.getRect(
                  find.byKey(ValueKey('symbol-${pos.$1}-${pos.$2}')),
                );
                expect(r.left, greaterThanOrEqualTo(square.left - .001));
                expect(r.right, lessThanOrEqualTo(square.right + .001));
                expect(r.top, greaterThanOrEqualTo(square.top - .001));
                expect(r.bottom, lessThanOrEqualTo(square.bottom + .001));
              }
              measurements.add({
                'seed': seed,
                'family': p.family,
                'width': size.width,
                'height': size.height,
                'dark': dark,
                'language': language,
                'rows': p.rows,
                'columns': p.columns,
                'cell': first.width,
                'grid': [grid.left, grid.top, grid.right, grid.bottom],
                'square': [
                  square.left,
                  square.top,
                  square.right,
                  square.bottom,
                ],
                'pool': [pool.top, pool.bottom],
                'controls': [controls.top, controls.bottom],
                'banner': [banner.top, banner.bottom],
              });
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
  for (var seed = 0; seed < 4; seed++) {
    testWidgets(
      'medium fitted pointer feedback hover accept outer targets seed=$seed',
      (tester) async {
        resetView(tester);
        final p = const MediumGenerator().generate(seed).puzzle!,
            game = Game(const MediumGenerator().generate(seed).puzzle!);
        await showGame(tester, game, const Size(320, 568), 50, language: 'tr');
        final poolBefore = tester.getRect(find.byKey(const ValueKey('pool'))),
            controlsBefore = tester.getRect(
              find.byKey(const ValueKey('pool-controls')),
            ),
            bannerBefore = tester.getRect(
              find.byKey(const ValueKey('qa-banner')),
            );
        final keys = p.positions.keys.where(game.editable).toList()
          ..sort((a, b) {
            final pa = p.positions[a]!, pb = p.positions[b]!;
            return (pa.$1 + pa.$2).compareTo(pb.$1 + pb.$2);
          });
        final tile = p.tiles.first;
        for (final key in {keys.first, keys.last}) {
          if (game.placed.isNotEmpty) {
            await tester.tap(find.byKey(const ValueKey('undo')));
            await tester.pumpAndSettle();
          }
          final source = find.byKey(ValueKey('tile-${tile.id}')),
              target = find.byKey(ValueKey('cell-$key'));
          final from = tester.getCenter(source), to = tester.getCenter(target);
          final gesture = await tester.startGesture(from);
          await gesture.moveBy(const Offset(0, -12));
          await tester.pump();
          for (var i = 1; i <= 24; i++) {
            await gesture.moveTo(
              Offset.lerp(
                from + const Offset(0, -12),
                to - TileDrag.feedbackCenterOffset,
                i / 24,
              )!,
            );
            await tester.pump(const Duration(milliseconds: 16));
          }
          expect(
            (tester.getCenter(find.byKey(const ValueKey('drag-feedback'))) - to)
                .distance,
            lessThan(.1),
          );
          expect(tester.widget<Stone>(target).hover, isTrue);
          await gesture.up();
          await tester.pumpAndSettle();
          expect(game.placed[key], tile.id);
          expect(
            tester.getRect(find.byKey(const ValueKey('pool'))),
            poolBefore,
          );
          expect(
            tester.getRect(find.byKey(const ValueKey('pool-controls'))),
            controlsBefore,
          );
          expect(
            tester.getRect(find.byKey(const ValueKey('qa-banner'))),
            bannerBefore,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
