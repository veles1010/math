import 'dart:convert';

import 'generated_puzzle.dart';
import 'medium_fallback_data.dart';

List<GeneratedPuzzle> mediumFallbackCatalog() => [
  for (final data in jsonDecode(mediumFallbackJson) as List)
    GeneratedPuzzle.fromDefinition((data as Map).cast<String, dynamic>()),
];
GeneratedPuzzle? pickMediumFallback(String family, Set<String> recent) =>
    mediumFallbackCatalog()
        .where((p) => p.family == family && !recent.contains(p.fingerprint))
        .firstOrNull;
