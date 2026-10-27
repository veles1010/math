import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_puzzle/board.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/game_screen.dart';
import 'package:math_puzzle/easy_generator.dart';
import 'package:math_puzzle/l10n/app_localizations.dart';
import 'package:math_puzzle/store.dart';
import 'package:math_puzzle/theme.dart';

Future<void> showGame(
  WidgetTester tester,
  Game game,
  Size size,
  double banner, {
  bool dark = false,
  String language = 'en',
  bool tutorial = false,
  bool large = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  // Model gesture navigation and a status bar, rather than a zero-inset canvas.
  tester.view.padding = FakeViewPadding(top: 24, bottom: 24);
  await tester.pumpWidget(
    MaterialApp(
      theme: (dark ? ThemePalette.night : ThemePalette.warm).build(
        dark ? Brightness.dark : Brightness.light,
      ),
      locale: Locale(language),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => GameScreen(
          game: game,
          number: 1,
          onChanged: () {},
          qaBannerHeight: banner,
          settings: AppSettings()..largeNumbers = large,
          title: AppLocalizations.of(context)!.easyPuzzle,
          nextLabel: AppLocalizations.of(context)!.newEasyPuzzle,
          onNext: () {},
          onReplay: () {},
          onTutorialDone: tutorial ? (_) {} : null,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void resetView(WidgetTester tester) {
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
}

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
  ]) {
    for (final dark in [false, true]) {
      for (final language in ['en', 'tr']) {
        for (final banner in [50.0, 90.0]) {
          for (final seed in [0, 1]) {
            testWidgets(
              'banner bounds $size $dark $language $banner seed=$seed',
              (tester) async {
                resetView(tester);
                final p = const EasyGenerator().generate(seed).puzzle!;
                final game = Game(p);
                await showGame(
                  tester,
                  game,
                  size,
                  banner,
                  dark: dark,
                  language: language,
                );
                expect(tester.takeException(), isNull);
                if (find
                    .byKey(const ValueKey('board-zoom'))
                    .evaluate()
                    .isNotEmpty) {
                  await tester.tap(find.byKey(const ValueKey('board-zoom')));
                  await tester.pumpAndSettle();
                }
                final ad = tester.getRect(
                  find.byKey(const ValueKey('qa-banner')),
                );
                final pool = tester.getRect(find.byKey(const ValueKey('pool')));
                expect(ad.height, banner);
                expect(ad.bottom, lessThanOrEqualTo(size.height - 24));
                expect(pool.bottom, lessThanOrEqualTo(ad.top - 8));
                for (final key in ['undo', 'return', 'sort']) {
                  final r = tester.getRect(find.byKey(ValueKey(key)));
                  expect(r.top, greaterThanOrEqualTo(pool.top));
                  expect(r.bottom, lessThanOrEqualTo(pool.bottom));
                  expect(r.height, greaterThanOrEqualTo(48));
                }
                final board = find.byType(PuzzleBoard);
                final visible = tester.getRect(
                  find.byKey(const ValueKey('board-square')),
                );
                expect(visible.width, closeTo(visible.height, .01));
                expect(visible.bottom, lessThanOrEqualTo(pool.top));
                expect(
                  visible.top,
                  greaterThanOrEqualTo(
                    tester.getRect(find.byType(AppBar)).bottom,
                  ),
                );
                for (final key in p.positions.keys) {
                  final r = tester.getRect(find.byKey(ValueKey('cell-$key')));
                  expect(r.left, greaterThanOrEqualTo(0));
                  expect(r.right, lessThanOrEqualTo(size.width));
                  expect(r.width, greaterThan(0));
                  expect(r.top, greaterThanOrEqualTo(visible.top - .01));
                  expect(r.bottom, lessThanOrEqualTo(visible.bottom + .01));
                }
                expect(
                  find.descendant(of: board, matching: find.byType(Scrollable)),
                  findsNothing,
                );
                // Complete using the model to inspect the same screen's result layout.
                final tiles = p.tiles.toList();
                for (final key in p.positions.keys.where(
                  (k) => !p.clues.contains(k),
                )) {
                  final tile = tiles.firstWhere(
                    (t) => t.value == p.solution[key],
                  );
                  tiles.remove(tile);
                  game.transfer(tile.id, key);
                }
                await tester.pumpWidget(const SizedBox());
                await showGame(
                  tester,
                  game,
                  size,
                  banner,
                  dark: dark,
                  language: language,
                );
                expect(tester.takeException(), isNull);
                final actions = tester.getRect(
                  find.byKey(const ValueKey('result-actions')),
                );
                expect(actions.bottom, lessThanOrEqualTo(ad.top - 8));
                expect(actions.top, greaterThan(24));
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
              },
            );
          }
        }
      }
    }
  }
  testWidgets(
    'banner resize preserves selected cell, clock, history and pointer targeting',
    (tester) async {
      resetView(tester);
      final p = const EasyGenerator().generate(1).puzzle!;
      final game = Game(p)..beginSession();
      final key = p.positions.keys.firstWhere((k) => !p.clues.contains(k));
      await showGame(tester, game, const Size(390, 844), 50);
      await tester.tap(find.byKey(ValueKey('cell-$key')));
      await tester.pump();
      final before = game.clock.elapsed;
      await showGame(tester, game, const Size(390, 844), 90);
      expect(
        tester.widget<Stone>(find.byKey(ValueKey('cell-$key'))).selected,
        isTrue,
      );
      expect(game.clock.elapsed, greaterThanOrEqualTo(before));
      final tile = p.tiles.firstWhere((t) => t.value == p.solution[key]);
      final origin = tester.getCenter(find.byKey(ValueKey('tile-${tile.id}')));
      final target = tester.getCenter(find.byKey(ValueKey('cell-$key')));
      final gesture = await tester.startGesture(origin);
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump();
      for (var i = 1; i <= 16; i++) {
        await gesture.moveTo(
          Offset.lerp(
            origin + const Offset(0, -20),
            target - TileDrag.feedbackCenterOffset,
            i / 16,
          )!,
        );
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(
        (tester.getCenter(find.byKey(const ValueKey('drag-feedback'))) - target)
            .distance,
        lessThan(.1),
      );
      expect(game.placed, isEmpty);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(game.placed[key], tile.id);
      await showGame(tester, game, const Size(390, 844), 50);
      expect(game.placed[key], tile.id);
      expect(game.canUndo, isTrue);
      game.undo();
      expect(game.placed, isEmpty);
    },
  );
  testWidgets('tutorial never reserves or displays a banner', (tester) async {
    resetView(tester);
    await showGame(
      tester,
      Game(const TutorialPuzzle()),
      const Size(320, 568),
      90,
      tutorial: true,
    );
    expect(find.byKey(const ValueKey('qa-banner')), findsNothing);
  });
}
