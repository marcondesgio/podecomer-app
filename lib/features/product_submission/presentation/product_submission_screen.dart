import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/allergen_engine_provider.dart';
import '../../../core/data/household.dart';
import '../../../core/data/products/product_providers.dart';
import '../../../core/engine/models.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/verdict/verdict_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/document_camera.dart';
import '../data/ingredients_ocr.dart';
import '../data/submission_repository.dart';
import '../domain/auto_capture.dart';
import 'allergen_highlight_controller.dart';

enum _Step { front, ingredients, reading, review, sending, done }

/// Cadastro pela câmera ao vivo: frente → ingredientes → OCR → revisão →
/// envio → veredito "baseado no seu cadastro".
class ProductSubmissionScreen extends ConsumerStatefulWidget {
  const ProductSubmissionScreen({super.key, required this.barcode});

  final String barcode;

  @override
  ConsumerState<ProductSubmissionScreen> createState() =>
      _ProductSubmissionScreenState();
}

class _ProductSubmissionScreenState
    extends ConsumerState<ProductSubmissionScreen> {
  var _step = _Step.front;
  CapturedPhoto? _front;
  CapturedPhoto? _ingredients;
  AllergenHighlightController? _ingredientsText;
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _ingredientsText?.dispose();
    _name.dispose();
    _brand.dispose();
    super.dispose();
  }

  Future<void> _onCaptured(CapturedPhoto photo) async {
    if (_step == _Step.front) {
      setState(() {
        _front = photo;
        _step = _Step.ingredients;
      });
      return;
    }
    setState(() {
      _ingredients = photo;
      _step = _Step.reading;
    });

    String text;
    try {
      text = await ref.read(ingredientsOcrProvider).read(photo.path);
    } on Object {
      text = '';
    }
    final engine = await ref.read(allergenEngineProvider.future);
    if (!mounted) return;
    _ingredientsText?.dispose();
    setState(() {
      _ingredientsText = AllergenHighlightController(
        dictionary: engine.dictionary,
        text: text,
      )..addListener(() => setState(() {}));
      _step = _Step.review;
    });
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _step = _Step.sending);
    try {
      await ref
          .read(submissionRepositoryProvider)
          .submit(
            SubmissionDraft(
              barcode: widget.barcode,
              frontJpeg: _front!.bytes,
              ingredientsJpeg: _ingredients!.bytes,
              ingredientsText: _ingredientsText!.text.trim(),
              name: _name.text.trim().isEmpty ? null : _name.text.trim(),
              brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
            ),
          );
      // A próxima consulta já encontra o produto pendente.
      ref.invalidate(productLookupProvider(widget.barcode));
      if (mounted) setState(() => _step = _Step.done);
    } on SubmissionRateLimited {
      if (!mounted) return;
      setState(() => _step = _Step.review);
      showMessage(context, l10n.submissionRateLimited);
    } on Object {
      if (!mounted) return;
      setState(() => _step = _Step.review);
      showMessage(context, l10n.submissionFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (_step) {
      _Step.front => _CaptureStep(
        key: const ValueKey('front'),
        title: l10n.submissionStepFront,
        hint: l10n.submissionFrontHint,
        onCaptured: _onCaptured,
      ),
      _Step.ingredients => _CaptureStep(
        key: const ValueKey('ingredients'),
        title: l10n.submissionStepIngredients,
        hint: l10n.submissionIngredientsHint,
        onCaptured: _onCaptured,
      ),
      _Step.reading => _Busy(message: l10n.readingIngredients),
      _Step.sending => _Busy(message: l10n.sendingSubmission),
      _Step.review => _review(context),
      _Step.done => _Done(
        barcode: widget.barcode,
        ingredientsText: _ingredientsText!.text.trim(),
        name: _name.text.trim(),
      ),
    };
  }

  Widget _review(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = context.statusColors;
    final controller = _ingredientsText!;

    Widget legend(Color background, Color foreground, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppSizes.radiusChip),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.screenMargin),
            children: [
              Text(l10n.reviewHint),
              if (controller.text.trim().isEmpty) ...[
                const SizedBox(height: 8),
                Text(l10n.ocrEmpty, style: textTheme.titleMedium),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  legend(
                    colors.doNotConsume.container,
                    colors.doNotConsume.onContainer,
                    l10n.legendContains,
                  ),
                  legend(
                    colors.caution.container,
                    colors.caution.onContainer,
                    l10n.legendMayContain,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('ingredients-text'),
                controller: controller,
                minLines: 6,
                maxLines: null,
                maxLength: 5000,
                decoration: InputDecoration(labelText: l10n.ingredientsLabel),
                validator: (v) => (v ?? '').trim().length < 3
                    ? l10n.ingredientsRequired
                    : null,
              ),
              TextButton.icon(
                onPressed: () => setState(() => _step = _Step.ingredients),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.retakeIngredients),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                maxLength: 120,
                decoration: InputDecoration(
                  labelText: l10n.productNameOptional,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _brand,
                maxLength: 80,
                decoration: InputDecoration(labelText: l10n.brandOptional),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _send, child: Text(l10n.sendSubmission)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um passo de foto: preview ao vivo + captura automática + botão manual.
class _CaptureStep extends ConsumerStatefulWidget {
  const _CaptureStep({
    super.key,
    required this.title,
    required this.hint,
    required this.onCaptured,
  });

  final String title;
  final String hint;
  final ValueChanged<CapturedPhoto> onCaptured;

  @override
  ConsumerState<_CaptureStep> createState() => _CaptureStepState();
}

class _CaptureStepState extends ConsumerState<_CaptureStep>
    with WidgetsBindingObserver {
  late DocumentCamera _camera = ref.read(documentCameraProvider)();
  final _detector = AutoCaptureDetector();
  var _ready = false;
  var _failed = false;
  var _capturing = false;
  var _progress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_camera.dispose());
    super.dispose();
  }

  /// O plugin pede para liberar a câmera quando o app sai de cena.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive && _ready) {
      setState(() => _ready = false);
      unawaited(_camera.dispose());
    } else if (state == AppLifecycleState.resumed && !_ready && !_failed) {
      _camera = ref.read(documentCameraProvider)();
      _start();
    }
  }

  Future<void> _start() async {
    try {
      await _camera.initialize();
    } on Object {
      if (mounted) setState(() => _failed = true);
      return;
    }
    if (!mounted) return;
    _detector.reset();
    setState(() {
      _ready = true;
      _failed = false;
      _progress = 0;
    });
    _camera.startFrames(_onFrame);
  }

  void _onFrame(LumaFrame frame) {
    if (_capturing || !mounted) return;
    final assessment = _detector.add(frame);
    setState(
      () => _progress = assessment.progress(_detector.requiredStableFrames),
    );
    if (assessment.ready) unawaited(_capture());
  }

  Future<void> _capture() async {
    if (_capturing || !_ready) return;
    _capturing = true;
    try {
      final photo = await _camera.capture();
      unawaited(HapticFeedback.mediumImpact());
      if (mounted) widget.onCaptured(photo);
    } on Object {
      if (mounted) {
        showMessage(context, AppLocalizations.of(context).genericError);
        _detector.reset();
        _camera.startFrames(_onFrame);
      }
    } finally {
      _capturing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const white = TextStyle(color: Colors.white);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _failed
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.screenMargin),
                        child: Text(
                          l10n.cameraUnavailable,
                          textAlign: TextAlign.center,
                          style: white,
                        ),
                      ),
                    )
                  : _ready
                  ? Center(child: _camera.preview())
                  : const Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.screenMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.hint, style: white, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _progress,
                    semanticsLabel: l10n.holdSteady,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _progress > 0 ? l10n.holdSteady : l10n.autoCaptureHint,
                    style: white,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _ready && !_capturing ? _capture : null,
                    icon: const Icon(Icons.photo_camera),
                    label: Text(l10n.takePhotoNow),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Busy extends StatelessWidget {
  const _Busy({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    ),
  );
}

