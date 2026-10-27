import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

/// A measured banner's own widget determines its height. Safe-area padding and
/// the separator belong to this slot, never to the game board or tile inventory.
class BannerArea extends StatelessWidget {
  final Widget? banner;
  const BannerArea({super.key, this.banner});

  factory BannerArea.qa({Key? key, double? height}) {
    const configured = int.fromEnvironment('QA_BANNER_HEIGHT', defaultValue: 0);
    return BannerArea(
      key: key,
      banner: kDebugMode && (height ?? configured) > 0
          ? _Placeholder(height: height ?? configured.toDouble())
          : null,
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: banner == null
        ? const SizedBox.shrink()
        : DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: banner!,
            ),
          ),
  );
}

class _Placeholder extends StatelessWidget {
  final double height;
  const _Placeholder({required this.height});
  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('qa-banner'),
    height: height,
    width: double.infinity,
    child: IgnorePointer(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Center(child: Text(AppLocalizations.of(context)!.qaBanner)),
      ),
    ),
  );
}
