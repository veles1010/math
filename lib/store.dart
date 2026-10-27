import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game.dart';
import 'generated_puzzle.dart';
import 'easy_generator.dart';
import 'medium_generator.dart';

class AppSettings {
  ThemeMode theme = ThemeMode.system;
  String? language;
  bool timer = true, largeNumbers = false, slash = false;
  String tutorial = '';
  Map<String, dynamic> toJson() => {
    'language': language,
    'timer': timer,
    'largeNumbers': largeNumbers,
    'slash': slash,
    'tutorial': tutorial,
  };
  void restore(Map<String, dynamic> data) {
    language = ['en', 'tr'].contains(data['language'])
        ? data['language'] as String
        : null;
    timer = data['timer'] is bool ? data['timer'] as bool : true;
    largeNumbers = data['largeNumbers'] == true;
    slash = data['slash'] == true;
    tutorial = ['completed', 'skipped'].contains(data['tutorial'])
        ? data['tutorial'] as String
        : '';
  }
}

class AppStore extends ChangeNotifier {
  final games = puzzles.map(Game.new).toList();
  final settings = AppSettings();
  Game? generatedGame;
  final Set<String> generatedCompletedIds = {};
  final Set<String> mediumCompletedIds = {};
  String? mediumLastFamily;
  int get mediumCompletedCount => mediumCompletedIds.length;
  final List<String> recentGenerated = [];
  final Map<String, int> familyCounts = {};
  String? lastFamily;
  bool lastFallback = false;
  int seedCounter = DateTime.now().microsecondsSinceEpoch % 500000000;
  int get generatedCompletedCount => generatedCompletedIds.length;
  Future<void> replayGenerated() {
    final old = generatedGame;
    if (old == null) return Future.value();
    _countGenerated();
    generatedGame = Game(old.puzzle)
      ..restore(old.toJson())
      ..replay();
    return save();
  }

  int reserveEasySeed() {
    final choices = EasyGenerator.families
        .where((f) => f != lastFamily)
        .toList();
    choices.sort((a, b) {
      final score = (familyCounts[a] ?? 0).compareTo(familyCounts[b] ?? 0);
      return score == 0
          ? EasyGenerator.families
                .indexOf(a)
                .compareTo(EasyGenerator.families.indexOf(b))
          : score;
    });
    final family = EasyGenerator.families.indexOf(choices.first);
    final seed = seedCounter * 4 + family;
    seedCounter = (seedCounter + 1) % 500000000;
    return seed;
  }

  int reserveMediumSeed() {
    final choices = MediumGenerator.families
        .where((f) => f != mediumLastFamily)
        .toList();
    choices.sort((a, b) {
      final score = (familyCounts[a] ?? 0).compareTo(familyCounts[b] ?? 0);
      return score == 0
          ? MediumGenerator.families
                .indexOf(a)
                .compareTo(MediumGenerator.families.indexOf(b))
          : score;
    });
    final seed =
        seedCounter * 4 + MediumGenerator.families.indexOf(choices.first);
    seedCounter = (seedCounter + 1) % 500000000;
    return seed;
  }

  void _countGenerated() {
    if (generatedGame?.completedOnce == true) {
      final p = generatedGame!.puzzle as GeneratedPuzzle;
      (p.difficulty == 'medium' ? mediumCompletedIds : generatedCompletedIds)
          .add(p.id);
    }
  }

  Future<void> installGenerated(
    GeneratedPuzzle puzzle, {
    required bool fallback,
  }) {
    _countGenerated();
    generatedGame = Game(puzzle)..beginSession();
    if (puzzle.difficulty == 'medium') {
      mediumLastFamily = puzzle.family;
    } else {
      lastFamily = puzzle.family;
    }
    familyCounts.update(puzzle.family, (n) => n + 1, ifAbsent: () => 1);
    recentGenerated.add(puzzle.fingerprint);
    if (recentGenerated.length > 20) recentGenerated.removeAt(0);
    lastFallback = fallback;
    return save();
  }

  Map<String, dynamic> _easyData() => {
    'definition': (generatedGame?.puzzle as GeneratedPuzzle?)?.toDefinition(),
    'difficulty': (generatedGame?.puzzle as GeneratedPuzzle?)?.difficulty,
    'mediumCompletedIds': mediumCompletedIds.toList(),
    'mediumLastFamily': mediumLastFamily,
    'session': generatedGame?.toJson(),
    'completedIds': generatedCompletedIds.toList(),
    'recent': recentGenerated,
    'familyCounts': familyCounts,
    'lastFamily': lastFamily,
    'seedCounter': seedCounter,
    'fallback': lastFallback,
  };
  int get completedCount => games.where((g) => g.completedOnce).length;
  Future<void> replayLevel(int index) {
    games[index].replay();
    return save();
  }

