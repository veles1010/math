import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'board.dart';
import 'game.dart';
import 'store.dart';
import 'l10n/app_localizations.dart';

String formatTime(Duration duration) {
  final seconds = duration.inSeconds;
  return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
}

class GameScreen extends StatefulWidget {
  final Game game;
  final int number;
  final VoidCallback onChanged;
  final AppSettings? settings;
  final VoidCallback? onNext;
  final Future<void> Function()? onSettings;
  final ValueChanged<bool>? onTutorialDone;
  final String? title, nextLabel;
  final VoidCallback? onReplay;
  const GameScreen({
    super.key,
    required this.game,
    required this.number,
    required this.onChanged,
    this.settings,
    this.onNext,
    this.onSettings,
    this.onTutorialDone,
    this.title,
    this.nextLabel,
    this.onReplay,
  });
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final fallback = AppSettings();
  String? selected;
  bool paused = false,
      foreground = true,
      result = false,
      dragging = false,
      confetti = false;
  int tutorialStep = 0;
  Set<int> celebrating = {};
  Timer? ticker, pulseTimer, celebrationTimer;
  Game get game => widget.game;
  AppSettings get settings => widget.settings ?? fallback;
  bool get tutorial => widget.onTutorialDone != null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    result = game.complete;
    foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _syncClock();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (game.clock.running) {
        setState(() {});
        if (game.clock.elapsed.inSeconds % 5 == 0) widget.onChanged();
      }
    });
  }

  void _syncClock() {
    if (foreground && !paused && !result && !tutorial) {
      game.clock.start();
    } else {
      game.clock.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (!foreground) paused = true;
    _syncClock();
    widget.onChanged();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    game.clock.stop();
    ticker?.cancel();
    pulseTimer?.cancel();
    celebrationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool allowed(String tile, String? target) {
    if (!tutorial) return true;
    return tutorialStep == 0
        ? tile == 'tutorial-1' && target == 'b'
        : tile == 'tutorial-2' && target == 'c';
  }

  void transfer(String tile, String? target, {required bool fromDrag}) {
    if (paused || result || !allowed(tile, target)) return;
    if (tutorial &&
        ((tutorialStep == 0 && fromDrag) || (tutorialStep == 1 && !fromDrag))) {
      return;
    }
    final before = game.equationStates;
    if (!game.transfer(tile, target)) return;
    setState(() {
      selected = null;
      if (tutorial) tutorialStep++;
      celebrating = {
        for (var i = 0; i < before.length; i++)
          if (before[i] != true && game.equationStates[i] == true) i,
      };
    });
    pulseTimer?.cancel();
    pulseTimer = Timer(const Duration(milliseconds: 550), () {
      if (mounted) setState(() => celebrating = {});
    });
    if (game.complete) {
      if (tutorial) {
        widget.onTutorialDone!(true);
        return;
      }
      confetti =
          !game.resultPresented && !MediaQuery.disableAnimationsOf(context);
      if (confetti) {
        celebrationTimer = Timer(const Duration(milliseconds: 1150), () {
          if (mounted) setState(() => confetti = false);
        });
      }
      game.resultPresented = true;
      result = true;
      _syncClock();
    }
    widget.onChanged();
  }

  void _home() {
    game.clock.stop();
    widget.onChanged();
    Navigator.of(context).pop();
  }

  Future<void> _settings() async {
    setState(() => paused = true);
    _syncClock();
    widget.onChanged();
    await widget.onSettings?.call();
    if (mounted) {
      setState(() {}); // Explicit resume keeps time stopped behind settings.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          game.clock.stop();
          widget.onChanged();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            tutorial ? l.howToPlay : widget.title ?? l.level(widget.number),
          ),
          actions: [
            if (tutorial)
              TextButton(
                onPressed: () => widget.onTutorialDone!(false),
                child: Text(l.skip),
              )
            else ...[
              if (settings.timer)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Center(
                    child: Semantics(
                      label: l.elapsedTime,
                      child: Text(
                        formatTime(game.clock.elapsed),
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              if (!result)
                IconButton(
                  key: const ValueKey('pause'),
                  tooltip: paused ? l.resume : l.pause,
                  onPressed: () {
                    setState(() => paused = !paused);
                    _syncClock();
                    widget.onChanged();
                  },
                  icon: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                ),
              if (widget.onSettings != null)
                IconButton(
                  tooltip: l.settings,
                  onPressed: _settings,
                  icon: const Icon(Icons.settings_outlined),
                ),
            ],
          ],
        ),
        body: result
            ? ResultView(
                game: game,
                number: widget.number,
                settings: settings,
                celebrate: confetti,
                onHome: _home,
                onNext: widget.onNext,
                title: widget.title,
                nextLabel: widget.nextLabel,
                onReplay: widget.onReplay,
              )
            : SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    if (tutorial)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Column(
                          children: [
                            Text(
                              l.tutorialStep(tutorialStep + 1),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tutorialStep == 0
                                  ? l.tutorialTap
                                  : l.tutorialDrag,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, area) => SingleChildScrollView(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: tutorial ? 0 : area.maxHeight,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: tutorial ? 12 : 8,
                                    ),
                                    child: PuzzleBoard(
                                      fittingHeight: tutorial
                                          ? null
                                          : area.maxHeight - 16,
                                      game: game,
                                      selected: selected,
                                      large: settings.largeNumbers,
                                      slash: settings.slash,
                                      celebrating: celebrating,
                                      interactive: !paused,
                                      allow: allowed,
                                      onSelect: (id) => setState(
                                        () => selected = selected == id
                                            ? null
                                            : id,
                                      ),
                                      onTransfer: (id, target) =>
                                          transfer(id, target, fromDrag: true),
                                      onDragging: (value) {
                                        if (mounted) {
                                          setState(() => dragging = value);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (paused)
                            Positioned.fill(
                              child: ColoredBox(
                                color: Theme.of(context).scaffoldBackgroundColor
                                    .withValues(alpha: .96),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.pause_circle_outline,
                                        size: 48,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l.paused,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      ),
                                      const SizedBox(height: 20),
                                      FilledButton.icon(
                                        key: const ValueKey('resume'),
                                        onPressed: () {
                                          setState(() => paused = false);
                                          _syncClock();
                                        },
                                        icon: const Icon(Icons.play_arrow),
                                        label: Text(l.resume),
                                      ),
                                      TextButton(
                                        onPressed: _home,
                                        child: Text(l.home),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!paused)
                      AbsorbPointer(
                        absorbing: result,
                        child: PoolPanel(
                          game: game,
                          selected: selected,
                          large: settings.largeNumbers,
                          allow: allowed,
                          onDragging: (value) {
                            if (mounted) setState(() => dragging = value);
                          },
                          onTransfer: (tile, target) =>
                              transfer(tile, target, fromDrag: dragging),
                          onUndo: () {
                            setState(() {
                              game.undo();
                              if (tutorial) {
                                tutorialStep = game.value('b') == null ? 0 : 1;
                              }
                              selected = null;
                              celebrating = {};
                            });
                            widget.onChanged();
                          },
                          onReturn: () {
                            if (selected != null) {
                              transfer(
                                game.placed[selected]!,
                                null,
                                fromDrag: false,
                              );
                            }
                          },
                          onSort: () {
                            setState(game.sortPool);
                            widget.onChanged();
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ResultView extends StatelessWidget {
  final String? title, nextLabel;
  final VoidCallback? onReplay;
  final Game game;
  final int number;
  final AppSettings settings;
  final bool celebrate;
  final VoidCallback onHome;
  final VoidCallback? onNext;
  const ResultView({
    super.key,
    required this.game,
    required this.number,
    required this.settings,
    required this.celebrate,
    required this.onHome,
    this.onNext,
    this.title,
    this.nextLabel,
    this.onReplay,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.completed,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title ?? l.level(number),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${l.elapsedTime} · ${game.legacyTime && game.clock.elapsed == Duration.zero ? '—' : formatTime(game.clock.elapsed)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (game.legacyTime)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        l.legacyTimeNotice,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      key: const ValueKey('result-preview'),
                      width: game.puzzle.columns > 5 ? 320 : 220,
                      child: PuzzleBoard(
                        game: game,
                        interactive: false,
                        fittingHeight: 240,
                        slash: settings.slash,
                      ),
                    ),
                  ),
                  Text(
                    title == null && number == puzzles.length
                        ? l.allComplete
                        : l.wellDone,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (onNext != null &&
                      (title != null || number < puzzles.length))
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onNext,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(nextLabel ?? l.nextLevel),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (onReplay != null)
                    TextButton.icon(
                      onPressed: onReplay,
                      icon: const Icon(Icons.replay_rounded),
                      label: Text(l.replay),
                    ),
                  OutlinedButton.icon(
                    onPressed: onHome,
                    icon: const Icon(Icons.home_outlined),
                    label: Text(l.home),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (celebrate && !MediaQuery.disableAnimationsOf(context))
          const Positioned.fill(child: IgnorePointer(child: ConfettiBurst())),
      ],
    );
  }
}

class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});
  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => CustomPaint(
      painter: _ConfettiPainter(
        controller.value,
        Theme.of(context).colorScheme,
      ),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final ColorScheme scheme;
  _ConfettiPainter(this.progress, this.scheme);
  @override
  void paint(Canvas canvas, Size size) {
    if (progress >= 1) return;
    final colors = [scheme.primary, scheme.secondary, scheme.tertiary];
    for (var i = 0; i < 32; i++) {
      final random = math.Random(i);
      final x =
          size.width / 2 +
          (random.nextDouble() - .5) * size.width * progress * 1.8;
      final y =
          size.height * .22 +
          (random.nextDouble() - .7) * 240 * progress +
          340 * progress * progress;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 5, height: 9),
        Paint()..color = colors[i % 3].withValues(alpha: 1 - progress),
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
