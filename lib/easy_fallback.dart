import 'dart:convert';

import 'easy_fallback_data.dart';
import 'easy_fallback_v2_data.dart';
import 'generated_puzzle.dart';

List<GeneratedPuzzle> fallbackCatalog({int version = 2}) => [
  for (final raw in jsonDecode(
    version == 1 ? easyFallbackJson : easyFallbackV2Json,
  ) as List)
    GeneratedPuzzle.fromDefinition((raw as Map).cast<String, dynamic>()),
];
GeneratedPuzzle? pickFallback(String family, Set<String> recent) {
  return fallbackCatalog()
      .where((p) => p.family == family && !recent.contains(p.fingerprint))
      .firstOrNull;
}
