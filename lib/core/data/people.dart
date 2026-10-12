import '../engine/allergen.dart';
import '../engine/models.dart';

/// `public.sex_type`.
enum Sex {
  male('masculino'),
  female('feminino'),
  preferNotToSay('nao_informar');

  const Sex(this.code);

  final String code;

  static Sex? fromCode(String? code) {
    for (final sex in values) {
      if (sex.code == code) return sex;
    }
    return null;
  }
}

/// `public.plan_type`.
enum Plan {
  free('free'),
  family('familia');

  const Plan(this.code);

  final String code;

  /// Máximo de membros além do titular; `null` = ilimitado.
  int? get memberLimit => this == free ? 1 : null;

  bool allowsAnotherMember(int currentMembers) =>
      memberLimit == null || currentMembers < memberLimit!;

  static Plan fromCode(String? code) => code == family.code ? family : free;
}

/// Lançada quando o trigger do plano free recusa um novo membro.
class FreeMemberLimitReached implements Exception {
  const FreeMemberLimitReached();
}

/// Formato esperado pelas RPCs `set_person_allergens` / `save_group_member`.
List<Map<String, String>> allergiesToJson(
  Iterable<PersonAllergy> allergies,
) => [
  for (final allergy in allergies)
    {'allergen_code': allergy.allergen.code, 'severity': allergy.severity.code},
];

/// Linhas de `person_allergens` (ordenadas como `Allergen.values`).
List<PersonAllergy> allergiesFromRows(Iterable<Map<String, dynamic>> rows) {
  final allergies = [
    for (final row in rows)
      if (Allergen.fromCode(row['allergen_code'] as String)
          case final allergen?)
        PersonAllergy(
          allergen: allergen,
          severity:
              AllergySeverity.fromCode(row['severity'] as String? ?? '') ??
              AllergySeverity.mild,
        ),
  ];
  allergies.sort((a, b) => a.allergen.index.compareTo(b.allergen.index));
  return allergies;
}

/// `date` do Postgres (`yyyy-MM-dd`).
String? dateToDb(DateTime? date) => date == null
    ? null
    : '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';

DateTime? dateFromDb(Object? value) =>
    value is String ? DateTime.parse(value) : null;

/// Idade completa em anos.
int ageInYears(DateTime birthDate, DateTime today) {
  var age = today.year - birthDate.year;
  final hadBirthday =
      today.month > birthDate.month ||
      (today.month == birthDate.month && today.day >= birthDate.day);
  if (!hadBirthday) age--;
  return age < 0 ? 0 : age;
}
