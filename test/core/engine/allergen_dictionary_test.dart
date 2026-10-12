import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/allergen_dictionary.dart';
import 'package:pode_comer/core/engine/text_normalizer.dart';

import 'engine_test_helpers.dart';

void main() {
  final dictionary = loadDictionary();

  test('dicionário cobre os 12 alergênicos com termos', () {
    expect(dictionary.entries.keys.toSet(), Allergen.values.toSet());
    for (final entry in dictionary.entries.values) {
      expect(entry.terms, isNotEmpty, reason: entry.allergen.code);
    }
  });

  test('dicionário incompleto é rejeitado', () {
    expect(
      () => AllergenDictionary.fromJson({
        'allergens': {
          'amendoim': {
            'name_pt': 'Amendoim',
            'terms': ['amendoim'],
          },
        },
      }),
      throwsFormatException,
    );
  });

  test('mapeia tags do Open Food Facts', () {
    expect(
      dictionary.allergensFromOffTags([
        'en:milk',
        'en:gluten',
        'en:peanuts',
        'en:eggs',
        'en:soybeans',
        'en:fish',
        'en:crustaceans',
        'en:nuts',
        'en:sesame-seeds',
        'en:sulphur-dioxide-and-sulphites',
      ]),
      {
        Allergen.milk,
        Allergen.gluten,
        Allergen.peanut,
        Allergen.egg,
        Allergen.soy,
        Allergen.fish,
        Allergen.crustaceans,
        Allergen.treeNuts,
        Allergen.sesame,
        Allergen.sulfites,
      },
    );
  });

  test('tags desconhecidas do Open Food Facts são ignoradas', () {
    expect(
      dictionary.allergensFromOffTags(['en:mustard', 'en:celery']),
      isEmpty,
    );
  });

  test('declarar trigo implica glúten; leite implica lactose', () {
    expect(dictionary.expandDeclared({Allergen.wheat, Allergen.milk}), {
      Allergen.wheat,
      Allergen.gluten,
      Allergen.milk,
      Allergen.lactose,
    });
  });

  test('normalização: minúsculas, sem acentos e sem pontuação', () {
    expect(
      normalizeText('PÃO de Açúcar,, com CASEÍNA!! (Ômega-3)'),
      'pao de acucar com caseina omega 3',
    );
  });

  test('o motor é Dart puro (não importa Flutter)', () {
    final files = Directory(
      'lib/core/engine',
    ).listSync().whereType<File>().where((f) => f.path.endsWith('.dart'));
    for (final file in files) {
      expect(
        file.readAsStringSync(),
        isNot(contains('package:flutter')),
        reason: file.path,
      );
    }
  });
}
