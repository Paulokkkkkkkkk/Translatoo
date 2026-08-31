# Translatoo

Tradutor **offline-first** PT ⇄ EN ⇄ ZH (Mandarim) — 100% on-device.
Nenhuma funcionalidade P0 depende de internet; a rede é usada apenas para
download de pacotes de idiomas e, no futuro, modo híbrido (P2).

## Status das fases

| Fase | Escopo | Status |
|---|---|---|
| **F0** | Fundação e design system (tokens, tema, i18n, storage, conectividade, shell responsivo, pipeline de qualidade) | ✅ **concluída** |
| **F1** | Motor de tradução offline (ML Kit + Plano B TFLite) | ✅ **concluída** (F1.1–F1.9, tipografia CJK incluída) |
| F2 | Voz: ditado STT + leitura TTS nativa | ⬜ — bloqueada pela spike **F2.0** (motor de STT) |
| F3 | Histórico, favoritos, ajustes, gerenciador de modelos | ⬜ — pode ser antecipada (depende de F1, não de F2) |
| F4 | Polimento, modo híbrido, performance, release v1 | ⬜ |

O backlog completo está nas [issues](../../issues) — uma por subfase do
`implementation_plan.md`, com objetivo, tarefas, entregável e critérios de aceite.

## Setup

```bash
flutter pub get
flutter run                # device/emulador Android (minSdk 23)
```

Requisitos: Flutter com Dart `^3.12.2` · Android `minSdk 23` · iOS **15.5**
(imposto pelo pod `GoogleMLKit/Translate`).

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

Verde & Branco, modos light/dark com os mesmos 14 tokens estáticos
(`AppColorsLight`/`AppColorsDark`). O tema Material 3 é construído
exclusivamente dos tokens; alternar o tema do sistema muda o app inteiro
sem tocar em widget algum.

## Persistência (chaves)

`translatoo.history` · `translatoo.favorites` ·
`translatoo.settings.{srcLang,tgtLang,ttsRate,ttsPitch,autoPlay,wifiOnly,cloudEnabled,themeMode}`
· `translatoo.settings.schemaVersion`.
Único acesso pelo `StorageService`: gravações agrupadas (debounce 500 ms),
leitura tolerante a JSON corrompido, migrações por `schemaVersion`.

## Desvios documentados

- **Motor de STT indefinido (M2/Fase 2)** — `vosk_flutter` 0.3.48 declara
  `sdk <3.0.0` e não resolve com Dart 3; está comentado no `pubspec.yaml` e
  foi **removido da lista fechada** de dependências. O motor será escolhido
  pela spike **F2.0** (risco R5b). A interface `SttService` isola a decisão,
  então F2.4/F2.5 podem ser programadas em paralelo.
- **Plano B TFLite desligado** — a spike F1.4 (`docs/tflite_spike.md`) não
  encontrou modelo NMT compacto viável para os 3 pares.
  `AppConstants.enableAlternativeEngine = false`. Consequência assumida: sem
  acesso aos servidores de download do Google, o app não traduz (risco R9).
- ~~**Tipografia CJK pendente (F1.9)**~~ — **resolvido**: subset GB2312 de Noto
  Sans SC (4,20 MB, SIL OFL 1.1) embutido como `fontFamilyFallback` do tema.
  Mandarim renderiza sem tofu em Androids sem pacote de idioma chinês
  (risco R8 fechado). Origem, licença e comando de regeração em
  `docs/cjk_font.md`; regenerar com `bash scripts/build_cjk_subset.sh`.

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
| F2.0 | [#19](../../issues/19) | Spike do motor de STT | _disponível_ |

_As demais linhas são preenchidas conforme as issues forem concluídas._

**Como preencher**: use seu handle do GitHub no formato
`[@usuario](https://github.com/usuario)`. Se a issue teve mais de uma pessoa,
liste todas separadas por vírgula. Não remova linhas de outras pessoas.
