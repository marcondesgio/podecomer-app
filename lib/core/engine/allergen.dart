/// Alergênicos do MVP. [code] é o mesmo da tabela `allergens` no Supabase
/// e das chaves de `assets/engine/allergen_dictionary.json`.
enum Allergen {
  peanut('amendoim'),
  milk('leite_aplv'),
  lactose('lactose'),
  gluten('gluten'),
  wheat('trigo'),
  egg('ovo'),
  soy('soja'),
  fish('peixe'),
  crustaceans('crustaceos'),
  treeNuts('castanhas'),
  sesame('gergelim'),
  sulfites('sulfitos');

  const Allergen(this.code);

  final String code;

  static Allergen? fromCode(String code) {
    for (final allergen in values) {
      if (allergen.code == code) return allergen;
    }
    return null;
  }
}

/// Gravidade da alergia de uma pessoa (`person_allergens.severity`).
enum AllergySeverity {
  mild('leve'),

  /// Grave / anafilaxia: "pode conter" vira NÃO CONSUMIR.
  severe('grave');

  const AllergySeverity(this.code);

  final String code;

  static AllergySeverity? fromCode(String code) {
    for (final severity in values) {
      if (severity.code == code) return severity;
    }
    return null;
  }
}
