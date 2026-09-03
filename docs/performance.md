# Performance — orçamentos, otimizações e roteiro de medição (F4.4)

Fonte dos alvos: PRD §4.4. Este documento tem duas partes: o que já foi feito no
código (otimizações) e **como colher os números no aparelho** — porque
"está rápido" não é resultado auditável, número é.

## 1. Orçamentos

| Métrica | Alvo | Sonda no código |
|---|---|---|
| Cold start (splash → 1º frame) | < 2000 ms | `PerfBudget.coldStart` · `lib/main.dart` |
| Tradução (≤ 500 chars) | ≤ 300 ms | `PerfBudget.translation` · `TranslatorViewModel._translate` |
| Início de escuta (modelo já carregado) | ≤ 500 ms | `PerfBudget.listenStart` · `SpeechViewModel.start` |
| Animações | 60 fps | DevTools (sem sonda: quadro perdido não é evento do app) |

## 2. Otimizações já no código

- **Pré-aquecimento do tradutor** (`TranslationService.warmUp`): o ML Kit carrega
  o modelo na PRIMEIRA tradução. Sem aquecer, esse custo cai justamente onde o
  usuário está olhando o resultado. O `TranslatorViewModel` aquece assim que o
  par fica pronto e de novo ao trocar de idioma — uma vez por par, e falhando em
  silêncio, já que aquecer é otimização, não função.
- **Lazy-load do modelo de STT**: `SttService.start()` chama `ensureInstalled()`
  no primeiro uso; nada de whisper na construção do app. É por isso que o
  orçamento de escuta vale "modelo já carregado" — a primeira vez inclui a cópia
  do asset e não é comparável.
- **Rebuild cirúrgico**: `Selector` nas telas quentes; os três `Consumer` que
  restam (histórico, ajustes, bloco de voz) reconstroem tela inteira de propósito
  — são telas em que quase tudo muda junto.
- **Conectividade fora do caminho crítico**: resolve async depois do primeiro
  frame (`lib/main.dart`), para não empurrar o cold start.

## 3. Roteiro de medição

As sondas só existem em debug (`kDebugMode`), e debug é o número PIOR que o
usuário veria — errar para o lado seguro. Cada linha já traz o veredito, então
ler o log não exige lembrar o alvo:

```
[perf] translation: 214ms / 300ms ok · pt->en 137 chars local
[perf] listen_start: 612ms / 500ms ACIMA · pt
```

### Execução

1. Aparelho **físico** de classe média (ex.: Snapdragon 6xx), bateria acima de
   50% e sem economia de energia — o governador de CPU muda o resultado mais que
   qualquer otimização deste documento.
2. `flutter run --flavor full -d <device>` e acompanhe o log.
3. Cada métrica **5 vezes**, anotando a mediana (não a média: um outlier de GC
   distorce a média e não representa o que o usuário sente).

| # | Cenário | O que fazer |
|---|---|---|
| 1 | Cold start | Fechar o app pelo gerenciador, abrir. Repetir 5×. |
| 2 | Tradução curta | ~50 chars, par pt→en já baixado, após o aquecimento. |
| 3 | Tradução longa | ~500 chars (limite do AC). |
| 4 | Tradução fria | Logo após instalar o pacote, **sem** deixar aquecer — mede o que a otimização evita. |
| 5 | Início de escuta | Ditado já usado uma vez na sessão (modelo carregado). |
| 6 | Animações | DevTools → Performance overlay, percorrer home → histórico → ajustes. |

### Registro

Anote em `docs/performance_results.md` (crie ao medir): aparelho, versão do
Android, flavor, e a mediana de cada cenário contra o alvo. Cenário acima do
orçamento vira issue própria com o log colado — sem o número, a issue não é
acionável.
