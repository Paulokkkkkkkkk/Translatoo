# Translatoo

Tradutor **offline-first** PT ⇄ EN ⇄ ZH (Mandarim) — 100% on-device.
Nenhuma funcionalidade P0 depende de internet; a rede é usada apenas para
download de pacotes de idiomas e, no futuro, modo híbrido (P2).

## Status das fases

| Fase | Escopo | Status |
|---|---|---|
| **F0** | Fundação e design system (tokens, tema, i18n, storage, conectividade, shell responsivo, pipeline de qualidade) | ✅ **concluída** |
| **F1** | Motor de tradução offline (ML Kit + Plano B TFLite) | ✅ **concluída** (F1.1–F1.9, tipografia CJK incluída) |
| F2 | Voz: ditado STT + leitura TTS nativa | ✅ **concluída** (F2.0–F2.9 — ditado, TTS e integração conversacional) |
| F3 | Histórico, favoritos, ajustes, gerenciador de modelos | 🟡 **F3.1–F3.6 concluídas** · ⬜ F3.7 (qualidade da fase) |
| F4 | Polimento, modo híbrido, performance, release v1 | ⬜ |

O backlog completo está nas [issues](../../issues) — uma por subfase do
`implementation_plan.md`, com objetivo, tarefas, entregável e critérios de aceite.

## Setup

```bash
flutter pub get
flutter run                # device/emulador Android (minSdk 23)
```

Requisitos: Flutter com Dart `^3.12.2` · Android `minSdk 23` · iOS **15.6**
(imposto pelo pod do `whisper_ggml`; o `GoogleMLKit/Translate` exige 15.5).

> **iOS só roda em iPhone físico.** O ML Kit publica fatia `arm64` apenas para
> device, e o simulador do Apple Silicon recusa `x86_64` — não há contorno.

## Flavors `lite` e `full` (F2.1b)

Cada variante embarca **um** modelo de ditado; a seleção do `.bin` é feita
pelos `flavors:` do `pubspec.yaml`, e o `--dart-define` diz ao app qual
procurar. Os dois valores precisam combinar.

```bash
# full — ggml-base-q5_1 (56,9 MB), melhor qualidade
flutter run --flavor full \
  --dart-define=STT_MODEL_ASSET=assets/models/whisper/ggml-base-q5_1.bin

# lite — ggml-tiny-q5_1 (30,7 MB)
flutter run --flavor lite \
  --dart-define=STT_MODEL_ASSET=assets/models/whisper/ggml-tiny-q5_1.bin

# build sem ditado: o 🎤 some da árvore de widgets (TranslatorViewModel.canDictate)
flutter run --flavor lite --dart-define=STT_MODEL_ASSET=
```

Troque `run` por `build apk --release --split-per-abi` para gerar os APKs.

### Tamanhos medidos (release, `--split-per-abi`, arm64-v8a)

| Flavor | Medido | Meta PRD §4.7 | |
|---|---|---|---|
| `lite` | **92,4 MB** | ~95 MB *(revista na v1.2)* | ✅ |
| `full` | **119,3 MB** | ≤ 180 MB | ✅ |

A meta original do `lite` era **< 40 MB** e foi **revista para ~95 MB** na v1.2 do PRD:
ela havia sido escrita antes de a lista de dependências existir. A distância nunca veio
do modelo.
Composição do APK arm64 (descomprimido):

| Item | Tamanho |
|---|---|
| Modelo `ggml-tiny-q5_1` | 30,7 MB |
| `libtranslate_jni` (ML Kit) | 15,6 MB |
| `libflutter` | 11,0 MB |
| **ffmpeg** (`avcodec`, `avfilter`, `avformat`, …) | **~14,2 MB** |
| TF Lite (`jni` + `gpu_jni`) | 6,9 MB |
| `libwhisper` | 2,8 MB |