/// Veredito calculado com o texto que a pessoa acabou de cadastrar.
class _Done extends ConsumerWidget {
  const _Done({
    required this.barcode,
    required this.ingredientsText,
    required this.name,
  });

  final String barcode;
  final String ingredientsText;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final people = ref.watch(selectedPeopleProvider);
    final engine = ref.watch(allergenEngineProvider).value;
    final selected = people.isLoading ? null : people.value;

    final List<Widget> verdict;
    if (selected == null || engine == null) {
      verdict = [const Center(child: CircularProgressIndicator())];
    } else {
      final group = engine.evaluate(
        Product(ingredientsText: ingredientsText, hasIngredients: true),
        selected,
      );
      verdict = [
        GroupVerdictHeader(
          status: group.status,
          names: [for (final p in group.people) p.personName],
        ),
        const SizedBox(height: 16),
        for (final person in group.people) PersonReasonsCard(verdict: person),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          children: [
            if (name.isNotEmpty) Text(name, style: textTheme.headlineSmall),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.pending_outlined),
                label: Text(l10n.submissionSeal),
              ),
            ),
            const SizedBox(height: 16),
            ...verdict,
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.volunteer_activism_outlined),
                title: Text(l10n.submissionThanksTitle),
                subtitle: Text(l10n.submissionThanksBody),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.labelDisclaimer, style: textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.pushReplacement(AppRoutes.scanner),
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.nextProduct),
            ),
          ],
        ),
      ),
    );
  }
}
