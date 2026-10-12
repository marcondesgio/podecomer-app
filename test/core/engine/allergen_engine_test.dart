import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/models.dart';
import 'package:pode_comer/core/engine/verdict_status.dart';

import 'engine_test_helpers.dart';

const _safe = VerdictStatus.safe;
const _caution = VerdictStatus.caution;
const _dnc = VerdictStatus.doNotConsume;
const _inconclusive = VerdictStatus.inconclusive;

void main() {
  group('Família Ana (amendoim grave), Carol (glúten), Enzo (lactose)', () {
    test('biscoito com farinha de trigo: só Carol não pode', () {
      final group = engine.evaluate(
        label(
          'Farinha de trigo enriquecida com ferro e ácido fólico, açúcar, '
          'gordura vegetal, sal.',
        ),
        family,
      );
      expect(group.status, _dnc);
      expect(verdictOf(group, ana).status, _safe);
      expect(verdictOf(group, carol).status, _dnc);
      expect(verdictOf(group, enzo).status, _safe);
    });

    test('"pode conter amendoim" é NÃO CONSUMIR para Ana (grave)', () {
      final group = engine.evaluate(
        label(
          'Açúcar, cacau, gordura vegetal. Alérgicos: pode conter amendoim.',
        ),
        family,
      );
      final anaVerdict = verdictOf(group, ana);
      expect(anaVerdict.status, _dnc);
      expect(anaVerdict.reasons.first.kind, ReasonKind.traces);
      expect(anaVerdict.reasons.first.escalation, Escalation.severeAllergy);
      expect(anaVerdict.reasons.first.excerpt, 'pode conter amendoim');
      expect(verdictOf(group, carol).status, _safe);
      expect(verdictOf(group, enzo).status, _safe);
    });

    test('"pode conter amendoim" é ATENÇÃO para alergia leve', () {
      expect(
        statusFor('Açúcar. Pode conter amendoim.', Allergen.peanut),
        _caution,
      );
    });

    test('leite em pó: Enzo não pode, Ana e Carol podem', () {
      final group = engine.evaluate(
        label('Açúcar, leite em pó integral, cacau.'),
        family,
      );
      expect(verdictOf(group, enzo).status, _dnc);
      expect(verdictOf(group, ana).status, _safe);
      expect(verdictOf(group, carol).status, _safe);
    });

    test('produto seguro para todos', () {
      final group = engine.evaluate(
        label('Arroz, água, sal, óleo de girassol.'),
        family,
      );
      expect(group.status, _safe);
      expect(group.people.every((v) => v.reasons.isEmpty), isTrue);
    });

    test('veredito do grupo considera só as pessoas selecionadas', () {
      final product = label('Farinha de trigo, açúcar.');
      expect(engine.evaluate(product, [ana, enzo]).status, _safe);
      expect(engine.evaluate(product, family).status, _dnc);
    });

    test('grupo vazio é INCONCLUSIVO', () {
      expect(engine.evaluate(label('Arroz.'), []).status, _inconclusive);
    });

    test('um veredito por pessoa, na ordem recebida', () {
      final group = engine.evaluate(label('Arroz.'), family);
      expect(group.people.map((v) => v.personName), ['Ana', 'Carol', 'Enzo']);
    });

    test('grupo: NÃO CONSUMIR vence ATENÇÃO', () {
      final lia = personWith(Allergen.soy);
      final group = engine.evaluate(
        label('Farinha de trigo, açúcar. Pode conter soja.'),
        [carol, lia],
      );
      expect(verdictOf(group, lia).status, _caution);
      expect(group.status, _dnc);
    });
  });

  group('Sem produto ou sem ingredientes', () {
    test('produto não encontrado é INCONCLUSIVO para todos', () {
      final group = engine.evaluate(null, family);
      expect(group.status, _inconclusive);
      for (final verdict in group.people) {
        expect(verdict.status, _inconclusive);
        expect(verdict.reasons.single.kind, ReasonKind.productNotFound);
      }
    });

    test('sem lista de ingredientes é INCONCLUSIVO, nunca SEGURO', () {
      const product = Product(hasIngredients: false);
      final group = engine.evaluate(product, family);
      expect(group.people.map((v) => v.status), everyElement(_inconclusive));
    });

    test('hasIngredients com texto vazio é INCONCLUSIVO', () {
      const product = Product(ingredientsText: '   ', hasIngredients: true);
      expect(engine.evaluate(product, [carol]).status, _inconclusive);
    });

    test('sem ingredientes, mas "contém amendoim" declarado: NÃO CONSUMIR', () {
      const product = Product(
        hasIngredients: false,
        allergensContains: {Allergen.peanut},
      );
      final group = engine.evaluate(product, family);
      expect(verdictOf(group, ana).status, _dnc);
      expect(verdictOf(group, carol).status, _inconclusive);
    });
  });

  group('Alergênicos declarados', () {
    test('allergensContains glúten → NÃO CONSUMIR para Carol', () {
      final verdict = verdictOf(
        engine.evaluate(
          label('Ingredientes diversos.', contains: {Allergen.gluten}),
          [carol],
        ),
        carol,
      );
      expect(verdict.status, _dnc);
      expect(verdict.reasons.single.source, ReasonSource.declaredContains);
    });

    test('allergensContains trigo implica glúten', () {
      final group = engine.evaluate(
        label('Massa.', contains: {Allergen.wheat}),
        [carol],
      );
      expect(group.status, _dnc);
    });

    test('allergensTraces amendoim: grave NÃO CONSUMIR, leve ATENÇÃO', () {
      final product = label('Chocolate.', traces: {Allergen.peanut});
      expect(engine.evaluate(product, [ana]).status, _dnc);
      expect(
        engine.evaluate(product, [personWith(Allergen.peanut)]).status,
        _caution,
      );
    });

    test('allergensTraces glúten → NÃO CONSUMIR para Carol', () {
      final product = label('Chocolate.', traces: {Allergen.gluten});
      final verdict = verdictOf(engine.evaluate(product, [carol]), carol);
      expect(verdict.status, _dnc);
      expect(verdict.reasons.single.escalation, Escalation.glutenTraceRule);
    });

    test('leite declarado + "zero lactose": Enzo pode, APLV não', () {
      final product = label(
        'Leite zero lactose, enzima lactase.',
        contains: {Allergen.milk},
      );
      expect(engine.evaluate(product, [enzo]).status, _safe);
      expect(
        engine.evaluate(product, [personWith(Allergen.milk)]).status,
        _dnc,
      );
    });
  });

  group('Regra do glúten ("pode conter" cereais)', () {
    for (final cereal in ['trigo', 'centeio', 'cevada', 'aveia']) {
      test('"pode conter $cereal" é NÃO CONSUMIR para Carol', () {
        final verdict = verdictOf(
          engine.evaluate(label('Milho, açúcar. Pode conter $cereal.'), [
            carol,
          ]),
          carol,
        );
        expect(verdict.status, _dnc);
        expect(verdict.reasons.first.escalation, Escalation.glutenTraceRule);
      });
    }

    test('"pode conter trigo" é ATENÇÃO para alergia leve a trigo', () {
      expect(statusFor('Milho. Pode conter trigo.', Allergen.wheat), _caution);
    });

    test('"contém glúten" → NÃO CONSUMIR', () {
      expect(
        statusFor('Amido de milho. CONTÉM GLÚTEN.', Allergen.gluten),
        _dnc,
      );
    });

    test('"não contém glúten" → SEGURO', () {
      expect(
        statusFor(
          'Farinha de arroz, ovos. NÃO CONTÉM GLÚTEN.',
          Allergen.gluten,
        ),
        _safe,
      );
    });

    test('malte é glúten', () {
      expect(statusFor('Açúcar, extrato de malte.', Allergen.gluten), _dnc);
    });
  });

  group('Lactose x leite (APLV)', () {
    for (final claim in ['zero lactose', 'sem lactose', 'isento de lactose']) {
      test('"$claim" anula lactose mas não leite', () {
        final text = 'Leite $claim, cacau.';
        expect(statusFor(text, Allergen.lactose), _safe);
        expect(statusFor(text, Allergen.milk), _dnc);
      });
    }

    test('"sem lactose" sozinho não é leite para APLV', () {
      expect(
        statusFor('Farinha de arroz, açúcar. Sem lactose.', Allergen.milk),
        _safe,
      );
    });

    test('caseinato é leite (APLV) mas não lactose', () {
      const text = 'Caseinato de sódio, maltodextrina.';
      expect(statusFor(text, Allergen.milk), _dnc);
      expect(statusFor(text, Allergen.lactose), _safe);
    });

    for (final term in [
      'caseína',
      'whey',
      'soro de leite',
      'lactoalbumina',
      'manteiga',
      'creme de leite',
      'queijo',
    ]) {
      test('"$term" é leite (APLV)', () {
        expect(statusFor('Açúcar, $term, sal.', Allergen.milk), _dnc);
      });
    }

    test('ingrediente ambíguo "aroma de manteiga" → ATENÇÃO', () {
      final group = engine.evaluate(
        label('Farinha de milho, aroma idêntico ao natural de manteiga.'),
        [personWith(Allergen.milk)],
      );
      expect(group.status, _caution);
      expect(group.people.single.reasons.single.kind, ReasonKind.ambiguous);
    });
  });

  group('Outros alergênicos', () {
    const cases = {
      'Albumina, açúcar.': Allergen.egg,
      'Gema de ovo, sal.': Allergen.egg,
      'Lisozima.': Allergen.egg,
      'Ovos pasteurizados.': Allergen.egg,
      'Lecitina de soja.': Allergen.soy,
      'Molho de soja (shoyu).': Allergen.soy,
      'Óleo de peixe.': Allergen.fish,
      'Camarão seco.': Allergen.crustaceans,
      'Castanha-do-pará, nozes.': Allergen.treeNuts,
      'Amêndoas laminadas.': Allergen.treeNuts,
      'Tahine, limão.': Allergen.sesame,
      'Conservador metabissulfito de sódio.': Allergen.sulfites,
      'Conservador INS 223.': Allergen.sulfites,
      'Paçoca triturada.': Allergen.peanut,
    };
    for (final MapEntry(key: text, value: allergen) in cases.entries) {
      test('"$text" → NÃO CONSUMIR para ${allergen.code}', () {
        expect(statusFor(text, allergen), _dnc);
      });
    }

    test('lecitina sem origem → ATENÇÃO para soja', () {
      expect(
        statusFor('Açúcar, emulsificante lecitina.', Allergen.soy),
        _caution,
      );
    });
  });

  group('Falsos positivos', () {
    test('"manteiga de cacau" não é leite', () {
      const text = 'Açúcar, manteiga de cacau, massa de cacau.';
      expect(statusFor(text, Allergen.milk), _safe);
      expect(statusFor(text, Allergen.lactose), _safe);
    });

    test('"leite de coco" não é leite', () {
      const text = 'Leite de coco, água, goma guar.';
      expect(statusFor(text, Allergen.milk), _safe);
      expect(statusFor(text, Allergen.lactose), _safe);
    });

    test('"creme de leite de coco" não é leite', () {
      expect(statusFor('Creme de leite de coco.', Allergen.milk), _safe);
    });

    test('"leite de amêndoas" não é leite, mas é castanha', () {
      const text = 'Água, leite de amêndoas.';
      expect(statusFor(text, Allergen.milk), _safe);
      expect(statusFor(text, Allergen.treeNuts), _dnc);
    });

    test('"leite de aveia" não é leite, mas é glúten', () {
      const text = 'Leite de aveia.';
      expect(statusFor(text, Allergen.milk), _safe);
      expect(statusFor(text, Allergen.gluten), _dnc);
    });

    test('"manteiga de amendoim" é amendoim, não leite', () {
      final group = engine.evaluate(label('Manteiga de amendoim, sal.'), [
        ana,
        personWith(Allergen.milk),
      ]);
      expect(verdictOf(group, ana).status, _dnc);
      expect(group.people.last.status, _safe);
    });

    test('"noz-moscada" não é castanha', () {
      expect(statusFor('Sal, noz-moscada, pimenta.', Allergen.treeNuts), _safe);
    });

    test('"trigo sarraceno" não é trigo nem glúten', () {
      const text = 'Farinha de trigo sarraceno.';
      expect(statusFor(text, Allergen.gluten), _safe);
      expect(statusFor(text, Allergen.wheat), _safe);
    });

    test('maltodextrina não é malte', () {
      expect(statusFor('Maltodextrina, açúcar.', Allergen.gluten), _safe);
    });

    test('"sulfato ferroso" não é sulfito', () {
      expect(statusFor('Sulfato ferroso, zinco.', Allergen.sulfites), _safe);
    });

    test('"avelã" não é aveia', () {
      expect(statusFor('Creme de avelã.', Allergen.gluten), _safe);
    });

    test('"massa caseira" não é caseína', () {
      expect(statusFor('Massa caseira de milho.', Allergen.milk), _safe);
    });

    test('"lecitina de girassol" não é soja nem ovo', () {
      const text = 'Lecitina de girassol.';
      expect(statusFor(text, Allergen.soy), _safe);
      expect(statusFor(text, Allergen.egg), _safe);
    });

    test('"suco de caju" não é castanha', () {
      expect(statusFor('Suco de caju, açúcar.', Allergen.treeNuts), _safe);
    });
  });

  group('OCR imperfeito', () {
    test('maiúsculas e sem acentos', () {
      expect(statusFor('ACUCAR, PACOCA, SAL', Allergen.peanut), _dnc);
    });

    test('dígitos no lugar de letras: "AMEND0IM"', () {
      final verdict = engine.evaluate(label('Açúcar, AMEND0IM.'), [ana]);
      expect(verdict.status, _dnc);
      expect(verdict.people.single.reasons.single.approximate, isTrue);
    });

    test('"1eite em pó" e "farinha de tr1go"', () {
      expect(statusFor('Açúcar, 1eite em pó.', Allergen.milk), _dnc);
      expect(statusFor('Farinha de tr1go.', Allergen.gluten), _dnc);
    });

    test('rn lido no lugar de m: "arnendoim"', () {
      expect(statusFor('Doce de arnendoim.', Allergen.peanut), _dnc);
    });

    test('uma letra trocada em palavra longa: "amendoin"', () {
      expect(statusFor('Pasta de amendoin.', Allergen.peanut), _dnc);
    });

    test('palavra hifenizada na quebra de linha', () {
      final group = engine.evaluate(label('Açúcar, amen-\ndoim torrado.'), [
        ana,
      ]);
      expect(group.status, _dnc);
      expect(group.people.single.reasons.single.excerpt, 'amen-\ndoim');
    });

    test('palavra partida por espaço: "amen doim"', () {
      expect(statusFor('Açúcar, amen doim.', Allergen.peanut), _dnc);
    });

    test('"P0DE C0NTER" ainda é traço', () {
      expect(
        statusFor('ACUCAR. P0DE C0NTER AMENDOIM', Allergen.peanut),
        _caution,
      );
    });

    test('pontuação duplicada e espaços extras', () {
      const text = 'Açúcar,,  farinha   de  trigo..;  sal!!';
      expect(statusFor(text, Allergen.gluten), _dnc);
    });

    test('sem ponto entre "contém" e "pode conter"', () {
      const text = 'ALÉRGICOS: CONTÉM LEITE PODE CONTER AMENDOIM';
      expect(statusFor(text, Allergen.milk), _dnc);
      expect(statusFor(text, Allergen.peanut), _caution);
    });

    test('termo quebrado em duas linhas após conectivo', () {
      expect(statusFor('Açúcar, farinha de\ntrigo, sal', Allergen.wheat), _dnc);
    });

    test('"pode conter" termina no ponto', () {
      const text = 'Pode conter amendoim. Leite em pó.';
      expect(statusFor(text, Allergen.milk), _dnc);
      expect(statusFor(text, Allergen.peanut), _caution);
    });

    test('"aveia" não é corrigida para "avelã" nem vice-versa', () {
      expect(statusFor('Flocos de aveia.', Allergen.treeNuts), _safe);
    });
  });

  group('Motivos', () {
    test('cita o trecho exato do rótulo original', () {
      final group = engine.evaluate(
        label('AÇÚCAR, Farinha de Trigo Integral, sal.'),
        [carol],
      );
      final reason = group.people.single.reasons.single;
      expect(reason.excerpt, 'Farinha de Trigo');
      expect(reason.allergen, Allergen.gluten);
      expect(reason.source, ReasonSource.ingredientsText);
    });

    test('traço cita a frase inteira com a lista', () {
      final group = engine.evaluate(
        label('Cacau. Pode conter traços de castanhas, amendoim e leite.'),
        [ana],
      );
      expect(
        group.people.single.reasons.single.excerpt,
        'Pode conter traços de castanhas, amendoim',
      );
    });

    test('motivos ordenados do mais grave ao menos grave', () {
      const person = Person(
        id: 'p',
        name: 'P',
        allergies: [
          PersonAllergy(allergen: Allergen.soy),
          PersonAllergy(allergen: Allergen.gluten),
        ],
      );
      final verdict = engine
          .evaluate(label('Lecitina, farinha de trigo.'), [person])
          .people
          .single;
      expect(verdict.reasons.map((r) => r.status), [_dnc, _caution]);
    });

    test('pessoa sem alergias com ingredientes é SEGURO', () {
      const person = Person(id: 'x', name: 'X');
      expect(
        engine.evaluate(label('Farinha de trigo.'), [person]).status,
        _safe,
      );
    });
  });
}
