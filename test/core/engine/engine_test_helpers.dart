import 'dart:convert';
import 'dart:io';

import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/allergen_dictionary.dart';
import 'package:pode_comer/core/engine/allergen_engine.dart';
import 'package:pode_comer/core/engine/models.dart';
import 'package:pode_comer/core/engine/verdict_status.dart';

AllergenDictionary loadDictionary() => AllergenDictionary.fromJson(
  jsonDecode(File('assets/engine/allergen_dictionary.json').readAsStringSync())
      as Map<String, dynamic>,
);

final engine = AllergenEngine(loadDictionary());

// Família do estudo de caso.
const ana = Person(
  id: 'ana',
  name: 'Ana',
  allergies: [
    PersonAllergy(allergen: Allergen.peanut, severity: AllergySeverity.severe),
  ],
);
const carol = Person(
  id: 'carol',
  name: 'Carol',
  allergies: [PersonAllergy(allergen: Allergen.gluten)],
);
const enzo = Person(
  id: 'enzo',
  name: 'Enzo',
  allergies: [PersonAllergy(allergen: Allergen.lactose)],
);
const family = [ana, carol, enzo];

Person personWith(Allergen allergen, {bool severe = false}) => Person(
  id: allergen.code,
  name: allergen.code,
  allergies: [
    PersonAllergy(
      allergen: allergen,
      severity: severe ? AllergySeverity.severe : AllergySeverity.mild,
    ),
  ],
);

Product label(
  String ingredients, {
  Set<Allergen> contains = const {},
  Set<Allergen> traces = const {},
}) => Product(
  ingredientsText: ingredients,
  hasIngredients: true,
  allergensContains: contains,
  allergensTraces: traces,
);

/// Status de uma pessoa com uma única alergia para o texto dado.
VerdictStatus statusFor(
  String ingredients,
  Allergen allergen, {
  bool severe = false,
}) => engine.evaluate(label(ingredients), [
  personWith(allergen, severe: severe),
]).status;

PersonVerdict verdictOf(GroupVerdict group, Person person) =>
    group.people.singleWhere((v) => v.personId == person.id);
