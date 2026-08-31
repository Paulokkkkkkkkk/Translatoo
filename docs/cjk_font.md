# F1.9 — Tipografia CJK: subset de Noto Sans SC

> RF-CJK-01..04 · PRD §4.9 · Risco **R8** · AC-F1-6 · Status: **entregue**
> Data: 2026-08-31

## Problema

Android não garante cobertura de glifos **Han** em aparelhos sem pacote de
idioma chinês. Como a tela Traduzir renderiza mandarim desde a F1.6, todo `zh`
aparecia como **tofu** (□□□) nesses devices — um terço do produto quebrado
visualmente, e a F2 (ditado e leitura em chinês) invalidável.

## Origem do arquivo

| Item | Valor |
|---|---|
| Família | **Noto Sans SC** |
| Fonte original | `https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc/NotoSansSC[wght].ttf` (variable, eixo `wght` 100–900) |
| Tamanho original | 16,95 MB — inviável para o flavor `lite` (< 40 MB) |
| Licença | **SIL Open Font License 1.1** — uso comercial e redistribuição permitidos; texto integral versionado em [`assets/fonts/OFL.txt`](../assets/fonts/OFL.txt) |

A OFL exige que o texto da licença acompanhe o arquivo e proíbe vender a fonte
isoladamente — nenhuma das duas condições afeta o embutimento no app.

## Subset gerado

O recorte cobre os **6.763 hanzi do GB2312** (níveis 1 e 2), sua pontuação,
ASCII e Latin-1 — a faixa de uso corrente do mandarim simplificado. A lista de
caracteres não é digitada à mão: é derivada do próprio codec `gb2312` do
Python, o que a torna auditável e idêntica a cada execução.

| Arquivo | Peso | Glifos | Tamanho |
|---|---|---|---|
| `assets/fonts/NotoSansSC-Regular.subset.ttf` | 400 | 7.620 | **2,10 MB** |
| `assets/fonts/NotoSansSC-Bold.subset.ttf` | 700 | 7.620 | **2,10 MB** |
| | | **Total** | **4,20 MB** ≤ 5 MB |

O peso 700 é embutido porque o `TextTheme` usa `w600`/`w700` em títulos e
labels: sem ele, os títulos em chinês cairiam num negrito sintético irregular.

## Reprodução

```bash
bash scripts/build_cjk_subset.sh
```

O script baixa a variable font oficial, instancia os pesos 400 e 700, aplica o
recorte e **falha** se algum arquivo passar de 2,5 MB. `SOURCE_DATE_EPOCH=0`
fixa o timestamp interno da fonte, então a saída é **byte a byte idêntica** aos
arquivos versionados — dá para verificar um build com `shasum -a 256`.

| SHA-256 | Arquivo |
|---|---|
| `fc7717afd5702a117fd12dd6cc87b0a1f293c2bb04899d44ee32e0dedd8f0954` | `NotoSansSC-Regular.subset.ttf` |
| `a5523f09a3a0905394005c88f9d1f43f1fd3ae5e1efb0fd07d6abb3c79169ced` | `NotoSansSC-Bold.subset.ttf` |

## Como é aplicado

**Exclusivamente** como `fontFamilyFallback` no `TextTheme` de
[`app_theme.dart`](../lib/core/theme/app_theme.dart), num único ponto
(`AppTheme.cjkFallback`). PT e EN permanecem na tipografia nativa da
plataforma (RF-CJK-02): o fallback só é consultado para os pontos de código que
a fonte nativa não cobre.

Os temas de componente (`appBarTheme`, `inputDecorationTheme`, `snackBarTheme`,
`navigationBarTheme`, botões) passaram a derivar desse `TextTheme` em vez de ler
`AppTypography` direto — antes eles escapavam do fallback e reintroduziriam
tofu na AppBar e nos hints.

**Aplicar fonte widget a widget é proibido**, mesma regra dos tokens de cor
(RN-04). `test/theme/cjk_fallback_test.dart` trava isso: varre `lib/` e falha se
`fontFamily` aparecer fora de `app_theme.dart`, além de verificar o fallback em
todos os estilos dos dois temas e o orçamento de 5 MB.

## Limitação conhecida

Caracteres fora do GB2312 — hanzi raros, nomes próprios incomuns, texto em
chinês **tradicional** — continuam sem cobertura no subset e dependem da fonte
do sistema. A decisão é deliberada: cobrir o Unicode CJK completo custaria
~11 MB e estouraria o flavor `lite` para atender um caso que o produto não
declara (RN-01 fixa `zh` como mandarim simplificado). Reabrir na F4 se o
suporte a tradicional entrar no escopo.
