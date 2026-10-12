import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/group/group_repository.dart';
import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/models.dart';
import 'package:pode_comer/core/router/app_router.dart';
import 'package:pode_comer/features/product_submission/data/document_camera.dart';
import 'package:pode_comer/features/product_submission/data/ingredients_ocr.dart';
import 'package:pode_comer/features/product_submission/data/submission_repository.dart';
import 'package:pode_comer/features/product_submission/domain/auto_capture.dart';
import 'package:pode_comer/features/product_submission/presentation/allergen_highlight_controller.dart';

import '../../support/account_fakes.dart';
import 'frames.dart';

class FakeDocumentCamera implements DocumentCamera {
  FakeDocumentCamera(this.log, {this.failInit = false});

  final List<String> log;
  final bool failInit;
  ValueChanged<LumaFrame>? onFrame;

  @override
  Future<void> initialize() async {
    if (failInit) throw StateError('sem câmera');
  }

  @override
  Widget preview() => const ColoredBox(color: Colors.black);

  @override
  void startFrames(ValueChanged<LumaFrame> onFrame) => this.onFrame = onFrame;

  @override
  Future<void> stopFrames() async => onFrame = null;

  @override
  Future<CapturedPhoto> capture() async {
    log.add('capture');
    return CapturedPhoto(
      path: 'foto${log.length}.jpg',
      bytes: Uint8List.fromList([log.length]),
    );
  }

  @override
  Future<void> dispose() async {}
}

class FakeOcr implements IngredientsOcr {
  FakeOcr(this.text);

  final String text;
  final paths = <String>[];

  @override
  Future<String> read(String imagePath) async {
    paths.add(imagePath);
    return text;
  }
}

class FakeSubmissions implements SubmissionRepository {
  FakeSubmissions({this.error});

  final Object? error;
  final drafts = <SubmissionDraft>[];

  @override
  Future<void> submit(SubmissionDraft draft) async {
    if (error case final e?) throw e;
    drafts.add(draft);
  }
}

const _barcode = '7891000100158';

