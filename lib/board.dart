import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game.dart';
import 'l10n/app_localizations.dart';

class PuzzleBoard extends StatelessWidget {
  final Game game;
  final String? selected;
  final bool large, slash, interactive;
  final Set<int> celebrating;
  final ValueChanged<String>? onSelect;
  final void Function(String, String?)? onTransfer;
  final ValueChanged<bool>? onDragging;
  final bool Function(String, String?)? allow;
  final double? fittingHeight;
  final double? cellExtent;
  const PuzzleBoard({
    super.key,
    required this.game,
    this.selected,
    this.large = false,
    this.slash = false,
    this.interactive = true,
    this.celebrating = const {},
    this.onSelect,
    this.onTransfer,
    this.onDragging,
    this.allow,
    this.fittingHeight,
    this.cellExtent,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      if (c.maxWidth <= 0 || c.maxHeight <= 0) return const SizedBox.shrink();
      final columns = game.puzzle.columns;
      if (c.maxWidth <= columns - 1 || c.maxHeight <= game.puzzle.rows - 1) {
        return const SizedBox.shrink();
      }
      final states = game.equationStates;
      final paths = [
        for (var i = 0; i < states.length; i++)
          game.puzzle.equationCoordinates(i),
      ];
      final fit = (c.maxWidth - (columns - 1)) / columns;
      final heightLimit = math.min(
        fittingHeight ?? double.infinity,
        c.maxHeight,
      );
      final heightFit = heightLimit.isFinite
          ? (heightLimit - (game.puzzle.rows - 1)) / game.puzzle.rows
          : 64.0;
      final size = cellExtent ?? math.min(64.0, math.min(fit, heightFit));
      final width = size * columns + (columns - 1);
      final grid = SizedBox(
        key: const ValueKey('board-grid'),
        width: width,
        height: size * game.puzzle.rows + (game.puzzle.rows - 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var row = 0; row < game.puzzle.rows; row++)
              Padding(
                padding: EdgeInsets.only(
                  bottom: row == game.puzzle.rows - 1 ? 0 : 1,
                ),
                child: Row(
                  children: [
                    for (var col = 0; col < columns; col++)
                      Padding(
                        padding: EdgeInsets.only(
                          right: col == columns - 1 ? 0 : 1,
                        ),
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: _cell(context, row, col, states, paths),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
      return Center(
        child: width <= c.maxWidth + .01
            ? grid
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: grid,
              ),
      );
    },
  );
  Widget _cell(
    BuildContext context,
    int row,
    int col,
    List<bool?> states,
    List<List<(int, int)>> paths,
  ) {
    final l = AppLocalizations.of(context)!;
    final position = (row, col);
    final id = game.puzzle.positions.entries
        .where((e) => e.value == position)
        .firstOrNull
        ?.key;
    final symbol = game.puzzle.symbols[position];
    if (id == null && symbol == null) return const SizedBox.shrink();
    final equations = [
      for (var i = 0; i < paths.length; i++)
        if (paths[i].contains(position)) i,
    ];
    final wrong = equations.any((i) => states[i] == false);
    final correct = equations.any((i) => states[i] == true);
    final pulse = equations.any(celebrating.contains);
    if (id == null) {
      return Stone(
        boardCell: true,
        key: ValueKey('symbol-$row-$col'),
        label: symbol == '÷' && slash ? '/' : symbol!,
        semantics: symbol!,
        operatorCell: true,
        wrong: wrong,
        correct: correct,
        pulse: pulse,
        large: large,
      );
    }
    final fixed = game.puzzle.fixed.containsKey(id),
        value = game.value(id),
        tileId = game.placed[id];
    Widget stone({bool hover = false}) => Stone(
      boardCell: true,
      key: ValueKey('cell-$id'),
      label: value?.toString() ?? '',
      semantics:
          '${l.cell(row * game.puzzle.columns + col + 1)}, ${value ?? l.empty}, ${fixed ? l.fixed : l.editable}${wrong ? ', ${l.incorrect}' : ''}${correct ? ', ${l.correct}' : ''}',
      selected: selected == id,
      hover: hover,
      fixed: fixed,
      empty: value == null,
      placed: tileId != null,
      wrong: wrong,
      correct: correct,
      pulse: pulse,
      large: large,
      onTap: interactive && !fixed ? () => onSelect?.call(id) : null,
    );
    if (!interactive || fixed) return stone();
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) =>
          game.canTransfer(d.data, id) && (allow?.call(d.data, id) ?? true),
      onAcceptWithDetails: (d) => onTransfer?.call(d.data, id),
      builder: (context, candidates, rejected) {
        final child = stone(hover: candidates.isNotEmpty);
        return tileId == null
            ? child
            : TileDrag(
                tileId: tileId,
                value: value!,
                large: large,
                onDragging: onDragging,
                child: child,
              );
      },
    );
  }
}

/// Fitted and playable by default; no minimum cell size overrides visibility.
class ReadableBoard extends StatelessWidget {
  final int rows, columns;
  final bool dragging;
  final Widget Function(double extent, bool playable) builder;
  const ReadableBoard({
    super.key,
    required this.rows,
    required this.columns,
    required this.dragging,
    required this.builder,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, area) {
      if (area.maxWidth <= columns - 1 || area.maxHeight <= rows - 1) {
        return const SizedBox.shrink();
      }
      final extent = math.min(
        64.0,
        math.min(
          (area.maxWidth - (columns - 1)) / columns,
          (area.maxHeight - (rows - 1)) / rows,
        ),
      );
      return builder(extent, true);
    },
  );
}

class TileDrag extends StatelessWidget {
  static const feedbackExtent = 60.0;
  static const feedbackCenterOffset = Offset(0, -48);
  final String tileId;
  final int value;
  final bool large;
  final Widget child;
  final ValueChanged<bool>? onDragging;
  const TileDrag({
    super.key,
    required this.tileId,
    required this.value,
    required this.child,
    this.large = false,
    this.onDragging,
  });
  @override
  Widget build(BuildContext context) => Draggable<String>(
    data: tileId,
    maxSimultaneousDrags: 1,
    // Flutter hit-tests pointer + feedbackOffset. Both the rendered center and
    // that hit-test point use this single offset; hover and acceptance agree.
    dragAnchorStrategy: pointerDragAnchorStrategy,
    feedbackOffset: feedbackCenterOffset,
    feedback: Transform.translate(
      offset:
          feedbackCenterOffset -
          const Offset(feedbackExtent / 2, feedbackExtent / 2),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: feedbackExtent,
          height: feedbackExtent,
          key: const ValueKey('drag-feedback'),
          child: Stone(
            label: '$value',
            semantics: '$value',
            large: large,
            selected: true,
          ),
        ),
      ),
    ),
    childWhenDragging: Opacity(opacity: .22, child: child),
    onDragStarted: () => onDragging?.call(true),
    onDragEnd: (_) => onDragging?.call(false),
    child: child,
  );
}

