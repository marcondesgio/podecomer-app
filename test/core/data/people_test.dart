import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/people.dart';
import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/models.dart';

void main() {
  test('idade completa considera o aniversário', () {
    final birth = DateTime(2018, 10, 9);
    expect(ageInYears(birth, DateTime(2026, 10, 8)), 7);
    expect(ageInYears(birth, DateTime(2026, 10, 9)), 8);
    expect(ageInYears(DateTime(2026, 5), DateTime(2026, 10)), 0);
  });

  test('alergias vão para o formato das RPCs', () {
    expect(
      allergiesToJson(const [
        PersonAllergy(
          allergen: Allergen.milk,
          severity: AllergySeverity.severe,
        ),
      ]),
      [
        {'allergen_code': 'leite_aplv', 'severity': 'grave'},
      ],
    );
  });

  test('linhas do banco viram alergias ordenadas; códigos estranhos somem', () {
    expect(
      allergiesFromRows([
        {'allergen_code': 'ovo', 'severity': 'leve'},
        {'allergen_code': 'mostarda', 'severity': 'leve'},
        {'allergen_code': 'amendoim', 'severity': 'grave'},
      ]),
      const [
        PersonAllergy(
          allergen: Allergen.peanut,
          severity: AllergySeverity.severe,
        ),
        PersonAllergy(allergen: Allergen.egg),
      ],
    );
  });

  test('plano free permite 1 membro; Família, ilimitado', () {
    expect(Plan.free.allowsAnotherMember(0), isTrue);
    expect(Plan.free.allowsAnotherMember(1), isFalse);
    expect(Plan.family.allowsAnotherMember(50), isTrue);
    expect(Plan.fromCode('familia'), Plan.family);
    expect(Plan.fromCode(null), Plan.free);
  });

  test('datas no formato do Postgres', () {
    expect(dateToDb(DateTime(2018, 5, 1)), '2018-05-01');
    expect(dateFromDb('2018-05-01'), DateTime(2018, 5));
    expect(dateToDb(null), isNull);
  });
}
