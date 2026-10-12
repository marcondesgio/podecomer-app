import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/activity_repository.dart';
import 'package:pode_comer/core/data/group/group_repository.dart';
import 'package:pode_comer/core/data/people.dart';
import 'package:pode_comer/core/data/products/product_lookup_result.dart';
import 'package:pode_comer/core/data/products/product_providers.dart';
import 'package:pode_comer/core/data/products/product_repository.dart';
import 'package:pode_comer/core/data/products/safe_alternatives.dart';
import 'package:pode_comer/core/data/scan_metrics.dart';
import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/models.dart';
import 'package:pode_comer/core/engine/verdict_status.dart';
import 'package:pode_comer/features/scanner/presentation/barcode_camera.dart';

import '../core/data/products/fakes.dart';
import '../support/account_fakes.dart';

class FakeBarcodeCamera implements BarcodeCamera {
  ValueChanged<String>? onCode;
  var pauses = 0;
  var resumes = 0;

  @override
  final torchOn = ValueNotifier(false);

  @override
  Widget build(
    BuildContext context, {
    required ValueChanged<String> onCode,
    required WidgetBuilder errorBuilder,
  }) {
    this.onCode = onCode;
    return const ColoredBox(color: Colors.black);
  }

  @override
  Future<void> toggleTorch() async => torchOn.value = !torchOn.value;
  @override
  Future<void> pause() async => pauses++;
  @override
  Future<void> resume() async => resumes++;
  @override
  void dispose() {}
}

class FakeActivity implements ActivityRepository {
  final scans = <(String, VerdictStatus)>[];
  final reports = <(String, String)>[];

  @override
  Future<void> saveScan(String barcode, VerdictStatus groupStatus) async =>
      scans.add((barcode, groupStatus));

  @override
  Future<void> report(String barcode, String message) async =>
      reports.add((barcode, message));
}

const _carol = GroupMember(
  id: 'carol',
  name: 'Carol',
  allergies: [PersonAllergy(allergen: Allergen.gluten)],
);
const _enzo = GroupMember(
  id: 'enzo',
  name: 'Enzo',
  allergies: [PersonAllergy(allergen: Allergen.lactose)],
);

