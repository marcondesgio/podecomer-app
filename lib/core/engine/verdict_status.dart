/// Os quatro status de veredito do Pode Comer?.
///
/// Dart puro (sem Flutter): o motor de alergênicos precisa ser testável
/// isoladamente. A ordem de declaração NÃO define a precedência; use
/// [severity] / [worstOf].
enum VerdictStatus {
  safe(severity: 0),
  inconclusive(severity: 1),
  caution(severity: 2),
  doNotConsume(severity: 3);

  const VerdictStatus({required this.severity});

  /// Quanto maior, mais grave.
  /// NÃO CONSUMIR > ATENÇÃO > INCONCLUSIVO > SEGURO.
  final int severity;

  bool isWorseThan(VerdictStatus other) => severity > other.severity;

  /// Pior status de uma coleção (regra do veredito do grupo).
  ///
  /// Coleção vazia → [inconclusive]: sem pessoas avaliadas, nunca
  /// afirmamos que algo é seguro.
  static VerdictStatus worstOf(Iterable<VerdictStatus> statuses) {
    var worst = VerdictStatus.safe;
    var any = false;
    for (final status in statuses) {
      any = true;
      if (status.isWorseThan(worst)) worst = status;
    }
    return any ? worst : VerdictStatus.inconclusive;
  }
}