Mesmo com **zero** modelo embutido o `lite` passaria de 55 MB só em código
nativo. Os ~14 MB de ffmpeg são peso morto: vêm como dependência dura do
`whisper_ggml` para converter arquivos de áudio, e o app alimenta PCM direto.
Fechar os 40 MB exige decisão de produto — remover o Plano B TFLite do `lite`,
entregar o modelo por *dynamic feature*, ou revisar a meta. **Não é algo que a
F2.1b pudesse resolver dentro do seu escopo.**

## Pipeline de qualidade (obrigatório por subfase)

```bash
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter run --release      # validação manual em Android físico / modo avião
```

## Arquitetura

```text
lib/
├── main.dart              # raiz de composição (MultiProvider + MaterialApp)
├── core/
│   ├── constants/         # app_colors · app_typography · app_spacing · app_strings · app_constants
│   ├── services/          # storage · connectivity · app_exception (+ translation/stt/tts nas próximas fases)
│   └── theme/             # app_theme.dart (Material 3 light/dark)
├── models/                # language · translation_record · app_settings
├── state/                 # ViewModels (ChangeNotifier/provider)
└── ui/
    ├── screens/           # home · translate · history · settings
    └── widgets/           # connection_badge · placeholder_panel · ...
```

**Regras invioláveis**

1. Camadas: `ui/` → ViewModels (`state/`) → `core/services/` → plugins.
   A UI **nunca** importa plugin diretamente.
2. Cores existem **somente** em `app_colors.dart` (RN-04). Nenhum
   `Color(0x…)` fora dele; widgets consomem via `Theme.of(context)`.
3. Strings de UI existem **somente** em `app_strings.dart`
   (`AppStrings.of(context)`), pt/en/zh com fallback pt-BR.
4. Toda exceção cruza a fronteira de serviço convertida em
   `AppException(ErrorCode)` — tabela única §4.8 do PRD.
5. Enum fechado `Language { pt, en, zh }` (RN-01).
6. Sem telemetria; logs somente em modo debug.

## Design system

**Azul & Branco**, modos light/dark com os mesmos 14 tokens estáticos
(`AppColorsLight`/`AppColorsDark`). O tema Material 3 é construído
exclusivamente dos tokens; alternar o tema do sistema muda o app inteiro
sem tocar em widget algum.

A primária `#3954FD` foi **amostrada do case de referência** em `docs/design/`.
A identidade era verde até a extração do design system, que mostrou que branco
sobre o verde `#16A34A` dava 3,30:1 — abaixo do mínimo AA. A troca inteira não
tocou em widget algum, só nos 28 valores de `app_colors.dart`.

As regras de forma, layout e componentes estão em
[`docs/design_system.md`](docs/design_system.md); o contraste de todo par
texto/fundo é verificado em `test/theme/palette_contrast_test.dart`.

## Persistência (chaves)

`translatoo.history` · `translatoo.favorites` ·
`translatoo.settings.{srcLang,tgtLang,ttsRate,ttsPitch,autoPlay,wifiOnly,cloudEnabled,themeMode}`
· `translatoo.settings.schemaVersion`.
Único acesso pelo `StorageService`: gravações agrupadas (debounce 500 ms),
leitura tolerante a JSON corrompido, migrações por `schemaVersion`.

## Desvios documentados

- ~~**Motor de STT indefinido (M2/Fase 2)**~~ — **resolvido na spike F2.0**:
  `whisper_ggml` (whisper.cpp), com um único modelo ggml multilíngue cobrindo
  pt/en/zh em 56,9 MB — contra 113 MB do Vosk (Android-only, sem release há
  ~2 anos) e ~176 MB do `sherpa-onnx` (sem modelo streaming de português). A
  lista fechada de dependências voltou a estar fechada. Risco R5b encerrado;
  medições e ressalvas em `docs/stt_spike.md`.
- **Latência do STT ainda não medida (herdada da F2.0, aberta na F2.1)** —
  whisper.cpp é mais pesado em CPU que um zipformer streaming, e nem a spike nem
  a F2.1 tiveram Android físico disponível (o emulador roda a CPU do host e não
  representa gama média). Falta medir carga do modelo e latência dos parciais; a
  escada de recuo (`tiny-q5_1` → `sherpa_onnx`) está em `docs/whisper_models.md`.
