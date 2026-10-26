import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:math_puzzle/main.dart';
import 'package:math_puzzle/game.dart';
import 'package:math_puzzle/l10n/app_localizations.dart';
import 'package:math_puzzle/theme.dart';

void main() {
  for (final locale in ['en', 'tr']) {
    for (final dark in [false, true]) {
      testWidgets(
        'small phone $locale dark=$dark, large text and tile actions',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final game = Game(puzzles.first);
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: (dark ? ThemePalette.night : ThemePalette.warm).build(
                dark ? Brightness.dark : Brightness.light,
              ),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(1.5)),
                child: child!,
              ),
              home: GameScreen(game: game, number: 1, onChanged: () {}),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.ensureVisible(find.byKey(const ValueKey('cell-b')));
          await tester.tap(find.byKey(const ValueKey('cell-b')));
          await tester.pump();
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('tile-one-1')),
            120,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.ensureVisible(find.byKey(const ValueKey('tile-one-1')));
          await tester.tap(find.byKey(const ValueKey('tile-one-1')));
          await tester.pumpAndSettle();
          expect(game.value('b'), 4);
          final undo = find.widgetWithText(
            OutlinedButton,
            locale == 'en' ? 'Undo' : 'Geri al',
          );
          await tester.ensureVisible(undo);
          await tester.tap(undo);
          await tester.pumpAndSettle();
          expect(game.value('b'), isNull);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  testWidgets('home loads stored theme and progress', (tester) async {
    SharedPreferences.setMockInitialValues({
      'appearance': 'dark',
      'settings-v2': '{"tutorial":"skipped"}',
      'game-one': '{"placed":{"b":"one-1"},"history":[{}]}',
    });
    await tester.pumpWidget(const MathPuzzleApp());
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    await tester.ensureVisible(find.textContaining('1 ·'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('1 ·'));
    await tester.pumpAndSettle();
    final screen = tester.widget<GameScreen>(find.byType(GameScreen));
    expect(screen.game.value('b'), 4);
    expect(screen.game.canUndo, isTrue);
    expect(tester.takeException(), isNull);
  });
}
