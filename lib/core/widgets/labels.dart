import '../../l10n/app_localizations.dart';
import '../data/people.dart';
import '../engine/allergen.dart';

extension DomainLabels on AppLocalizations {
  String allergen(Allergen allergen) => switch (allergen) {
    Allergen.peanut => allergenPeanut,
    Allergen.milk => allergenMilk,
    Allergen.lactose => allergenLactose,
    Allergen.gluten => allergenGluten,
    Allergen.wheat => allergenWheat,
    Allergen.egg => allergenEgg,
    Allergen.soy => allergenSoy,
    Allergen.fish => allergenFish,
    Allergen.crustaceans => allergenCrustaceans,
    Allergen.treeNuts => allergenTreeNuts,
    Allergen.sesame => allergenSesame,
    Allergen.sulfites => allergenSulfites,
  };

  String severity(AllergySeverity severity) => switch (severity) {
    AllergySeverity.mild => severityMild,
    AllergySeverity.severe => severitySevere,
  };

  String sex(Sex sex) => switch (sex) {
    Sex.male => sexMale,
    Sex.female => sexFemale,
    Sex.preferNotToSay => sexPreferNotToSay,
  };
}
