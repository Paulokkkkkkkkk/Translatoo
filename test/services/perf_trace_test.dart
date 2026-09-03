import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:translatoo/core/utils/perf_trace.dart';

void main() {
  test('cada orçamento da F4.4 casa com o número do PRD §4.6', () {
    expect(PerfBudget.coldStart.budgetMs, 2000);
    expect(PerfBudget.translation.budgetMs, 300);
    expect(PerfBudget.listenStart.budgetMs, 500);
  });

  test('stop devolve o tempo decorrido e não lança', () {
    final trace = PerfTrace.start(PerfBudget.translation);
    expect(trace.stop(detail: 'pt->en'), isNonNegative);
  });

  test('a linha traz o veredito contra o orçamento', () {
    // Sem o veredito, ler o log exigiria lembrar de cor qual era o alvo.
    final linhas = <String>[];
    final anterior = debugPrint;
    debugPrint = (String? m, {int? wrapWidth}) => linhas.add(m ?? '');
    addTearDown(() => debugPrint = anterior);

    PerfTrace.start(PerfBudget.coldStart).stop(detail: 'frio');

    expect(linhas.single, contains('cold_start'));
    expect(linhas.single, contains('/ 2000ms ok'));
    expect(linhas.single, contains('frio'));
  });
}
