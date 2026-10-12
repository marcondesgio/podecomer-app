import 'package:flutter_test/flutter_test.dart';

import 'engine_test_helpers.dart';

void main() {
  test('veredito de um rótulo real para 3 pessoas leva poucos ms', () {
    final product = label(
      'Farinha de trigo enriquecida com ferro e ácido fólico, açúcar, gordura '
      'vegetal, cacau em pó, açúcar invertido, sal, amido, fermentos químicos '
      'bicarbonato de amônio e bicarbonato de sódio, emulsificante lecitina de '
      'soja, aromatizantes, leite em pó integral, soro de leite. ALÉRGICOS: '
      'CONTÉM DERIVADOS DE TRIGO, SOJA E LEITE. PODE CONTER AMENDOIM, '
      'CASTANHAS E OVO. CONTÉM GLÚTEN. CONTÉM LACTOSE.',
    );

    engine.evaluate(product, family); // aquece
    const runs = 200;
    final watch = Stopwatch()..start();
    for (var i = 0; i < runs; i++) {
      engine.evaluate(product, family);
    }
    watch.stop();

    final perRun = watch.elapsedMicroseconds / runs;
    // Folga larga para máquinas de CI; no aparelho é bem menos.
    expect(perRun, lessThan(20000), reason: '$perRun µs por veredito');
  });
}