- **Parciais de STT são refinados, não incrementais** — whisper.cpp reescreve o
  texto parcial a cada emissão. O overlay de escuta da F2.5 deve tratá-lo como
  bloco substituível, nunca concatenar emissões.
- **Plano B TFLite desligado** — a spike F1.4 (`docs/tflite_spike.md`) não
  encontrou modelo NMT compacto viável para os 3 pares.
  `AppConstants.enableAlternativeEngine = false`. Consequência assumida: sem
  acesso aos servidores de download do Google, o app não traduz (risco R9).
- ~~**Tipografia CJK pendente (F1.9)**~~ — **resolvido**: subset GB2312 de Noto
  Sans SC (4,20 MB, SIL OFL 1.1) embutido como `fontFamilyFallback` do tema.
  Mandarim renderiza sem tofu em Androids sem pacote de idioma chinês
  (risco R8 fechado). Origem, licença e comando de regeração em
  `docs/cjk_font.md`; regenerar com `bash scripts/build_cjk_subset.sh`.
- ~~**Captura de microfone ausente da lista fechada (F2.2)**~~ — **resolvido na
  F2.2b**: a spike F2.0 escolheu o motor e não a fonte de áudio, e o
  `SttService` ficou programando contra a interface `SttAudioSource` sem
  implementação real. `record` 7.1.1 entrou na lista fechada — sem colidir com
  o `permission_handler`, que foi o que matou o `vosk_flutter`. Critérios e
  decisão em `docs/audio_source.md`.
- ~~**Waveform do ditado não foi implementada (F2.5)**~~ — **resolvido na
  F2.2b**: a §5.7 proíbe onda sem amplitude real, e a F2.5 entregou um
  indicador neutro por não haver captura de áudio. Com o `record` há nível real
  de microfone, e a onda foi implementada medindo — o conflito com a §5.7
  deixou de existir.
- ~~**`lite` estoura o orçamento de 40 MB (F2.1b)**~~ — **resolvido**: a meta era
  inalcançável (com zero modelo embutido o APK ainda passaria de 55 MB só em nativo) e
  foi revista para ~95 MB no PRD §4.7 v1.2.
- ~~**Textos de permissão do iOS só existem em pt-BR (F2.3)**~~ — **resolvido na
  F4.7a**: `InfoPlist.strings` em `pt-BR`, `en` e `zh-Hans`, registrados como
  variant group no projeto Xcode e declarados em `CFBundleLocalizations`.
- **Atalho às configurações de TTS do SO não implementado (F2.6)** — pendência
  de produto: nenhum plugin da lista fechada expõe o deep-link, e botão que não
  leva a lugar nenhum é pior que ausência. A SnackBar de voz ausente é
  persistente e instrui o caminho (AC-M3-2 preservado); a validação manual dos
  AC-M3-1..3 em Android físico segue pendente (sem device no ambiente).

## Nota de ambiente (risco R6)

O projeto vive dentro de pasta sincronizada pelo OneDrive. Antes do release,
avaliar mover para pasta local e garantir `.gitignore` cobrindo `build/`.

---

## Como contribuir

Leia o [CONTRIBUTING.md](CONTRIBUTING.md) antes de abrir um PR. Em resumo:
pegue uma issue, trabalhe em branch própria, rode o pipeline de qualidade e
**credite seu nome na tabela abaixo** — é um requisito de merge, não uma
gentileza.

## Créditos por issue

> **Regra do projeto (obrigatória).** Toda issue concluída **deve** registrar
> aqui quem a desenvolveu. A atualização desta tabela faz parte do PR que
> fecha a issue: **PR que não credita o autor não é aprovado.** A tabela é a
> memória de quem construiu cada parte do Translatoo.
>
> Preencha uma linha por issue concluída, em ordem crescente de subfase:

