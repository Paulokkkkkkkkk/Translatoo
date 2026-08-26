# Translatoo

Tradutor **offline-first** PT ⇄ EN ⇄ ZH (Mandarim) — 100% on-device.
Nenhuma funcionalidade P0 depende de internet; a rede é usada apenas para
download de pacotes de idiomas e, no futuro, modo híbrido (P2).

## Status das fases

| Fase | Escopo | Status |
|---|---|---|
| **F0** | Fundação e design system (tokens, tema, i18n, storage, conectividade, shell responsivo, pipeline de qualidade) | ✅ **concluída** |
| F1 | Motor de tradução offline (ML Kit + Plano B TFLite) | ⬜ |
| F2 | Voz: ditado STT (Vosk) + leitura TTS nativa | ⬜ |
| F3 | Histórico, favoritos, ajustes, gerenciador de modelos | ⬜ |
| F4 | Polimento, modo híbrido, performance, release v1 | ⬜ |

## Setup

```bash
flutter pub get
flutter run                # device/emulador Android (minSdk 23)
```

Requisitos: Flutter com Dart `^3.13.1`.

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

## Desvio documentado

- `vosk_flutter` (M2/Fase 2): a versão publicada (0.3.48) declara
  `sdk <3.0.0` e não resolve com Dart 3. A integração ocorrerá na F2 atrás
  da interface `SttService`, com fork compatível ou override (risco R5).

## Nota de ambiente (risco R6)

O projeto vive dentro de pasta sincronizada pelo OneDrive. Antes do release,
avaliar mover para pasta local e garantir `.gitignore` cobrindo `build/`.
