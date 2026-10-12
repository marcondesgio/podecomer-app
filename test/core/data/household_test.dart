import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/household.dart';

import '../engine/engine_test_helpers.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [householdProvider.overrideWith((ref) async => family)],
    );
    addTearDown(container.dispose);
  });

  Future<List<String>> selected() async {
    await container.read(householdProvider.future);
    return [
      for (final p in container.read(selectedPeopleProvider).value!) p.name,
    ];
  }

  test('todos selecionados por padrão', () async {
    expect(await selected(), ['Ana', 'Carol', 'Enzo']);
  });

  test('tirar e devolver pessoas', () async {
    final notifier = container.read(excludedPeopleProvider.notifier);
    expect(notifier.toggle('carol', family), isTrue);
    expect(await selected(), ['Ana', 'Enzo']);
    expect(notifier.toggle('carol', family), isTrue);
    expect(await selected(), ['Ana', 'Carol', 'Enzo']);
  });

  test('nunca deixa o grupo vazio', () async {
    final notifier = container.read(excludedPeopleProvider.notifier);
    notifier.toggle('ana', family);
    notifier.toggle('carol', family);
    expect(notifier.toggle('enzo', family), isFalse);
    expect(await selected(), ['Enzo']);
  });
}
