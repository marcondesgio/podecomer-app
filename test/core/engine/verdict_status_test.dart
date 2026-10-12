import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/engine/verdict_status.dart';

void main() {
  group('VerdictStatus', () {
    test('precedência: NÃO CONSUMIR > ATENÇÃO > INCONCLUSIVO > SEGURO', () {
      expect(
        VerdictStatus.doNotConsume.isWorseThan(VerdictStatus.caution),
        isTrue,
      );
      expect(
        VerdictStatus.caution.isWorseThan(VerdictStatus.inconclusive),
        isTrue,
      );
      expect(
        VerdictStatus.inconclusive.isWorseThan(VerdictStatus.safe),
        isTrue,
      );
    });

    test('worstOf retorna o pior status do grupo', () {
      expect(
        VerdictStatus.worstOf([
          VerdictStatus.safe,
          VerdictStatus.caution,
          VerdictStatus.inconclusive,
        ]),
        VerdictStatus.caution,
      );
      expect(
        VerdictStatus.worstOf([
          VerdictStatus.caution,
          VerdictStatus.doNotConsume,
          VerdictStatus.safe,
        ]),
        VerdictStatus.doNotConsume,
      );
    });

    test('worstOf de todos seguros é SEGURO', () {
      expect(
        VerdictStatus.worstOf([VerdictStatus.safe, VerdictStatus.safe]),
        VerdictStatus.safe,
      );
    });

    test('worstOf de lista vazia é INCONCLUSIVO, nunca SEGURO', () {
      expect(VerdictStatus.worstOf([]), VerdictStatus.inconclusive);
    });
  });
}