  SharedPreferences? _prefs;
  bool ready = false, saveError = false, recovered = false;
  Future<void> _pending = Future.value();
  final Set<String> _protectedKeys = {};
  bool _loadFailed = false;
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      settings.theme =
          ThemeMode.values
              .where((m) => m.name == _prefs!.getString('appearance'))
              .firstOrNull ??
          ThemeMode.system;
      final rawSettings = _prefs!.getString('settings-v2');
      if (rawSettings != null) {
        try {
          settings.restore(jsonDecode(rawSettings) as Map<String, dynamic>);
        } catch (_) {
          await _backup('settings-v2', rawSettings);
        }
      }
      for (final game in games) {
        final key = 'game-${game.puzzle.id}',
            raw = _prefs!.getString('game-${game.puzzle.id}');
        if (raw == null) continue;
        try {
          if (!game.restore(jsonDecode(raw) as Map<String, dynamic>)) {
            await _backup(key, raw);
          }
        } catch (_) {
          await _backup(key, raw);
        }
      }
      final easyRaw = _prefs!.getString('easy-session-v1');
      if (easyRaw != null) {
        try {
          final data = jsonDecode(easyRaw) as Map<String, dynamic>;
          Game? loaded;
          if (data['definition'] != null) {
            final puzzle = GeneratedPuzzle.fromDefinition(
              (data['definition'] as Map).cast<String, dynamic>(),
            );
            if (data['difficulty'] != null &&
                data['difficulty'] != puzzle.difficulty) {
              throw const FormatException('difficulty mismatch');
            }
            loaded = Game(puzzle);
            if (!loaded.restore(
              (data['session'] as Map).cast<String, dynamic>(),
            )) {
              throw const FormatException('session');
            }
          }
          final ids = (data['completedIds'] as List).cast<String>().toSet();
          final recent = (data['recent'] as List).cast<String>();
          final counts = (data['familyCounts'] as Map).cast<String, int>();
          final counter = data['seedCounter'] as int;
          if (recent.length > 20 ||
              counter < 0 ||
              counter >= 500000000 ||
              counts.values.any((n) => n < 0)) {
            throw const FormatException('history');
          }
          generatedGame = loaded;
          generatedCompletedIds.addAll(ids);
          mediumCompletedIds.addAll(
            (data['mediumCompletedIds'] as List? ?? []).cast<String>(),
          );
          mediumLastFamily = data['mediumLastFamily'] as String?;
          recentGenerated.addAll(recent);
          familyCounts.addAll(counts);
          seedCounter = counter;
          lastFamily = data['lastFamily'] as String?;
          lastFallback = data['fallback'] == true;
          _countGenerated();
        } catch (_) {
          await _backup('easy-session-v1', easyRaw);
        }
      }
    } catch (_) {
      saveError = true;
      _loadFailed = true;
    }
    ready = true;
    notifyListeners();
  }

  Future<void> _backup(String key, String raw) async {
    // Keep the original bytes before any future write, and tell the player.
    _protectedKeys.add(key);
    recovered = true;
    try {
      var backup = 'recovery-$key';
      var suffix = 1;
      while (_prefs!.containsKey(backup) && _prefs!.getString(backup) != raw) {
        backup = 'recovery-$key-${++suffix}';
      }
      if (!_prefs!.containsKey(backup) &&
          !await _prefs!.setString(backup, raw)) {
        saveError = true;
        return;
      }
      _protectedKeys.remove(key);
    } catch (_) {
      saveError = true;
    }
  }

  Future<void> save() {
    if (_loadFailed) return Future.value();
    _countGenerated();
    final values = <String, String>{
      'appearance': settings.theme.name,
      'settings-v2': jsonEncode(settings.toJson()),
      'easy-session-v1': jsonEncode(_easyData()),
      for (final game in games)
        'game-${game.puzzle.id}': jsonEncode(game.toJson()),
    };
    _pending = _pending.then((_) async {
      try {
        final prefs = _prefs ??= await SharedPreferences.getInstance();
        var ok = true;
        for (final e in values.entries) {
          if (_protectedKeys.contains(e.key)) {
            ok = false;
            continue;
          }
          ok = await prefs.setString(e.key, e.value) && ok;
        }
        saveError = !ok;
      } catch (_) {
        saveError = true;
      }
      notifyListeners();
    });
    notifyListeners();
    return _pending;
  }
}
