import 'package:flutter/foundation.dart';

/// Medição dos orçamentos de latência da F4.4 (PRD §4.6).
///
/// Existe porque "está rápido" não é resultado: o roteiro de QA pede NÚMEROS,
/// e colhê-los no aparelho exige que o app os imprima. Cada sonda conhece o
/// próprio orçamento e marca `ACIMA` quando estoura — assim a leitura do log
/// não depende de lembrar qual era o alvo.
///
/// Fora de debug isto some inteiro: `kDebugMode` é const, então a release nem
/// carrega o relógio. Medir em debug dá o número PIOR que o usuário veria, o
/// que é o lado seguro de errar.
enum PerfBudget {
  /// Splash até o primeiro frame interativo.
  coldStart('cold_start', 2000),

  /// Texto pronto até a tradução aparecer (RN-04).
  translation('translation', 300),

  /// Toque no microfone até o motor estar de fato ouvindo.
  listenStart('listen_start', 500);

  const PerfBudget(this.label, this.budgetMs);

  final String label;
  final int budgetMs;
}

/// Cronômetro de uma medição. Descarte-o chamando [stop].
final class PerfTrace {
  PerfTrace._(this.budget) : _watch = Stopwatch()..start();

  /// Começa a medir [budget]. Em release devolve um traço inerte.
  factory PerfTrace.start(PerfBudget budget) => PerfTrace._(budget);

  final PerfBudget budget;
  final Stopwatch _watch;

  /// Encerra e imprime. [detail] entra na linha (idioma, tamanho do texto…) —
  /// sem ele, uma medição fora do orçamento não diz sobre O QUÊ.
  int stop({String? detail}) {
    _watch.stop();
    final ms = _watch.elapsedMilliseconds;
    if (kDebugMode) {
      final veredito = ms <= budget.budgetMs ? 'ok' : 'ACIMA';
      final sufixo = detail == null ? '' : ' · $detail';
      debugPrint(
        '[perf] ${budget.label}: ${ms}ms / ${budget.budgetMs}ms $veredito'
        '$sufixo',
      );
    }
    return ms;
  }
}
