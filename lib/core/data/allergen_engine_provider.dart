import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/allergen_dictionary.dart';
import '../engine/allergen_engine.dart';

const allergenDictionaryAsset = 'assets/engine/allergen_dictionary.json';

/// Motor de alergênicos com o dicionário carregado dos assets.
final allergenEngineProvider = FutureProvider<AllergenEngine>((ref) async {
  // O provider já guarda o motor; o cache do bundle só duplicaria a string.
  final raw = await rootBundle.loadString(
    allergenDictionaryAsset,
    cache: false,
  );
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return AllergenEngine(AllergenDictionary.fromJson(json));
});
