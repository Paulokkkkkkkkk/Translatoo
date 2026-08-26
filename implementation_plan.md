# TRANSLATOO — PLANO DE IMPLEMENTAÇÃO
## Guia de Desenvolvimento por Fases — Tradutor Offline PT ⇄ EN ⇄ ZH (Mandarim)

| Campo | Valor |
|---|---|
| **Produto** | Translatoo |
| **Versão do plano** | 1.0 |
| **Data** | 2026-08-26 |
| **Documento-fonte** | `PRD.md` v1.0 (requisitos, módulos, critérios de aceite) |
| **Stack** | Dart + Flutter (exclusivamente) |
| **Plataformas** | Android (prioridade máxima) · iOS (secundária) · Desktop/Web (terciária) |
| **Idiomas** | Português `pt-BR` · Inglês `en-US` · Chinês Mandarim `zh-CN` |
| **Paleta** | **Verde & Branco**, com modos **Light** e **Dark** |
| **Público** | Devs Flutter / agentes de IA de programação |

---

## SUMÁRIO
1. [Princípios do Plano](#1-princípios-do-plano)
2. [Síntese da Análise do PRD](#2-síntese-da-análise-do-prd)
3. [Design System — Paleta Verde & Branco (Light/Dark)](#3-design-system--paleta-verde--branco-lightdark)
4. [Arquitetura Alvo](#4-arquitetura-alvo)
5. [Roadmap Macro — Visão das 5 Fases](#5-roadmap-macro--visão-das-5-fases)
6. [FASE 0 — Fundação e Design System](#6-fase-0--fundação-e-design-system)
7. [FASE 1 — Motor de Tradução Offline (M1)](#7-fase-1--motor-de-tradução-offline-m1)
8. [FASE 2 — Voz Completa: Ditado STT + Leitura TTS (M2+M3)](#8-fase-2--voz-completa-ditado-stt--leitura-tts-m2m3)
9. [FASE 3 — Histórico, Favoritos, Ajustes e Conectividade (M4)](#9-fase-3--histórico-favoritos-ajustes-e-conectividade-m4)
10. [FASE 4 — Polimento, Modo Híbrido, Performance e Release](#10-fase-4--polimento-modo-híbrido-performance-e-release)
11. [Matriz de Rastreabilidade PRD → Fases](#11-matriz-de-rastreabilidade-prd--fases)
12. [Riscos e Mitigações](#12-riscos-e-mitigações)
13. [Padrões Emprestados de Apps Existentes](#13-padrões-emprestados-de-apps-existentes)
14. [Definition of Done Global](#14-definition-of-done-global)

---

# 1. PRINCÍPIOS DO PLANO

1. **Offline-first é lei**: nenhuma funcionalidade P0 pode depender de internet em execução. Internet só para download de pacotes de idiomas (e, no futuro, modo híbrido).
2. **Fases curtas, entregas completas**: cada fase termina com algo **executável e testável** no aparelho Android físico (validação em modo avião).
3. **Poucas fases, muitas subfases**: 5 fases principais, decompostas em ~35 subfases verificáveis individualmente.
4. **Rastreabilidade total**: cada subfase cita os requisitos do PRD que satisfaz (`RF-M*`, `AC-M*`, `RN-*`, `UX-*`). A matriz da seção 11 fecha o ciclo.
5. **Tokens antes de telas**: nenhuma UI nasce antes do design system (cores/spaçamento/tipografia/i18n). Proibido `Color(0x…)` e string literal de UI fora dos arquivos de tokens.
6. **Camadas invioláveis**: `ui/` → ViewModels (`provider`/ChangeNotifier) → `core/services/` → plugins. A UI jamais importa plugin diretamente (RN do PRD §2).
7. **Erros nunca crus**: toda exceção de plugin é convertida em `AppException(code)` da tabela única de erros (PRD §4.8) com mensagem + ação sugerida.
8. **Privacidade como feature**: zero telemetria; logs só em debug; nenhum conteúdo do usuário sai do aparelho.

---

# 2. SÍNTESE DA ANÁLISE DO PRD

## 2.1 Módulos obrigatórios (todos P0 na v1)
| Módulo | Escopo | Motores |
|---|---|---|
| **M1 — Tradução de Texto** | Pares fechados `pt↔en`, `pt↔zh`, `en↔zh`; tradução automática com debounce 800 ms; limite 5.000 chars com fatiamento ≤ 4.500; botão ⇄; download de pacotes com progresso | `google_mlkit_translation` + Plano B `tflite_flutter` |
| **M2 — Entrada por Voz (STT)** | Ditado offline com modelos Vosk **embutidos**; resultados parciais em streaming; pausa 1,5 s encerra frase; máx. 60 s; permissão de microfone com fluxo completo | `vosk_flutter` |
| **M3 — Saída por Voz (TTS)** | Voz nativa do SO; checagem de voz instalada; aviso acionável se ausente; rate/pitch configuráveis; autoplay opcional | `flutter_tts` |
| **M4 — Dados e Conectividade** | Histórico FIFO 200 entradas com dedupe; favoritos ilimitados; busca + filtros por par; swipe-delete com desfazer 5 s; persistência `shared_preferences`; Gerenciador de Modelos; `ConnectionBadge`; modo híbrido nuvem (P2) | `shared_preferences`, `connectivity_plus`, `share_plus` (P1) |

## 2.2 Metas técnicas mensuráveis (do PRD §1.2, §4.4, §4.7)
| Métrica | Alvo |
|---|---|
| Latência de tradução (≤ 500 chars, pacote pronto) | ≤ 300 ms |
| Cold start | < 2 s |
| Início da escuta Vosk (modelo carregado) | ≤ 500 ms |
| Animações | 60 fps sem jank |
| APK base (sem modelos embutidos) | < 40 MB |
| APK completo (modelos embutidos) | ≤ 180 MB |
| Sucesso de traduções em modo avião | ≥ 95% |
| Crash-free sessions | > 99,9% |

## 2.3 Regras transversais que moldam a arquitetura
- `RN-01`: enum fechado `Language { pt, en, zh }` — sem extensão pela UI.
- `RN-02`: operação padrão 100% offline.
- `RN-03`: `AppException(code)` obrigatório na fronteira dos serviços.
- `RN-04`: cores somente em `app_colors.dart`; strings de UI somente em `app_strings.dart` (pt/en/zh).
- `RN-06`: `Semantics` em todo botão de ícone; contraste AA 4.5:1; toque ≥ 48 dp.
- `RN-07`: ciclo de vida — escuta morre em background; TTS continua até concluir.
- Responsividade: < 600 dp coluna única + `NavigationBar`; 600–1024 dp cartões lado a lado; ≥ 1024 dp conteúdo 720 dp + `NavigationRail`.

---

# 3. DESIGN SYSTEM — PALETA VERDE & BRANCO (LIGHT/DARK)

> **Decisão registrada**: o PRD §4.3 traz um exemplo *ilustrativo* de tokens com azul (`0xFF2563EB`) como primária. A diretriz vigente do produto fixa a identidade em **VERDE & BRANCO**. A arquitetura de tokens (nomes estáticos idênticos entre classes, fonte única `app_colors.dart`, `ThemeData` construído exclusivamente deles) permanece **exatamente** como especificada — apenas os valores hex mudam. Nenhum widget precisará ser tocado para ajustes futuros de paleta.

## 3.1 Tokens — Modo LIGHT (Verde sobre Branco)
| Token | Hex | Uso |
|---|---|---|
| `colorPrimary` | `0xFF16A34A` | Botões primários, pills ativas, foco, marca |
| `colorPrimaryContainer` | `0xFFDCFCE7` | Fundo de pills/seletores inativos, badges suaves |
| `colorOnPrimary` | `0xFFFFFFFF` | Texto/ícone sobre primária |
| `colorOnPrimaryContainer` | `0xFF14532A` | Texto sobre container verde claro |
| `colorSecondary` | `0xFF22C55E` | Acentos secundários, waveform, destaques |
| `colorBackground` | `0xFFF8FAFC` | Fundo geral (branco gelo) |
| `colorSurface` | `0xFFFFFFFF` | Cartões origem/destino, sheets (branco puro) |
| `colorTextPrimary` | `0xFF0F172A` | Textos principais |
| `colorTextSecondary` | `0xFF64748B` | Textos de apoio, contador n/5000, timestamps |
| `colorSuccess` | `0xFF16A34A` | Badge online 🟢, download concluído |
| `colorWarning` | `0xFFF59E0B` | Avisos (Wi-Fi restrito, voz ausente) |
| `colorError` | `0xFFEF4444` | Botão mic gravando, erros |
| `colorBorder` | `0xFFE2E8F0` | Bordas de cartões e inputs |
| `colorOverlay` | `0x66000000` | Scrim do overlay de escuta |

## 3.2 Tokens — Modo DARK (mesmos nomes, valores próprios)
| Token | Hex | Uso |
|---|---|---|
| `colorPrimary` | `0xFF4ADE80` | Primária clara p/ contraste em fundo escuro |
| `colorPrimaryContainer` | `0xFF14532A` | Containers/pills em dark |
| `colorOnPrimary` | `0xFF052E16` | Texto escuro sobre verde claro |
| `colorOnPrimaryContainer` | `0xFFBBF7D0` | Texto sobre container |
| `colorSecondary` | `0xFF22C55E` | Acentos |
| `colorBackground` | `0xFF0F172A` | Fundo geral |
| `colorSurface` | `0xFF1E293B` | Cartões/sheets |
| `colorTextPrimary` | `0xFFF1F5F9` | Textos principais |
| `colorTextSecondary` | `0xFF94A3B8` | Textos de apoio |
| `colorSuccess` | `0xFF4ADE80` | Badge online 🟢 |
| `colorWarning` | `0xFFFBBF24` | Avisos |
| `colorError` | `0xFFF87171` | Erros / mic gravando |
| `colorBorder` | `0xFF334155` | Bordas |
| `colorOverlay` | `0x99000000` | Scrim |

## 3.3 Regras de tema
1. `AppColorsLight` e `AppColorsDark` expõem **os mesmos nomes estáticos**; trocar de paleta = trocar de classe (UX-05).
2. `app_theme.dart` gera dois `ThemeData` (Material 3) consumindo **apenas** os tokens; seleção via `ThemeMode.system` (default) ou override manual em Ajustes.
3. Contraste AA auditado: texto branco sobre `0xFF16A34A` somente em componentes grandes (botões ≥ 18sp); onde 4.5:1 for exigido por texto normal, usar `0xFF15803D`.
4. Complementos tokenizados: `app_spacing.dart` (escala 4/8/16/24/32; raio padrão 12), `app_typography.dart` (títulos/corpo/botões), `app_strings.dart` (i18n pt/en/zh), `app_constants.dart`.

---

# 4. ARQUITETURA ALVO

Estrutura conforme PRD §2 (mantida integralmente):

```text
lib/
├── main.dart                  # MultiProvider + MaterialApp(AppTheme)
├── core/
│   ├── constants/             # app_colors / app_typography / app_spacing / app_strings / app_constants
│   ├── services/              # translation / stt / tts / model_manager / storage / connectivity
│   └── theme/                 # app_theme.dart
├── models/                    # language.dart / translation_record.dart / app_settings.dart
├── state/                     # translator / speech / tts / library ViewModels
└── ui/
    ├── screens/               # home / translate / history / settings / model_manager
    └── widgets/               # language_pill, translation_card, mic_button, waveform_indicator,
                               # mini_player_tts, download_progress_card, connection_badge...
```

**Regras de dependência (verificadas em code review e por análise estática):**
1. `ui/` não importa plugin algum — só ViewModels.
2. ViewModels importam só `core/services/` e `models/`; serviços não conhecem Widgets.
3. Imports ordenados: dart → flutter → packages → projeto.
4. Toda exceção cruza a fronteira de serviço convertida em `AppException(code)`.

**Dependências do `pubspec.yaml` (lista fechada do PRD — não substituir):**
`google_mlkit_translation` · `vosk_flutter` · `flutter_tts` · `tflite_flutter` · `shared_preferences` · `connectivity_plus` · `provider` · `permission_handler` · `path_provider` · `share_plus` (P1). Android `minSdk 23+`; iOS 12+.

---

# 5. ROADMAP MACRO — VISÃO DAS 5 FASES

| Fase | Nome | Cobre do PRD | Prioridade | Depende de | Estimativa* |
|---|---|---|---|---|---|
| **F0** | Fundação e Design System | §2 arquitetura, §4.3 tokens, RN-04/06, UX-05, base i18n/persistência/conectividade | P0 | — | ~1 semana |
| **F1** | Motor de Tradução Offline (M1) | §3.1 completo, US-1 (AC-M1-1…4), §4.8 erros M1 | P0 | F0 | ~2 semanas |
| **F2** | Voz Completa: STT + TTS (M2+M3) | §3.2 e §3.3 completas, US-2/US-3, §4.5 permissões, RN-07 | P0 | F1 | ~2–3 semanas |
| **F3** | Histórico, Favoritos, Ajustes e Conectividade (M4) | §3.4 completa, US-4 (AC-M4-1…5), Gerenciador de Modelos, tema light/dark toggle | P0 | F1 (sliders de voz: F2) | ~1–2 semanas |
| **F4** | Polimento, Híbrido, Performance e Release | P1 (share, dark refinado, NavigationRail), P2 (híbrido nuvem→local, Language ID opcional), §4.1/4.4/4.6/4.7, QA final modo avião | P1/P2 | F0–F3 | ~1–2 semanas |

\* Estimativa para 1 desenvolvedor sênior com ambiente Flutter/Android Studio pronto. F2 e F3 podem rodar parcialmente em paralelo após F1.

**Regra de saída de cada fase**: app compila, roda no Android físico, critérios de aceite da fase verificados em modo avião, `flutter analyze` sem warnings, testes da fase verdes.

---

# 6. FASE 0 — FUNDAÇÃO E DESIGN SYSTEM [CHECK]

> **Objetivo**: deixar o terreno pronto para que TODAS as fases seguintes sejam "só" feature: dependências fechadas, arquitetura de pastas viva, tokens Verde & Branco light/dark funcionando, i18n pt/en/zh, persistência e conectividade encapsulados, shell de navegação responsivo navegável e pipeline de qualidade rodando.

## Subfases

### F0.1 — Bootstrap do projeto
- Criar/validar `pubspec.yaml` com a lista fechada de dependências (§4 deste plano); travar versões compatíveis entre si.
- Configurar Android: `minSdk 23`, permissão `RECORD_AUDIO` declarada (uso só a partir da F2), `INTERNET` apenas para downloads de pacotes.
- Criar árvore de pastas exata do PRD §2 (`core/constants`, `core/services`, `core/theme`, `models`, `state`, `ui/screens`, `ui/widgets`, `test/services`, `test/state`) + `assets/models/{vosk-small-pt,vosk-small-en,vosk-small-zh,tflite}` registrados no pubspec.
- `analysis_options.yaml`: lints Flutter recomendados + regras de ordenação de imports.
- **Entregável**: `flutter run` abre app vazio no device; `flutter analyze` limpo.

### F0.2 — Tokens de cor Verde & Branco (`app_colors.dart`)
- Implementar `AppColorsLight` e `AppColorsDark` com os valores da seção 3 deste plano (mesmos nomes estáticos).
- Doc-comment mapeando cada token à variável CSS equivalente (`--color-primary` etc.), como pede o PRD.
- **Entregável**: arquivo único de paleta aprovado; nenhuma outra cor no projeto (checagem por grep).

### F0.3 — Tema light/dark (`app_theme.dart`)
- Dois `ThemeData` Material 3 construídos só dos tokens: `ColorScheme`, `AppBarTheme`, `CardTheme`, `ElevatedButton/FilledButton`, `InputDecorationTheme`, `SnackBarTheme`, `NavigationBarTheme`.
- `MaterialApp` com `theme:` / `darkTheme:` / `themeMode: ThemeMode.system`.
- **Entregável**: alternar tema escuro do emulador muda o app inteiro sem tocar em widget algum.

### F0.4 — Tipografia, espaçamento e constantes
- `app_typography.dart` (display/title/body/label), `app_spacing.dart` (4/8/16/24/32; raio 12), `app_constants.dart` (enum Language codes BCP-47 `pt-BR/en-US/zh-CN`, limite 5000 chars, bloco 4500, debounce tradução 800 ms, debounce gravação prefs 500 ms, FIFO 200, chaves `translatoo.*`, timeout nuvem 2000 ms).
- **Entregável**: constantes consumíveis por serviços/VMs sem magic numbers.

### F0.5 — i18n manual (`app_strings.dart`)
- Classe com lookup `AppStrings.of(context)` ou enum+mapa `{pt,en,zh}` cobrindo TODOS os textos previstos: títulos, botões, estados vazios, mensagens da tabela §4.8, textos de Ajustes.
- Idioma da UI = idioma do sistema com fallback pt-BR (v1); estrutura pronta para override futuro.
- **Entregável**: zero string literal de UI fora do arquivo (regra RN-04).

### F0.6 — Modelos de domínio
- `language.dart`: `enum Language { pt, en, zh }` com `displayName` nativo ("Português", "English", "中文"), código ML Kit e código TTS/Vosk.
- `translation_record.dart`: `{id, sourceText, translatedText, sourceLang, targetLang, timestamp, isFavorite}` com `toJson/fromJson`.
- `app_settings.dart`: imutável com `copyWith` (srcLang, tgtLang, ttsRate, ttsPitch, autoPlay, wifiOnly, cloudEnabled=false, themeMode, schemaVersion).
- **Entregável**: round-trip JSON testado.

### F0.7 — Serviços base
- `storage_service.dart`: ÚNICO acesso a `shared_preferences`; gravações agrupadas (debounce 500 ms); leitura tolera JSON corrompido (reinicia coleção + log debug); migração por `schemaVersion`.
- `connectivity_service.dart`: stream de `connectivity_plus` exposto como `ValueListenable<bool> isOnline`.
- `app_exception.dart`: códigos da tabela única de erros §4.8 + mensagem i18n + ação sugerida.
- **Entregável**: testes unitários de storage com mocks verdes.

### F0.8 — Shell de navegação e responsividade
- `home_screen.dart`: `NavigationBar` inferior com Traduzir/Histórico/Ajustes (telas placeholder), `SafeArea`, `ConnectionBadge` placeholder no AppBar.
- Breakpoints via `LayoutBuilder`: <600 dp coluna; 600–1024 dp preparado p/ cartões lado a lado; ≥1024 dp conteúdo 720 dp (rail entra na F4).
- **Entregável**: navegação funcional nos 3 breakpoints simulados (resize/emuladores).

### F0.9 — Pipeline de qualidade
- Testes base dos modelos/serviços; comando padrão documentado: `flutter analyze && dart format --set-exit-if-changed . && flutter test`.
- README técnico curto (setup, comandos, regras de camada).
- **Critérios de aceite da fase**:
  - AC-F0-1: app roda light/dark seguindo o sistema, 100% das cores vindas de tokens.
  - AC-F0-2: idioma do sistema pt/en/zh troca textos da UI.
  - AC-F0-3: storage salva/lê settings sobrevivendo a restart.
  - AC-F0-4: analyze/format/test todos verdes.

---

# 7. FASE 1 — MOTOR DE TRADUÇÃO OFFLINE (M1)

> **Objetivo**: entregar o coração do produto — traduzir texto PT⇄EN⇄ZH 100% on-device, com download gerenciado de pacotes e Plano B para aparelhos sem Google Play Services (cenário China). Ao fim desta fase o app já é utilizável como tradutor de texto em modo avião.

## Subfases

### F1.1 — Contrato de backend (`TranslationBackend`)
- Interface abstrata `translate({source, target, text})` + `isReady(pair)`; implementações futuras: `MlKitBackend`, `TFLiteBackend`, `CloudBackend` (F4).
- Isolar aqui a conversão de qualquer exceção de plugin → `AppException(code)` (`ERR_TRANSLATION_FAILED`, `ERR_MODEL_NOT_DOWNLOADED`).
- **Entregável**: contrato compilando + testado com fake.

### F1.2 — `TranslationService` com ML Kit
- Wrapper de `google_mlkit_translation`: criação/ciclo de vida do `OnDeviceTranslator`, verificação `isModelDownloaded` para origem e destino antes de traduzir.
- **Fatiamento** (RF-M1-05): texto > limite → blocos ≤ 4.500 chars cortados em quebras de parágrafo/frase/espaço, tradução sequencial, concatenação preservando ordem.
- Medição de latência interna (alvo ≤ 300 ms) logada só em debug (RN-05).
- **Entregável**: tradução real funcionando no device com pacotes baixados manualmente.

### F1.3 — `ModelManagerService` (download/exclusão)
- `downloadModel` com stream de progresso (%), `cancelDownloadModel`, `deleteRemoteModel`, consulta de estado por idioma (`notDownloaded | downloading(n%) | ready`).
- Respeitar `wifiOnly`: se rede = dados móveis → `ERR_WIFI_ONLY` com decisão "Baixar mesmo assim" vinda da UI (sem alterar a preferência).
- Tamanho estimado ~30 MB exibido pela UI (constante).
- **Entregável**: baixar/cancelar/excluir pacote pt/zh via tela temporária de debug.

### F1.4 — Plano B TFLite (spike + integração) — RF-M1-07 / AC-M1-4
- **Spike de pesquisa**: escolher modelo NMT compacto convertível p/ LiteRT (ex.: família Marian/OPUS-MT destilada ou CTranslate2→TFLite) cobrindo os 3 pares; documentar trade-off tamanho × qualidade no PRD-apêndice.
- `TFLiteBackend` carregando modelo de `assets/models/tflite/`; detecção de ausência de GMS (tentativa ML Kit falha) → fallback transparente + flag interna `alternativeEngine=true`.
- UI nunca vê stacktrace: apenas badge discreto "motor alternativo".
- **Limitação honesta**: qualidade inferior ao ML Kit é aceitável e documentada; se nenhum modelo viável for encontrado na spike, o fallback fica atrás da mesma interface com feature-flag desligada e nota técnica — o fluxo AC-M1-4 permanece testável via mock.
- **Entregável**: app traduzindo em device sem Play Services (ou flag documentada).

### F1.5 — `TranslatorViewModel`
- Estado observável: `status ∈ {idle, typing, translating, done, error}`, `modelStatus: Map<LanguagePair, ModelState>`, textos, par de idiomas.
- Debounce 800 ms em `onTextChanged()` (≥ 1 char); `translateNow()` ignora debounce; `swapLanguages()` troca idiomas E textos e retraduz; bloqueios durante `translating`; `acceptDictatedText()` (gancho p/ F2) dispara tradução imediata.
- Rebuild cirúrgico com `Selector`/`context.select` — jamais `Consumer` inteiro nos campos de texto (evita perder foco/cursor).
- Persistência do último par delegada à F3 (`settings.srcLang/tgtLang`) — por ora, memória.
- **Entregável**: VM com testes unitários (fake backend) cobrindo debounce, swap, erro.

### F1.6 — UI da tela Traduzir (mobile-first)
- Cartão Origem: pill de idioma (canto sup. esq.), limpar ✕, `TextField` multilinha auto-expansível, contador `n/5000` com truncamento + aviso, linha de ações 🎤 (placeholder F2) · colar 📋.
- Botão ⇄ circular central 56 dp elevação 2, desabilitado durante tradução.
- Cartão Destino: pill, área somente-leitura, skeleton shimmer enquanto `translating`, linha 🔊 (placeholder F3) · copiar · ⭐ (placeholder F3) · compartilhar (placeholder F4).
- `DownloadProgressCard` sobreposto quando modelo ausente: nome do idioma, barra %, "~30 MB", Baixar/Cancelar; retomada automática da tradução pendente após download (AC-M1-2).
- Botão Traduzir primário verde, largura total do cartão origem; AppBar com logo + badge placeholder.
- **Entregável**: tela completa conforme PRD §3.1, tokens Verde & Branco.

### F1.7 — Widgets compartilhados
- `language_pill.dart` (seletor com menu dos 3 idiomas), `translation_card.dart`, `download_progress_card.dart`, `connection_badge.dart` (visual placeholder), componente de skeleton shimmer reutilizável.
- Todos com `Semantics` (RN-06) e alvos ≥ 48 dp.

### F1.8 — Qualidade da fase
- Testes: VM (debounce/swap/truncamento/fatiamento), serviço com mock de plugin, widget test da tela Traduzir.
- **Critérios de aceite da fase** (= US-1 do PRD):
  - AC-F1-1 ≙ AC-M1-1: modo avião, pacotes prontos, "Bom dia" PT→ZH traduzido ≤ 300 ms pós-debounce.
  - AC-F1-2 ≙ AC-M1-2: idioma sem pacote → card de progresso → "Pronto" → tradução pendente executa sozinha.
  - AC-F1-3 ≙ AC-M1-3: ⇄ inverte idiomas+textos e retraduz.
  - AC-F1-4 ≙ AC-M1-4: sem GMS → motor alternativo, sem stacktrace.
  - AC-F1-5: erros de rede/download exibem mensagem da tabela §4.8 com ação sugerida.

---

# 8. FASE 2 — VOZ COMPLETA: DITADO STT + LEITURA TTS (M2+M3)

> **Objetivo**: fechar o ciclo conversacional — o usuário fala (Vosk offline) e ouve a tradução (motor nativo do SO). Inclui permissões, modelos embutidos, overlay de escuta animado, mini-player e integração automática fala→tradução→fala.

## Subfases

### F2.1 — Aquisição e embutimento dos modelos Vosk
- Baixar os modelos *small* oficiais (alphacephei): `vosk-model-small-pt-0.3`, `vosk-model-small-en-us-0.15`, `vosk-model-small-cn-0.22` (~40–50 MB cada).
- Colocar em `assets/models/vosk-small-{pt,en,zh}`; no primeiro uso, copiar para diretório de dados (`path_provider`) — Vosk exige caminho real de arquivo.
- Criar **flavor "full"** (modelos embutidos ≤ 180 MB) vs **flavor "lite"** (sem STT embutido, APK < 40 MB), conforme PRD §4.7.
- **Entregável**: assets versionados + script/README de atualização dos modelos.

### F2.2 — `SttService` (wrapper vosk_flutter)
- Carregar modelo on-demand pelo idioma de ORIGEM; expor estado `initializing` na primeira carga.
- API: `start(lang)`, `stop()`, `cancel()`; stream com resultados **parciais** e **finais**.
- Regras RF-M2-05/06: fim de fala por pausa ≥ 1,5 s encerra frase; limite duro de 60 s com auto-stop usando o último resultado final.
- Erros → `ERR_STT_ENGINE`; nenhum stacktrace à UI.
- **Entregável**: transcrição real PT/EN/ZH no console do app de debug.

### F2.3 — Permissão de microfone e ciclo de vida
- `permission_handler`: solicitar `RECORD_AUDIO` ao tocar no 🎤 com diálogo explicativo prévio; negação permanente → diálogo com "Abrir configurações" (`openAppSettings()`); mapear para `ERR_MIC_PERMISSION`.
- RN-07: `AppLifecycleListener` — app em background durante escuta → finalizar com último resultado parcial; cancelar descarta e restaura texto anterior.
- iOS: `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` no Info.plist.
- **Entregável**: fluxo completo de permissão testado (conceder/negar/negar permanente).

### F2.4 — `SpeechViewModel`
- Máquina de estados `SpeechState { idle, initializing, listening, processing, error }` com transições inválidas ignoradas.
- Campos: `partialText`, `finalText`, `elapsedSeconds`, `errorMessage`.
- Ao emitir final → chama `TranslatorViewModel.acceptDictatedText(text)` (tradução imediata, ignora debounce).
- Durante escuta: TTS silenciado + campo de digitação desabilitado (RF-M2-07).
- **Entregável**: VM testada com fake do SttService (parciais, timeout 60 s, cancelamento).

### F2.5 — UI de ditado
- `mic_button.dart`: 3 estados — idle (outline verde) · listening (preenchido `colorError` vermelho + anel pulsante + waveform) · error (badge ! + tooltip).
- Overlay bottom-sheet de escuta: scrim `colorOverlay`, texto parcial grande rolável (estilo itálico/cor secundária enquanto parcial), timer mm:ss, waveform animada, botões **Cancelar** e **Concluir**.
- Feedback háptico curto ao iniciar/encerrar; `AnimationController` único p/ pulso+waveform (meta 60 fps).
- **Entregável**: experiência de ditado fluida conforme PRD §3.2.

### F2.6 — `TtsService` (wrapper flutter_tts)
- Fala exclusivamente com motor nativo do SO; idioma = idioma de DESTINO.
- Checagem prévia: `isLanguageAvailable`/`getVoices` → cache `voiceAvailable[lang]`; ausente → `ERR_TTS_VOICE_MISSING` com instrução explícita de instalação da voz no sistema + atalho p/ configurações do aparelho (SnackBar persistente; app não trava).
- Fila única: novo `speak()` sempre executa `stop()` antes; handlers `onComplete/onError` devolvem ao estado idle.
- Parâmetros `rate ∈ [0.5–2.0]` (default 1.0) e `pitch ∈ [0.5–1.5]` (default 1.0).
- **Entregável**: reprodução audível PT/EN/ZH no device com voz instalada; aviso correto sem voz.

### F2.7 — `TtsViewModel`
- Estados `{idle, speaking}`; debounce anti duplo-toque (mesmo texto ≤ 300 ms é idempotente).
- Autoplay (default OFF): tradução concluída é falada se ativado; traduções originadas de ditado SEMPRE reproduzem automaticamente (fluxo conversacional), independentemente do autoplay (RF-M3-06).
- Cache `voiceAvailable` atualizado na abertura do app e ao voltar de segundo plano.
- **Entregável**: VM testada (fila única, autoplay condicional, erro de voz).

### F2.8 — UI de reprodução
- Botão 🔊 no cartão destino alternando ▶/⏹ conforme estado; desabilitado com resultado vazio.
- `mini_player_tts.dart`: barra inferior durante reprodução — ícone animado, trecho falado com scroll horizontal, stop.
- Painel de voz (sliders rotulados velocidade/tom com valor numérico) já funcional em tela de debug; migra para Ajustes na F3.
- **Entregável**: UX de áudio completa conforme PRD §3.3.

### F2.9 — Integração M2×M3×M1 e qualidade da fase
- Orquestração conversacional completa: 🎤 → texto → tradução automática → 🔊 automático (ditado).
- Testes de integração dos três ViewModels com services fakeados.
- **Critérios de aceite da fase** (= US-2 e US-3 do PRD):
  - AC-F2-1 ≙ AC-M2-1: ditado PT mostra parciais em tempo real e dispara tradução após ~1,5 s de pausa.
  - AC-F2-2 ≙ AC-M2-2: permissão negada permanente → diálogo explicativo, app utilizável.
  - AC-F2-3 ≙ AC-M2-3: auto-stop aos 60 s mantendo último resultado final.
  - AC-F2-4 ≙ AC-M2-4: Cancelar restaura texto anterior, nada é traduzido.
  - AC-F2-5 ≙ AC-M3-1..3: 🔊 fala mandarim nativo, alterna ▶/⏹, nova reprodução interrompe a anterior, voz ausente → SnackBar acionável sem travar.
  - AC-F2-6 ≙ RN-07: background durante escuta encerra com parcial; TTS continua até fim/interrupção do SO.

---

# 9. FASE 3 — HISTÓRICO, FAVORITOS, AJUSTES E CONECTIVIDADE (M4)

> **Objetivo**: dar memória e personalidade ao app — tudo que o usuário faz é recuperável, toda preferência sobrevive ao restart, o gerenciamento de pacotes de idiomas fica nas mãos dele e o tema light/dark passa a ter toggle manual.

## Subfases

### F3.1 — `LibraryViewModel` + regras de dados
- `addRecord()`: salva toda tradução concluída com dedupe (mesma origem + mesmo par na última entrada → atualiza timestamp/resultado).
- Capacidade: histórico FIFO de **200** entradas; favoritos ilimitados e nunca descartados automaticamente.
- `delete(id)` + `undoDelete()` (restaura posição original); `clearHistory()` NÃO apaga favoritos.
- `search(q)` case-insensitive em origem OU tradução; `filterBy(pair)` com chips `Todos / PT↔EN / PT↔ZH / EN↔ZH`.
- Erros de persistência → `ERR_STORAGE` ("Não foi possível salvar" → Repetir ação).
- **Entregável**: VM 100% coberta por testes unitários (dedupe, FIFO, undo, filtros).

### F3.2 — Tela Histórico
- Cards: texto origem (cor secundária), tradução em destaque, pills dos idiomas, horário relativo ("há 5 min"), ⭐ quando favorito; toque reabre no Tradutor (preenche cartões + par).
- Barra de busca fixa no topo + chips de filtro horizontais scrolláveis.
- Swipe-to-delete individual + SnackBar "Desfazer" por 5 s; "Limpar tudo" com diálogo de confirmação.
- Estado vazio ilustrado ("Suas traduções aparecerão aqui").
- **Entregável**: tela completa conforme PRD §3.4.

### F3.3 — Tela Ajustes
- Itens RF-M4-09: par de idiomas padrão · autoplay TTS (switch) · sliders velocidade/tom ligados à `TtsViewModel` da F2 · somente Wi-Fi (switch) · link Gerenciar Modelos · limpar histórico (confirmado) · versão do app · declaração "Nenhum dado sai do seu aparelho".
- **Seletor de tema**: Sistema / Claro / Escuro (persistido) — ativa o override manual sobre o `ThemeMode.system` default da F0.
- **Entregável**: ajustes funcionais persistindo via `StorageService`.

### F3.4 — Gerenciador de Modelos (`model_manager_screen.dart`)
- Lista dos 3 idiomas com estado real (`Não baixado · Baixando n% · Pronto`), tamanho ~30 MB, ações Baixar/Excluir (usa `ModelManagerService` da F1.3).
- Bloqueio Wi-Fi-only em dados móveis: aviso explicativo + "Baixar mesmo assim" sem alterar a preferência (RF-M4-06 / AC-M4-4).
- **Entregável**: gestão completa de pacotes pela UI.

### F3.5 — Conectividade visível
- `ConnectionBadge` real no AppBar (🟢 online / ⚪ offline) alimentado pelo `ConnectivityService` (`ValueListenable`, sem rebuild das telas); tooltip explicativo.
- Regra crítica verificada em todos os fluxos: **nada é bloqueado offline** (traduzir/ditar/ouvir/histórico funcionam em modo avião).

### F3.6 — Persistência integral
- Chaves finais `translatoo.*`: history, favorites, settings.srcLang/tgtLang, ttsRate/ttsPitch/autoPlay, wifiOnly, themeMode, schemaVersion.
- Restauração no boot: último par de idiomas, preferências de voz, histórico e favoritos exatamente como deixados (AC-M4-3).
- **Entregável**: restart completo do app/aparelho preserva 100% do estado.

### F3.7 — Qualidade da fase
- Testes de VM/storage; widget tests das telas Histórico/Ajustes/Gerenciador.
- **Critérios de aceite da fase** (= US-4 do PRD):
  - AC-F3-1 ≙ AC-M4-1: 3 traduções → lista ordenada mais recente→antiga com origem/tradução/pills/horário relativo.
  - AC-F3-2 ≙ AC-M4-2: swipe-excluir + Desfazer 5 s restaurando posição.
  - AC-F3-3 ≙ AC-M4-3: kill do app → par, voz, histórico e favoritos intactos.
  - AC-F3-4 ≙ AC-M4-4: wifiOnly + dados móveis → aviso + download forçado opcional.
  - AC-F3-5 ≙ AC-M4-5: modo avião total → ConnectionBadge offline e TODAS as funções operantes.
  - AC-F3-6: alternância de tema manual persiste e não exige refactor (troca só de classe de tokens).

---

# 10. FASE 4 — POLIMENTO, MODO HÍBRIDO, PERFORMANCE E RELEASE

> **Objetivo**: transformar o app funcional em produto publicável — responsividade completa (tablet/desktop), compartilhamento, modo híbrido nuvem→local atrás de flag, metas de performance auditadas, acessibilidade, QA exaustivo em modo avião e build de release assinado.

## Subfases

### F4.1 — Compartilhar tradução (P1)
- Ligar o botão de compartilhar do cartão destino via `share_plus` (texto + par de idiomas).
- **Entregável**: share sheet nativo funcionando offline.

### F4.2 — Responsividade avançada
- 600–1024 dp: cartões origem/destino lado a lado horizontalmente.
- ≥ 1024 dp: conteúdo centralizado (`maxWidth` 720) + `NavigationRail` à esquerda substituindo a barra inferior.
- Validação visual mínima em 320 dp de largura (UX-04: uma mão, alvos ≥ 48 dp).
- **Entregável**: os 3 layouts aprovados (celular pequeno, tablet, desktop/web).

### F4.3 — Modo híbrido nuvem→local (P2 — RF-M4-08)
- `CloudBackend` implementando `TranslationBackend`: quando `isOnline && cloudEnabled`, tentar API em nuvem com **timeout de 2 s**; qualquer erro/timeout → fallback silencioso ao motor on-device + badge discreto "local" no resultado.
- `cloudEnabled = false` por padrão na v1; provedor de API abstrato (decisão comercial posterior).
- Opcional (se sobrar folga): detecção automática de idioma com ML Kit Language ID pré-selecionando origem.
- **Entregável**: flag testável ligada/desligada sem regressão offline.

### F4.4 — Performance auditada (§4.4)
- Perfis com DevTools: cold start < 2 s; tradução ≤ 300 ms (≤ 500 chars); início de escuta ≤ 500 ms (modelo carregado); animações 60 fps.
- Otimizações típicas: lazy-load dos modelos Vosk (só no primeiro uso), pré-aquecimento do translator, evitar rebuilds globais (já garantido por `Selector`), const widgets.
- **Entregável**: relatório curto de medições vs metas.

### F4.5 — Acessibilidade e privacidade (RN-05/06, §4.5)
- `Semantics` completo, contraste AA verificado nas duas paletas (ferramenta de auditoria), foco/ordem de tabulação coerentes.
- Revisão final de permissões (mínimo necessário), política de privacidade na loja coerente com "zero coleta".
- **Entregável**: checklist de acessibilidade 100%.

### F4.6 — QA final e compatibilidade
- Bateria completa dos 16 ACs do PRD em Android físico, incluindo:
  - Modo avião total (todas as funções);
  - Dispositivo/aparelho sem Google Play Services (Plano B TFLite + Vosk);
  - Perda de rede durante download de pacote;
  - Background/foreground durante escuta e reprodução;
  - JSON corrompido no storage (reinício limpo);
  - Tamanhos: APK base < 40 MB · APK full ≤ 180 MB.
- Correção de bugs priorizada por severidade; zero exceção crua na UI.
- **Entregável**: planilha de execução de ACs assinada.

### F4.7 — Release
- Build de release Android: assinatura keystore, `--obfuscate --split-debug-info`, split por ABI; iOS: archive/TestFlight (secundário).
- Store listing: screenshots light/dark, descrição enfatizando privacidade/offline, notas da v1.0.
- Versionamento `1.0.0+1`; tag git de release.
- **Critérios de aceite da fase**:
  - AC-F4-1: todos os DoD das fases anteriores seguem verdes após refactors de responsividade.
  - AC-F4-2: APK/AAB de release instalado de fábrica funciona offline do primeiro uso (após baixar pacotes uma única vez com internet).
  - AC-F4-3: metas §4.4 confirmadas em device médio (ex.: classe Snapdragon 6xx).

---

# 11. MATRIZ DE RASTREABILIDADE PRD → FASES

| Requisito do PRD | Fase.Subfase | Observação |
|---|---|---|
| UX-01..06 (metas de experiência) | F0.2–F0.8, F1.5–F1.7, F4.2, F4.4 | Tokens, rebuild cirúrgico, alvos 48 dp |
| RF-M1-01..09 + AC-M1-1..4 (M1) | F1.1–F1.8 | Núcleo da tradução |
| RN-01 (enum fechado) / RN-02 (offline) | F0.6 / transversal | Verificado em todas as fases |
| RN-03 + tabela §4.8 (erros) | F0.7, F1.1, F2.2, F2.3, F2.6, F3.1 | `AppException(code)` na fronteira |
| RF-M2-01..07 + AC-M2-1..4 (M2) | F2.1–F2.5 | Vosk embutido |
| RF-M3-01..06 + AC-M3-1..4 (M3) | F2.6–F2.9 | TTS nativo |
| RF-M4-01..07 + AC-M4-1..5 (M4) | F3.1–F3.7 | Dados/ajustes/conectividade |
| RF-M4-08 híbrido nuvem (P2) | F4.3 | Flag `cloudEnabled=false` |
| §4.1 responsividade 3 breakpoints | F0.8, F4.2 | Rail na F4.2 |
| §4.2 armazenamento local | F0.7, F3.6 | Só `shared_preferences` via serviço |
| §4.3 tokens de cor (+ paleta Verde/Branco light/dark) | F0.2, F0.3, seção 3 deste plano | Valores adaptados à diretriz Verde & Branco |
| §4.4 performance / §4.6 compatibilidade / §4.7 tamanho | F2.1, F4.4, F4.6 | Flavors full/lite |
| §4.5 privacidade/permissões | F2.3, F4.5 | iOS Info.plist incluso |
| P1 share_plus · dark mode refinado · NavigationRail | F4.1 / F3.3+F0.3 / F4.2 | Dark já nasce na fundação por decisão do produto |

---

# 12. RISCOS E MITIGAÇÕES

| # | Risco | Prob. | Impacto | Mitigação |
|---|---|---|---|---|
| R1 | Plano B TFLite: não existir modelo NMT compacto viável p/ os 3 pares | Média | Alto | Spike cedo (F1.4); interface `TranslationBackend` isola o motor; feature-flag e nota técnica se inviável; ML Kit continua cobrindo a maioria dos devices |
| R2 | Modelos Vosk estouram o limite de loja (180 MB full) | Baixa | Médio | Flavors lite/full; download sob demanda como alternativa futura |
| R3 | Voz chinesa TTS ausente em muitos aparelhos | Alta | Médio | Fluxo AC-M3-2 já previsto: SnackBar persistente + atalho às configurações do SO |
| R4 | Latência > 300 ms em devices fracos | Média | Médio | Pré-aquecimento, medição desde F1.2, chunking eficiente |
| R5 | Incompatibilidade entre versões dos plugins ML Kit/Vosk/TTS | Média | Alto | Versões travadas no pubspec; upgrade só com regressão completa |
| R6 | OneDrive sincronizando `build/` e assets grandes | Média | Baixo/Médio | `.gitignore` robusto; considerar mover projeto fora de pasta sincronizada antes do release |
| R7 | Perda de foco/cursor por rebuild excessivo nos campos de texto | Média | Médio | Regra arquitetural F1.5 (`Selector`/`context.select`), widget test dedicado |

---

# 13. PADRÕES EMPRESTADOS DE APPS EXISTENTES

| App | Padrão adotado no Translatoo |
|---|---|
| **Google Translate** | Cartões duplos origem/destino com ⇄ central; download on-demand de pacotes offline com % ; tradução automática ao digitar (nosso debounce 800 ms) |
| **Microsoft Translator** | Estados claros de "baixando/pronto" por idioma; foco em uso sem conectividade |
| **Papago (Naver)** | Atenção especial ao par PT⇄ZH: exibição cuidadosa de chinês (fonte adequada, quebras), áudio nativo mandarim |
| **DeepL** | Hierarquia limpa: texto traduzido é o herói visual; ações secundárias discretas (copiar/favoritar/compartilhar) |
| **iTranslate** | Sliders de velocidade/tom para aprendizado de pronúncia; autoplay conversacional |

---

# 14. DEFINITION OF DONE GLOBAL

Uma funcionalidade só está pronta quando **tudo** isto vale (herdado do PRD §6.2):
1. `flutter analyze` sem warnings; código formatado (`dart format`).
2. Testes unitários dos ViewModels/serviços envolvidos passando (`flutter test`).
3. Critérios de aceite do módulo verificados manualmente em Android físico.
4. Nenhuma cor fora de `app_colors.dart`; nenhuma string de UI fora de `app_strings.dart`.
5. Funcionamento validado em modo avião.
6. Erros mapeados para a tabela §4.8 — nenhuma exceção crua na UI.

## Comando padrão de validação (rodar ao fim de cada subfase)
```bash
flutter clean && flutter pub get
flutter analyze
dart format --set-exit-if-changed .
flutter test
flutter run --release   # validação manual no device
```

## Marcos de entrega
| Marco | Conteúdo |
|---|---|
| **M-F0** | Design system verde/branco light+dark navegável |
| **M-F1** | Tradutor de texto completo offline (usável em modo avião) |
| **M-F2** | Ciclo conversacional fala→tradução→áudio fechado |
| **M-F3** | Produto completo v1 (memória, ajustes, modelos, tema) |
| **M-F4** | Release candidate assinada → **v1.0.0** |

---
*Plano gerado a partir do `PRD.md` v1.0 — Translatoo (2026-08-26). Alterações de escopo devem refletir aqui E no PRD.*







