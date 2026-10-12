import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/engine/verdict_status.dart';
import 'package:pode_comer/core/theme/app_theme.dart';
import 'package:pode_comer/core/widgets/verdict/status_badge.dart';
import 'package:pode_comer/l10n/app_localizations.dart';

void main() {
  const labels = {
    VerdictStatus.safe: 'SEGURO',
    VerdictStatus.caution: 'ATENÇÃO',
    VerdictStatus.doNotConsume: 'NÃO CONSUMIR',
    VerdictStatus.inconclusive: 'INCONCLUSIVO',
  };

  for (final MapEntry(key: status, value: label) in labels.entries) {
    testWidgets('selo $label mostra palavra e ícone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('pt', 'BR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(body: StatusBadge(status: status)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(label), findsOneWidget);
      expect(find.byIcon(StatusBadge.iconFor(status)), findsOneWidget);
    });
  }
}