void main() {
  late List<String> cameraLog;
  late List<FakeDocumentCamera> cameras;
  late FakeOcr ocr;
  late FakeSubmissions submissions;

  FakeDocumentCamera camera() => cameras.last;

  Future<void> openFlow(
    WidgetTester tester, {
    String ocrText = 'Farinha de trigo, açúcar. Pode conter amendoim.',
    Object? submitError,
    bool cameraFails = false,
  }) async {
    cameraLog = [];
    cameras = [];
    ocr = FakeOcr(ocrText);
    submissions = FakeSubmissions(error: submitError);
    final app = AppHarness(
      user: confirmedUser,
      profile: profileOf(
        allergies: const [
          PersonAllergy(
            allergen: Allergen.peanut,
            severity: AllergySeverity.severe,
          ),
        ],
      ),
      members: const [
        GroupMember(
          id: 'carol',
          name: 'Carol',
          allergies: [PersonAllergy(allergen: Allergen.gluten)],
        ),
        GroupMember(
          id: 'enzo',
          name: 'Enzo',
          allergies: [PersonAllergy(allergen: Allergen.lactose)],
        ),
      ],
      overrides: [
        documentCameraProvider.overrideWithValue(() {
          final c = FakeDocumentCamera(cameraLog, failInit: cameraFails);
          cameras.add(c);
          return c;
        }),
        ingredientsOcrProvider.overrideWithValue(ocr),
        submissionRepositoryProvider.overrideWithValue(submissions),
      ],
    );
    await app.pump(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.text('Olá, Ana')),
    );
    unawaited(
      container
          .read(appRouterProvider)
          .push(AppRoutes.productSubmissionFor(_barcode)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> emit(
    WidgetTester tester,
    LumaFrame frame, [
    int times = 1,
  ]) async {
    for (var i = 0; i < times; i++) {
      camera().onFrame?.call(frame);
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> reachReview(WidgetTester tester) async {
    await emit(tester, sharpFrame(), 6); // frente: captura automática
    await tester.tap(find.text('Tirar foto')); // ingredientes: manual
    await tester.pumpAndSettle();
  }

  testWidgets('frente com captura automática quando nítida e parada', (
    tester,
  ) async {
    await openFlow(tester);
    expect(find.text('Passo 1 de 2 · Frente da embalagem'), findsOneWidget);

    await emit(tester, blurryFrame(), 6);
    expect(cameraLog, isEmpty, reason: 'desfocada não captura');

    await emit(tester, sharpFrame(), 6);
    expect(cameraLog, ['capture']);
    expect(find.text('Passo 2 de 2 · Lista de ingredientes'), findsOneWidget);
  });

  testWidgets('OCR roda na foto dos ingredientes e o texto é editável', (
    tester,
  ) async {
    await openFlow(tester);
    await reachReview(tester);

    expect(ocr.paths, ['foto2.jpg']); // só a foto dos ingredientes
    expect(find.text('Confira os ingredientes'), findsOneWidget);

    final field = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('ingredients-text')),
        matching: find.byType(EditableText),
      ),
    );
    final controller = field.controller as AllergenHighlightController;
    expect(controller.text, 'Farinha de trigo, açúcar. Pode conter amendoim.');
    expect(
      [
        for (final h in controller.highlights())
          controller.text.substring(h.start, h.end),
      ],
      ['Farinha de trigo', 'amendoim'],
    );

    await tester.enterText(
      find.byKey(const ValueKey('ingredients-text')),
      'Farinha de arroz, açúcar.',
    );
    await tester.pump();
    expect(controller.highlights(), isEmpty);
  });

  testWidgets('enviar mostra o veredito com o selo de revisão', (tester) async {
    await openFlow(tester);
    await reachReview(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do produto · opcional'),
      'Biscoito Novo',
    );
    await tester.ensureVisible(find.text('Enviar cadastro'));
    await tester.tap(find.text('Enviar cadastro'));
    await tester.pumpAndSettle();

    final draft = submissions.drafts.single;
    expect(draft.barcode, _barcode);
    expect(draft.name, 'Biscoito Novo');
    expect(draft.brand, isNull);
    expect(draft.frontJpeg, [1]);
    expect(draft.ingredientsJpeg, [2]);
    expect(
      draft.ingredientsText,
      'Farinha de trigo, açúcar. Pode conter amendoim.',
    );

    expect(find.text('Baseado no seu cadastro · em revisão'), findsOneWidget);
    expect(find.text('NÃO CONSUMIR'), findsWidgets);
    expect(find.text('para Ana, Carol e Enzo'), findsOneWidget);
    expect(
      find.textContaining('Glúten: contém “Farinha de trigo”'),
      findsOneWidget,
    );
    expect(find.textContaining('Nenhum alergênico de Enzo'), findsOneWidget);
  });

  testWidgets('refazer a foto dos ingredientes volta ao passo 2', (
    tester,
  ) async {
    await openFlow(tester);
    await reachReview(tester);
    await tester.tap(find.text('Refazer foto dos ingredientes'));
    await tester.pumpAndSettle();
    expect(find.text('Passo 2 de 2 · Lista de ingredientes'), findsOneWidget);
  });

  testWidgets('OCR vazio pede para digitar e não envia vazio', (tester) async {
    await openFlow(tester, ocrText: '');
    await reachReview(tester);
    expect(
      find.text(
        'Não conseguimos ler o texto. Digite os ingredientes ou refaça a foto.',
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Enviar cadastro'));
    await tester.tap(find.text('Enviar cadastro'));
    await tester.pumpAndSettle();
    expect(find.text('Informe a lista de ingredientes.'), findsOneWidget);
    expect(submissions.drafts, isEmpty);
  });

  testWidgets('limite diário: avisa e mantém o texto', (tester) async {
    await openFlow(tester, submitError: const SubmissionRateLimited());
    await reachReview(tester);
    await tester.ensureVisible(find.text('Enviar cadastro'));
    await tester.tap(find.text('Enviar cadastro'));
    await tester.pumpAndSettle();
    expect(
      find.text('Você já enviou muitos cadastros hoje. Tente de novo amanhã.'),
      findsOneWidget,
    );
    expect(find.text('Confira os ingredientes'), findsOneWidget);
  });

  testWidgets('falha de rede no envio: avisa e deixa tentar de novo', (
    tester,
  ) async {
    await openFlow(tester, submitError: Exception('offline'));
    await reachReview(tester);
    await tester.ensureVisible(find.text('Enviar cadastro'));
    await tester.tap(find.text('Enviar cadastro'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Não conseguimos enviar'), findsOneWidget);
    expect(find.text('Enviar cadastro'), findsOneWidget);
  });

  testWidgets('sem câmera: explica e não deixa fotografar', (tester) async {
    await openFlow(tester, cameraFails: true);
    expect(find.textContaining('Permita o acesso'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Tirar foto'),
        matching: find.byWidgetPredicate((w) => w is FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });
}