| Subfase | Issue | Entrega | Desenvolvido por |
|---|---|---|---|
| F0.1–F0.9 | [#1](../../issues/1)–[#9](../../issues/9) | Fundação e design system | [@Paulokkkkkkkkk](https://github.com/Paulokkkkkkkkk) |
| F1.1–F1.8 | [#10](../../issues/10)–[#17](../../issues/17) | Motor de tradução offline (M1) | [@Paulokkkkkkkkk](https://github.com/Paulokkkkkkkkk) |
| F1.9 | [#18](../../issues/18) | Tipografia CJK — subset de Noto Sans SC como `fontFamilyFallback` | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.0 | [#19](../../issues/19) | Spike do motor de STT — decisão por `whisper_ggml` | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F0.10 | [#45](../../issues/45) | Design system extraído do case + troca da paleta para Azul & Branco | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.1 | [#20](../../issues/20) | Modelos ggml de STT embutidos + instalador para o diretório de dados | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.1b | [#21](../../issues/21) | Flavors `lite`/`full` com assets condicionais por flavor | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.2 | [#22](../../issues/22) | `SttService` — parciais refinados, pausa de 1,5 s e teto de 60 s | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.3 | [#23](../../issues/23) | Permissão de microfone nos três caminhos + chaves de uso do iOS | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.4 | [#24](../../issues/24) | `SpeechViewModel` — máquina de estados, RN-07 e restauração no cancelamento | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.5 | [#25](../../issues/25) | UI do ditado — botão de microfone e folha de escuta | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.2b | [#52](../../issues/52) | Captura de microfone (`record`) + onda com nível real | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| DS | [#53](../../issues/53) | Tokens de raio da §2 (`radiusSm/Md/Lg/Pill`) e migração dos widgets | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| DS | [#58](../../issues/58) | Modo voz do case — bloco de marca expandido, onda no cabeçalho e botão de modo | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.9 | [#29](../../issues/29) | Integração M1×M2×M3 — ciclo conversacional testado ponta a ponta | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.1 | [#30](../../issues/30) | `LibraryViewModel` — dedupe, FIFO de 200, undo posicional e filtros | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.2 | [#31](../../issues/31) | Tela Histórico — busca, filtros bidirecionais e exclusão reversível | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.3 | [#32](../../issues/32) | Tela Ajustes — preferências persistidas e override manual de tema | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F4.7a | [#54](../../issues/54) | Identidade do app: bundle id, nome e textos de permissão do iOS | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| DS | — | Redesenho da tela Traduzir para a anatomia da §4 do design system | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.6 | [#26](../../issues/26) | `TtsService` + motor `flutter_tts` — fila única, cache de voz, erros mapeados | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.7 | [#27](../../issues/27) | `TtsViewModel` — autoplay, ditado sempre fala (RF-M3-06), erros observáveis | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.8 | [#28](../../issues/28) | UI de reprodução — 🔊, mini-player e sliders de voz (debug) | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F2.9 | [#29](../../issues/29) | Integração M2×M3×M1 — orquestração conversacional testada | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.1 | [#30](../../issues/30) | `LibraryViewModel` — dedupe, FIFO 200, undo, filtros | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.2 | [#31](../../issues/31) | Tela Histórico — busca, filtros, exclusão reversível | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.3 | [#32](../../issues/32) | Tela Ajustes + `SettingsViewModel` — preferências persistidas e tema manual | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.4 | [#33](../../issues/33) | Gerenciador de Modelos — estado real, Wi-Fi gate e confirmação de exclusão | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.5 | [#34](../../issues/34) | `ConnectionBadge` real — tooltip explicativo e live region | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |
| F3.6 | [#35](../../issues/35) | Persistência integral — migração de schema, downgrade e último par no boot | [@narcisojunior-dev](https://github.com/narcisojunior-dev) |

_As demais linhas são preenchidas conforme as issues forem concluídas._

**Como preencher**: use seu handle do GitHub no formato
`[@usuario](https://github.com/usuario)`. Se a issue teve mais de uma pessoa,
liste todas separadas por vírgula. Não remova linhas de outras pessoas.