class PoolPanel extends StatelessWidget {
  final Game game;
  final String? selected;
  final bool large;
  final bool safeBottom;
  final double maxInventoryHeight;
  final void Function(String, String?) onTransfer;
  final VoidCallback onUndo, onReturn, onSort;
  final ValueChanged<bool> onDragging;
  final bool Function(String, String?)? allow;
  const PoolPanel({
    super.key,
    required this.game,
    this.selected,
    this.large = false,
    this.safeBottom = true,
    this.maxInventoryHeight = double.infinity,
    required this.onTransfer,
    required this.onUndo,
    required this.onReturn,
    required this.onSort,
    required this.onDragging,
    this.allow,
  });
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!, theme = Theme.of(context);
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) =>
          game.canTransfer(d.data, null) && (allow?.call(d.data, null) ?? true),
      onAcceptWithDetails: (d) => onTransfer(d.data, null),
      builder: (context, candidates, rejected) => Container(
        key: const ValueKey('pool'),
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          border: Border.all(
            color: candidates.isNotEmpty
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: safeBottom,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  if (c.maxWidth <= 0) return const SizedBox.shrink();
                  final columns = math.max(
                    1,
                    math.min(
                      game.poolOrder.length,
                      math.min(
                        math.max(1, ((c.maxWidth + 4) / 16).floor()),
                        game.poolOrder.length > 10
                            ? 7
                            : math.min(7, ((c.maxWidth + 4) / 44).floor()),
                      ),
                    ),
                  );
                  final extent = math.min(
                    52.0,
                    (c.maxWidth - (columns - 1) * 4) / columns,
                  );
                  final rows = (game.poolOrder.length / columns).ceil();
                  final tileHeight = math.min(48.0, extent + 2);
                  return SizedBox(
                    height: math.min(
                      rows * (tileHeight + 4),
                      maxInventoryHeight,
                    ),
                    child: SingleChildScrollView(
                      key: const ValueKey('pool-viewport'),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final id in game.poolOrder)
                            SizedBox(
                              key: ValueKey('slot-$id'),
                              width: extent,
                              height: tileHeight,
                              child: game.placed.containsValue(id)
                                  ? DecoratedBox(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              theme.colorScheme.outlineVariant,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    )
                                  : TileDrag(
                                      tileId: id,
                                      value: game.tile(id)!.value,
                                      large: large,
                                      onDragging: onDragging,
                                      child: Stone(
                                        key: ValueKey('tile-$id'),
                                        label: '${game.tile(id)!.value}',
                                        semantics: l.poolTile(
                                          game.tile(id)!.value,
                                        ),
                                        large: large,
                                        onTap:
                                            selected == null ||
                                                !(allow?.call(id, selected) ??
                                                    true)
                                            ? null
                                            : () => onTransfer(id, selected),
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Row(
                key: const ValueKey('pool-controls'),
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      key: const ValueKey('undo'),
                      onPressed: game.canUndo ? onUndo : null,
                      icon: const Icon(Icons.undo_rounded, size: 20),
                      label: Text(l.undo, maxLines: 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      key: const ValueKey('return'),
                      onPressed:
                          game.placed.containsKey(selected) &&
                              (allow?.call(game.placed[selected]!, null) ??
                                  true)
                          ? onReturn
                          : null,
                      icon: const Icon(Icons.keyboard_return_rounded, size: 20),
                      label: Text(l.returnTile, maxLines: 1),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('sort'),
                    tooltip: l.sort,
                    onPressed: onSort,
                    icon: const Icon(Icons.sort_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Stone extends StatelessWidget {
  final String label, semantics;
  final bool selected,
      hover,
      fixed,
      empty,
      placed,
      wrong,
      correct,
      pulse,
      large,
      operatorCell;
  final VoidCallback? onTap;
  final bool boardCell;
  const Stone({
    super.key,
    required this.label,
    required this.semantics,
    this.selected = false,
    this.hover = false,
    this.fixed = false,
    this.empty = false,
    this.placed = false,
    this.wrong = false,
    this.correct = false,
    this.pulse = false,
    this.large = false,
    this.operatorCell = false,
    this.onTap,
    this.boardCell = false,
  });
  Widget _compact(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final colors = Theme.of(context).colorScheme;
      final side = math.min(c.maxWidth, c.maxHeight);
      return Semantics(
        label: semantics,
        selected: selected,
        button: onTap != null,
        excludeSemantics: true,
        child: Material(
          color: hover
              ? colors.primaryContainer
              : pulse
              ? colors.secondaryContainer
              : empty
              ? colors.secondaryContainer.withValues(alpha: .35)
              : fixed
              ? colors.secondaryContainer.withValues(alpha: .6)
              : colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1),
            side: BorderSide(
              color: wrong
                  ? colors.error
                  : selected || hover
                  ? colors.primary
                  : colors.outlineVariant,
              width: selected || hover || wrong ? 1.8 : .65,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                if (!empty)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            key: const ValueKey('board-label'),
                            style: TextStyle(
                              fontSize: side * (large ? .76 : .64),
                              height: 1,
                              fontWeight: operatorCell
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: operatorCell
                                  ? colors.onSurface
                                  : colors.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (fixed)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: SizedBox(
                      width: side * .16,
                      height: 1,
                      child: ColoredBox(color: colors.onSurfaceVariant),
                    ),
                  ),
                if (placed && !wrong)
                  Positioned(
                    top: 1,
                    left: 1,
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (wrong)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.priority_high,
                      size: math.min(8, side * .3),
                      color: colors.error,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context), s = t.colorScheme;
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (boardCell) return _compact(context);
    return Semantics(
      label: semantics,
      selected: selected,
      button: onTap != null,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: pulse && !reduce ? 1.045 : 1,
        duration: Duration(milliseconds: reduce ? 0 : 180),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: empty
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .10),
                      offset: const Offset(0, 3),
                      blurRadius: 2,
                    ),
                  ],
          ),
          child: Material(
            color: hover
                ? s.primaryContainer
                : empty
                ? s.surface.withValues(alpha: .45)
                : fixed
                ? s.secondaryContainer.withValues(alpha: .5)
                : s.surface,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: Duration(milliseconds: reduce ? 0 : 140),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: wrong
                        ? s.error
                        : selected || hover
                        ? s.primary
                        : pulse
                        ? s.secondary
                        : s.outlineVariant,
                    width: wrong || selected || hover ? 2.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(large ? 2 : 4),
                        child: empty
                            ? const SizedBox.shrink()
                            : FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: large ? 32 : 26,
                                    fontWeight: operatorCell
                                        ? FontWeight.w500
                                        : FontWeight.w800,
                                    color: operatorCell
                                        ? s.onSurface
                                        : s.secondary,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (fixed)
                      Positioned(
                        top: 3,
                        right: 3,
                        child: Icon(
                          Icons.lock_outline,
                          size: 9,
                          color: s.onSurfaceVariant,
                        ),
                      ),
                    if (selected)
                      Positioned(
                        bottom: 3,
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: s.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    if (placed && !wrong)
                      Positioned(
                        top: 3,
                        left: 3,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: s.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (wrong)
                      Positioned(
                        top: 1,
                        right: 2,
                        child: Icon(
                          Icons.priority_high_rounded,
                          size: 12,
                          color: s.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
