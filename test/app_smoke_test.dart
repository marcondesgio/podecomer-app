import 'package:flutter_test/flutter_test.dart';

import 'support/account_fakes.dart';

void main() {
  testWidgets('app abre em pt-BR na tela inicial do usuário pronto', (
    tester,
  ) async {
    await AppHarness(user: confirmedUser).pump(tester);

    expect(find.text('Olá, Ana'), findsOneWidget);
    expect(find.text('VERIFICAR PRODUTO'), findsOneWidget);
    expect(find.text('Início'), findsOneWidget);
  });
}
