import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'game.dart';

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
    final values = <String, String>{
      'appearance': settings.theme.name,
      'settings-v2': jsonEncode(settings.toJson()),
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
