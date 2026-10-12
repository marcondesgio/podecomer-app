import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Meta do produto: do código lido ao veredito na tela em menos de 2 s.
const scanToVerdictBudget = Duration(seconds: 2);

/// Cronômetro iniciado no momento da leitura; viaja até a tela de resultado.
class ScanTrace {
  ScanTrace() : _stopwatch = Stopwatch()..start();

  final Stopwatch _stopwatch;
  Duration? _verdictAt;

  /// Marca o veredito na tela. Só a primeira chamada conta.
  Duration markVerdict() => _verdictAt ??= _stopwatch.elapsed;
}

class ScanMetric {
  const ScanMetric({required this.elapsed, required this.fromCache});

  final Duration elapsed;
  final bool fromCache;

  bool get withinBudget => elapsed < scanToVerdictBudget;
}

/// Últimas medições scan→veredito. Guarda só tempo e cache: nada de código,
/// produto, pessoa ou status.
final scanMetricsProvider = NotifierProvider<ScanMetrics, List<ScanMetric>>(
  ScanMetrics.new,
);

class ScanMetrics extends Notifier<List<ScanMetric>> {
  static const _keep = 20;

  @override
  List<ScanMetric> build() => const [];

  void record(ScanMetric metric) {
    state = [...state, metric].reversed.take(_keep).toList().reversed.toList();
    if (kDebugMode) {
      developer.log(
        'scan→veredito: ${metric.elapsed.inMilliseconds} ms'
        '${metric.fromCache ? ' (cache)' : ''}'
        '${metric.withinBudget ? '' : ' ACIMA DA META'}',
        name: 'pode_comer.perf',
      );
    }
  }
}