void main() {
  late FakeBarcodeCamera camera;
  late FakeActivity activity;
  late AppHarness app;
  late ProviderContainer container;

  /// Abre o app com a família (Ana titular com amendoim grave) e entra no
  /// scanner pelo botão central.
  Future<void> openScanner(
    WidgetTester tester, {
    required List<Object?> ownLookups,
    List<Object> offResponses = const [],
    List<Object> alternatives = const [],
    Plan plan = Plan.free,
  }) async {
    camera = FakeBarcodeCamera();
    activity = FakeActivity();
    final repository = ProductRepository(
      ownProducts: FakeOwnProducts(ownLookups),
      openFoodFacts: offClient(
        RecordingHttp([for (final r in offResponses) respond(r)]).client,
      ),
    );
    final alternativesRepo = SafeAlternativesRepository(
      ownProducts: FakeOwnProducts(const []),
      openFoodFacts: offClient(
        RecordingHttp([
          respond({'products': alternatives}),
        ]).client,
      ),
      scanCounts: FakeScanCounts(),
    );
    app = AppHarness(
      user: confirmedUser,
      profile: profileOf(
        plan: plan,
        allergies: const [
          PersonAllergy(
            allergen: Allergen.peanut,
            severity: AllergySeverity.severe,
          ),
        ],
      ),
      members: [_carol, _enzo],
      overrides: [
        barcodeCameraProvider.overrideWithValue(() => camera),
        activityRepositoryProvider.overrideWithValue(activity),
        productRepositoryProvider.overrideWith((ref) async => repository),
        safeAlternativesRepositoryProvider.overrideWith(
          (ref) async => alternativesRepo,
        ),
      ],
    );
    await app.pump(tester);
    container = ProviderScope.containerOf(
      tester.element(find.text('Olá, Ana')),
    );
    await tester.tap(find.byTooltip('Escanear'));
    await tester.pumpAndSettle();
  }

  /// A lista do resultado é preguiçosa: rola até o item existir.
  Future<void> scrollTo(WidgetTester tester, String text) =>
      tester.scrollUntilVisible(
        find.text(text),
        300,
        scrollable: find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        ),
      );

  Future<void> scan(WidgetTester tester, String code) async {
    camera.onCode!(code);
    await tester.pumpAndSettle();
  }

  // Biscoito: farinha de trigo (Carol) e "pode conter amendoim" (Ana, grave).
  final biscuit = ownRow();

  testWidgets('scan → veredito do grupo, por pessoa, com motivos', (
    tester,
  ) async {
    await openScanner(tester, ownLookups: [biscuit]);
    expect(find.text('Para quem?'), findsOneWidget);

    await scan(tester, barcode);

    expect(find.text('Biscoito da Base'), findsOneWidget);
    expect(find.text('NÃO CONSUMIR'), findsWidgets);
    expect(find.text('para Ana, Carol e Enzo'), findsOneWidget);
    expect(
      find.textContaining('Glúten: declarado como presente pelo fabricante'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Amendoim: pode conter, segundo o fabricante'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Nenhum alergênico de Enzo encontrado'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Atualizado em 30/09/2026 · fonte: base Pode Comer?'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Ana: NÃO CONSUMIR'), findsOneWidget);
    expect(find.bySemanticsLabel('Enzo: SEGURO'), findsOneWidget);

    // Histórico gravado uma vez, com o status do grupo.
    expect(activity.scans, [(barcode, VerdictStatus.doNotConsume)]);
  });

  testWidgets('tempo scan→veredito medido e abaixo de 2 s', (tester) async {
    await openScanner(tester, ownLookups: [biscuit]);
    await scan(tester, barcode);

    final metric = container.read(scanMetricsProvider).single;
    expect(metric.elapsed, lessThan(scanToVerdictBudget));
    expect(metric.withinBudget, isTrue);
  });

  testWidgets('vibra, pausa a câmera e ignora a mesma leitura repetida', (
    tester,
  ) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics.add('vibrate');
        return null;
      },
    );
    await openScanner(tester, ownLookups: [biscuit]);

    camera.onCode!(barcode);
    camera.onCode!(barcode);
    camera.onCode!(barcode);
    await tester.pumpAndSettle();

    expect(haptics, ['vibrate']);
    expect(camera.pauses, 1);
    expect(find.text('Biscoito da Base'), findsOneWidget);

    await scrollTo(tester, 'Próximo produto');
    await tester.tap(find.text('Próximo produto'));
    await tester.pumpAndSettle();
    expect(find.text('Para quem?'), findsOneWidget);
    expect(camera.resumes, 1);

    // Mesmo código logo depois: debounce.
    await scan(tester, barcode);
    expect(find.text('Para quem?'), findsOneWidget);
  });

  testWidgets('código com dígito verificador inválido é ignorado', (
    tester,
  ) async {
    await openScanner(tester, ownLookups: [biscuit]);
    await scan(tester, '7891000100104');
    expect(find.text('Para quem?'), findsOneWidget);
    expect(camera.pauses, 0);
  });

  testWidgets('"Para quem?" muda o veredito', (tester) async {
    await openScanner(tester, ownLookups: [biscuit]);
    await tester.tap(find.widgetWithText(FilterChip, 'Carol'));
    await tester.tap(find.widgetWithText(FilterChip, 'Ana'));
    await tester.pumpAndSettle();

    // Não deixa ficar sem ninguém.
    await tester.tap(find.widgetWithText(FilterChip, 'Enzo'));
    await tester.pumpAndSettle();
    expect(find.text('Selecione pelo menos uma pessoa.'), findsOneWidget);

    await scan(tester, barcode);
    expect(find.text('SEGURO'), findsWidgets);
    expect(find.text('para Enzo'), findsOneWidget);
    expect(activity.scans.single.$2, VerdictStatus.safe);
  });

  testWidgets('lanterna liga e desliga', (tester) async {
    await openScanner(tester, ownLookups: [biscuit]);
    await tester.tap(find.byTooltip('Ligar lanterna'));
    await tester.pumpAndSettle();
    expect(camera.torchOn.value, isTrue);
    expect(find.byTooltip('Desligar lanterna'), findsOneWidget);
  });

  testWidgets('"Isso está errado?" grava em reports', (tester) async {
    await openScanner(tester, ownLookups: [biscuit]);
    await scan(tester, barcode);

    await scrollTo(tester, 'Isso está errado?');
    await tester.tap(find.text('Isso está errado?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(find.text('Conte rapidamente o que está errado.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Agora tem leite');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(activity.reports, [(barcode, 'Agora tem leite')]);
    expect(find.text('Obrigado! Vamos revisar.'), findsOneWidget);
  });

  group('alternativas seguras', () {
    final safeItems = [
      for (final (i, code) in [
        '7891000100110',
        '7891000100127',
        '7891000100134',
      ].indexed)
        offSearchItem(code, 'Biscoito de arroz $i'),
      offSearchItem(
        '7891000100141',
        'Com trigo',
        ingredients: 'Farinha de trigo.',
      ),
    ];

    testWidgets('plano grátis mostra 1 e oferece o Família', (tester) async {
      await openScanner(tester, ownLookups: [biscuit], alternatives: safeItems);
      await scan(tester, barcode);

      expect(
        find.text('Alternativas seguras para Ana, Carol e Enzo'),
        findsOneWidget,
      );
      expect(find.text('Biscoito de arroz 0'), findsOneWidget);
      expect(find.text('Biscoito de arroz 1'), findsNothing);
      expect(find.text('Com trigo'), findsNothing);
      expect(
        find.text('Veja até 5 alternativas no plano Família'),
        findsOneWidget,
      );
    });

    testWidgets('plano Família mostra todas as seguras', (tester) async {
      await openScanner(
        tester,
        ownLookups: [biscuit],
        alternatives: safeItems,
        plan: Plan.family,
      );
      await scan(tester, barcode);
      expect(find.textContaining('Biscoito de arroz'), findsNWidgets(3));
      expect(find.text('Com trigo'), findsNothing);
    });

    testWidgets('produto SEGURO não busca alternativas', (tester) async {
      await openScanner(
        tester,
        ownLookups: [
          {
            ...ownRow(ingredients: 'Arroz, sal.'),
            'allergens_contains': <String>[],
            'allergens_traces': <String>[],
          },
        ],
      );
      await scan(tester, barcode);
      expect(find.text('SEGURO'), findsWidgets);
      expect(find.textContaining('Alternativas seguras'), findsNothing);
    });
  });

  testWidgets('não encontrado: INCONCLUSIVO, cadastrar e scan salvo', (
    tester,
  ) async {
    await openScanner(tester, ownLookups: [null], offResponses: [offNotFound]);
    await scan(tester, barcode);
    expect(find.text('INCONCLUSIVO'), findsWidgets);
    expect(find.textContaining('Produto não encontrado'), findsWidgets);
    expect(find.text('Cadastrar produto'), findsOneWidget);
    expect(activity.scans.single.$2, VerdictStatus.inconclusive);
  });

  testWidgets('falha de rede: INCONCLUSIVO e tentar de novo', (tester) async {
    await openScanner(
      tester,
      ownLookups: [
        const ProductSourceException(LookupFailure.network),
        biscuit,
      ],
    );
    await scan(tester, barcode);
    expect(find.text('INCONCLUSIVO'), findsOneWidget);
    expect(activity.scans, isEmpty);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('Biscoito da Base'), findsOneWidget);
    expect(activity.scans, hasLength(1));
  });
}
