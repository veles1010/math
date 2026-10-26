import 'package:flutter/material.dart';

import 'game.dart';
import 'game_screen.dart';
import 'store.dart';
import 'theme.dart';
import 'l10n/app_localizations.dart';
export 'game_screen.dart' show GameScreen;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MathPuzzleApp());
}

class MathPuzzleApp extends StatefulWidget {
  const MathPuzzleApp({super.key});
  @override
  State<MathPuzzleApp> createState() => _MathPuzzleAppState();
}

class _MathPuzzleAppState extends State<MathPuzzleApp> {
  final store = AppStore();
  bool tutorialOffered = false;
  final levelsKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    store.load();
  }

  Future<void> tutorial(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GameScreen(
          game: Game(const TutorialPuzzle()),
          number: 0,
          settings: store.settings,
          onChanged: () {},
          onTutorialDone: (complete) {
            store.settings.tutorial = complete ? 'completed' : 'skipped';
            store.save();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
    // Leaving with system back also counts as skipping, without touching levels.
    if (store.settings.tutorial.isEmpty) {
      store.settings.tutorial = 'skipped';
      store.save();
    }
  }

  Future<void> settings(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) =>
          SettingsScreen(store: store, onTutorial: () => tutorial(context)),
    ),
  );
  Future<void> openGame(
    BuildContext context,
    int index, {
    bool replace = false,
  }) async {
    final game = store.games[index];
    if (game.complete) {
      final l = AppLocalizations.of(context)!;
      final replay = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.level(index + 1),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(l.solved, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                  key: const ValueKey('replay'),
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(l.replay),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.viewResult),
                ),
              ],
            ),
          ),
        ),
      );
      if (!context.mounted || replay == null) return;
      if (replay) await store.replayLevel(index);
    }
    if (!context.mounted) return;
    if (!game.complete) {
      game.beginSession();
      store.save();
    }
    final route = MaterialPageRoute<void>(
      builder: (routeContext) => ListenableBuilder(
        listenable: store,
        builder: (_, _) => GameScreen(
          game: store.games[index],
          number: index + 1,
          settings: store.settings,
          onChanged: store.save,
          onSettings: () => settings(routeContext),
          onNext: index + 1 < store.games.length
              ? () => openGame(routeContext, index + 1, replace: true)
              : null,
        ),
      ),
    );
    if (replace) {
      await Navigator.of(context).pushReplacement(route);
    } else {
      await Navigator.of(context).push(route);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: store.settings.language == null
          ? null
          : Locale(store.settings.language!),
      theme: ThemePalette.warm.build(Brightness.light),
      darkTheme: ThemePalette.night.build(Brightness.dark),
      themeMode: store.settings.theme,
      home: Builder(
        builder: (context) {
          final l = AppLocalizations.of(context)!, games = store.games;
          if (store.ready && !tutorialOffered) {
            tutorialOffered = true;
            if (store.settings.tutorial.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) tutorial(context);
              });
            }
          }
          final completed = store.completedCount;
          final unfinished = games.indexWhere((g) => g.canContinue);
          final next = unfinished >= 0
              ? unfinished
              : games.indexWhere((g) => !g.completedOnce);
          final active = next < 0 ? 0 : next;
          return Scaffold(
            appBar: AppBar(
              title: Text(l.appTitle),
              actions: [
                IconButton(
                  key: const ValueKey('settings'),
                  tooltip: l.settings,
                  onPressed: store.ready ? () => settings(context) : null,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            body: !store.ready
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 24),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withValues(alpha: .5),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: Icon(
                                  Icons.calculate_outlined,
                                  size: 64,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l.tagline,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              l.completedCount(completed, games.length),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: completed / games.length,
                                minHeight: 7,
                              ),
                            ),
                            const SizedBox(height: 28),
                            FilledButton.icon(
                              key: const ValueKey('primary-play'),
                              onPressed: () {
                                if (next < 0) {
                                  Scrollable.ensureVisible(
                                    levelsKey.currentContext!,
                                    duration: Duration(
                                      milliseconds:
                                          MediaQuery.disableAnimationsOf(
                                            context,
                                          )
                                          ? 0
                                          : 250,
                                    ),
                                  );
                                } else {
                                  openGame(context, active);
                                }
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(
                                next < 0
                                    ? l.viewLevels
                                    : games[active].canContinue
                                    ? l.resume
                                    : l.play,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              l.chooseLevel,
                              key: levelsKey,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            for (var i = 0; i < games.length; i++)
                              Card(
                                elevation: 0,
                                child: ListTile(
                                  minVerticalPadding: 12,
                                  leading: Icon(
                                    games[i].completedOnce
                                        ? Icons.check_circle_outline
                                        : Icons.grid_view_rounded,
                                  ),
                                  title: Text(
                                    '${l.level(i + 1)} · ${games[i].canContinue
                                        ? l.resume
                                        : games[i].completedOnce
                                        ? l.solved
                                        : l.play}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                  ),
                                  onTap: () => openGame(context, i),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              store.saveError ? l.saveError : l.saved,
                              textAlign: TextAlign.center,
                            ),
                            if (store.recovered)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  l.recoveryNotice,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    ),
  );
}

class SettingsScreen extends StatelessWidget {
  final AppStore store;
  final Future<void> Function() onTutorial;
  const SettingsScreen({
    super.key,
    required this.store,
    required this.onTutorial,
  });
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final l = AppLocalizations.of(context)!, s = store.settings;
      return Scaffold(
        appBar: AppBar(title: Text(l.settings)),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  DropdownButtonFormField<ThemeMode>(
                    key: ValueKey(s.theme),
                    initialValue: s.theme,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l.appearance,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(l.system),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(l.light),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(l.dark),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        s.theme = v;
                        store.save();
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    key: ValueKey(s.language ?? 'system'),
                    initialValue: s.language ?? 'system',
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l.language,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'system', child: Text(l.system)),
                      DropdownMenuItem(value: 'en', child: Text(l.english)),
                      DropdownMenuItem(value: 'tr', child: Text(l.turkish)),
                    ],
                    onChanged: (v) {
                      s.language = v == 'system' ? null : v;
                      store.save();
                    },
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.showTimer),
                    value: s.timer,
                    onChanged: (v) {
                      s.timer = v;
                      store.save();
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.largeNumbers),
                    value: s.largeNumbers,
                    onChanged: (v) {
                      s.largeNumbers = v;
                      store.save();
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<bool>(
                    key: ValueKey(s.slash),
                    initialValue: s.slash,
                    decoration: InputDecoration(
                      labelText: l.divisionSymbol,
                      border: const OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: false, child: Text('÷')),
                      DropdownMenuItem(value: true, child: Text('/')),
                    ],
                    onChanged: (v) {
                      s.slash = v ?? false;
                      store.save();
                    },
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: onTutorial,
                    icon: const Icon(Icons.touch_app_outlined),
                    label: Text(l.howToPlay),
                  ),
                  const SizedBox(height: 12),
                  Text(l.instructions),
                  if (store.saveError) Text(l.saveError),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
