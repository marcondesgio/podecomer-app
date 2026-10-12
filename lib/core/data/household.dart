import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/models.dart';
import 'account_providers.dart';

/// Titular + membros do grupo, no formato do motor.
final householdProvider = FutureProvider<List<Person>>((ref) async {
  final profile = await ref.watch(myProfileProvider.future);
  final members = await ref.watch(groupMembersProvider.future);
  return [
    Person(id: profile.id, name: profile.name, allergies: profile.allergies),
    for (final m in members)
      Person(id: m.id, name: m.name, allergies: m.allergies),
  ];
});

/// "Para quem?": quem ficou de fora. Guardar os excluídos faz membros novos
/// entrarem selecionados.
final excludedPeopleProvider = NotifierProvider<ExcludedPeople, Set<String>>(
  ExcludedPeople.new,
);

class ExcludedPeople extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Alterna [personId]; nunca deixa o grupo vazio.
  /// Devolve `false` se recusou (era a última pessoa selecionada).
  bool toggle(String personId, List<Person> household) {
    if (state.contains(personId)) {
      state = {...state}..remove(personId);
      return true;
    }
    final selected = household.where((p) => !state.contains(p.id)).length;
    if (selected <= 1) return false;
    state = {...state, personId};
    return true;
  }
}

/// Selecionados = grupo menos os excluídos. Se ninguém sobrar (todos os
/// selecionados saíram do grupo), vale o grupo todo.
List<Person> selectPeople(List<Person> household, Set<String> excluded) {
  final selected = [
    for (final p in household)
      if (!excluded.contains(p.id)) p,
  ];
  return selected.isEmpty ? household : selected;
}

/// Pessoas para quem o produto está sendo verificado.
///
/// Derivado de forma síncrona: mudar a seleção nunca passa por um estado
/// "recarregando" com a seleção antiga (que daria um veredito para as
/// pessoas erradas).
final selectedPeopleProvider = Provider<AsyncValue<List<Person>>>((ref) {
  final excluded = ref.watch(excludedPeopleProvider);
  return ref
      .watch(householdProvider)
      .whenData((household) => selectPeople(household, excluded));
});
