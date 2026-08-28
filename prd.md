# PRD — TRANSLATOO
## Documento de Requisitos do Produto — Aplicativo de Tradução Offline (Português · Inglês · Mandarim)

| Campo | Valor |
|---|---|
| **Produto** | Translatoo |
| **Versão do documento** | 1.1 |
| **Data** | 2026-08-28 |
| **Histórico** | v1.0 (2026-08-26) · v1.1 — ver §7 Registro de Revisões |
| **Stack obrigatória** | Dart + Flutter (exclusivamente) |
| **Plataformas-alvo** | Android (prioridade máxima), iOS (secundária), Desktop/Web (terciária) |
| **Idiomas suportados** | Português (`pt`), Inglês (`en`), Chinês Mandarim (`zh`) |
| **Documento-fonte complementar** | `share.txt` (decisões de arquitetura offline/on-device) |
| **Público deste documento** | IA de programação (Cursor/Windsurf) e desenvolvedores Flutter |

---

## SUMÁRIO
1. [Objetivo e Visão Geral](#1-objetivo-e-visão-geral)
2. [Arquitetura de Arquivos Sugerida](#2-arquitetura-de-arquivos-sugerida)
3. [Escopo do Produto (Requisitos Funcionais)](#3-escopo-do-produto-requisitos-funcionais)
4. [Requisitos Não-Funcionais](#4-requisitos-não-funcionais-especificações-técnicas)
5. [Critérios de Aceite (User Stories)](#5-critérios-de-aceite-user-stories)
6. [Roadmap, Prioridades e Definição de Pronto](#6-roadmap-prioridades-e-definição-de-pronto)
7. [Registro de Revisões](#7-registro-de-revisões)

---

# 1. OBJETIVO E VISÃO GERAL

## 1.1 Propósito do Aplicativo
O Translatoo é um aplicativo de tradução **offline-first** entre **Português (pt-BR)**, **Inglês (en-US)** e **Chinês Mandarim (zh-CN)**, capaz de operar a 100% sem internet após o download inicial dos pacotes de idiomas.

Objetivos centrais:
- **Traduzir texto instantaneamente no dispositivo (on-device)** usando Google ML Kit (`google_mlkit_translation`), sem enviar dados para servidores.
- **Garantir funcionamento em celulares chineses nativos (Xiaomi, Huawei, Vivo locais)**. ⚠️ **Correção v1.1**: o plugin `google_mlkit_translation` usa o SDK **standalone** (`com.google.mlkit:translate`), empacotado no próprio APK — ele **NÃO depende de Google Play Services** e funciona nesses aparelhos. O risco real não é a ausência de GMS, e sim o **download dos pacotes de idioma (~30 MB) a partir de servidores do Google, potencialmente inacessíveis na China**. É esse cenário — e só ele — que o Plano B TFLite (`tflite_flutter`, modelo embutido em `assets`) existe para cobrir.
- **Entrada por voz offline (Speech-to-Text)** com modelos acústicos embarcados no aplicativo. ⚠️ **Status v1.1**: o motor está **pendente de decisão técnica**. O `vosk_flutter` (0.3.48) declara `sdk <3.0.0` e **não resolve com Dart 3**, estando comentado no `pubspec.yaml`. A escolha do motor sai da spike **F2.0** do plano de implementação (candidatos: fork do `vosk_flutter`, `sherpa-onnx`, `whisper.cpp`). O requisito de produto — ditado 100% offline, sem depender de configuração do SO — permanece inalterado; apenas a implementação está em aberto.
- **Saída por voz (Text-to-Speech)** via motor nativo do sistema operacional (`flutter_tts`), sem consumo de internet.
- **Privacidade total**: nenhum texto ou áudio sai do aparelho na operação padrão.
- **Arquitetura híbrida preparada (Fase 2)**: quando houver internet, o app poderá usar API em nuvem para maior qualidade; sem internet, faz fallback silencioso para os motores locais (`connectivity_plus`).

## 1.2 Metas de Experiência do Usuário (UX/UI)
| ID | Meta | Critério mensurável |
|---|---|---|
| UX-01 | Tradução percebida como instantânea | Resultado exibido em ≤ 300 ms (pós-download dos pacotes) para textos ≤ 500 caracteres |
| UX-02 | Máximo 2 toques para qualquer ação principal | Traduzir, ouvir, copiar e favoritar exigem ≤ 2 toques a partir da tela inicial |
| UX-03 | Zero ambiguidade de estado | Todo processo longo exibe indicador visual: baixando modelo (%), ouvindo (pulso), traduzindo (spinner) |
| UX-04 | Uso com uma mão | Alvos de toque ≥ 48×48 dp; ações primárias no terço inferior da tela em layout compacto |
| UX-05 | Tema remapeável sem refatoração | 100% das cores vindas de um único arquivo de tokens (`app_colors.dart`), equivalente às variáveis CSS |
| UX-06 | Feedback de erro acionável | Todo erro mostra mensagem clara + ação sugerida (ex.: "Abrir configurações") |

## 1.3 Métricas de Sucesso

> **Decisão v1.1 — como estas métricas são medidas.** O produto adota **zero telemetria** (RN-05, §4.5): não há coleta de crashes, latências ou contagem de sessões. Portanto nenhuma métrica abaixo pode ser apurada em campo. Todas são **metas de qualidade verificadas em bateria de QA manual** (plano de implementação, F4.6), com amostra e roteiro definidos — não são indicadores de produção. A promessa de privacidade prevalece sobre a observabilidade: é o diferencial competitivo do produto (§4.2).

| ID | Meta | Como é verificada |
|---|---|---|
| MS-01 | ≥ 95% das traduções concluídas sem erro em modo avião | QA manual: roteiro de **40 traduções** (frases curtas/médias/longas × 3 pares) em modo avião, com pacotes prontos. Aprovado com ≤ 2 falhas |
| MS-02 | Tempo médio de tradução ≤ 300 ms (on-device, pacote pronto) | Medição via DevTools em device de referência classe média (ex.: Snapdragon 6xx), amostra de 20 traduções ≤ 500 chars (F4.4) |
| MS-03 | 0 (zero) envio de conteúdo do usuário para servidores | Auditoria de tráfego com proxy durante a bateria de QA: nenhuma requisição além do download de pacotes ML Kit |
| MS-04 | Estabilidade: nenhum crash na bateria de QA | Execução completa dos ACs (F4.6) sem crash. **Não** é medível como "% de sessões" sem telemetria |

## 1.4 Fora do Escopo (v1)
Tradução de imagem/câmera (OCR), modo conversa dupla em tempo real, login/contas, sincronização em nuvem, anúncios, detecção automática de idioma (Planejado P2 via ML Kit Language ID), loja de frases pré-traduzidas.

---

# 2. ARQUITETURA DE ARQUIVOS SUGERIDA

Estrutura em camadas simples, compatível com os diretórios já existentes no projeto (`lib/core/constants`, `lib/core/services`, `lib/core/theme`).

```text
translatoo/
├── assets/
│   ├── fonts/                           # Subset Noto Sans SC — fallback CJK (§4.9)
│   └── models/                          # Modelos embutidos (offline garantido)
│       ├── stt-pt/                      # Modelo acústico STT Português (~50 MB)
│       ├── stt-en/                      # Modelo acústico STT Inglês
│       ├── stt-zh/                      # Modelo acústico STT Mandarim
│       │                                # (nomes definitivos após a spike F2.0;
│       │                                #  hoje `vosk-small-*` no repositório)
│       └── tflite/                      # (Plano B) modelo de tradução TFLite embutido
├── lib/
│   ├── main.dart                        # Bootstrap: MultiProvider + MaterialApp(AppTheme)
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # 🎨 TOKENS DE COR — FONTE ÚNICA DA PALETA
│   │   │   ├── app_typography.dart      # Estilos de texto (títulos, corpo, botões)
│   │   │   ├── app_spacing.dart         # Tokens de espaçamento/radius (4/8/16/24)
│   │   │   ├── app_strings.dart         # Todos os textos da UI em pt/en/zh (i18n manual)
│   │   │   └── app_constants.dart       # Códigos de idioma, limites de chars, chaves prefs
│   │   ├── services/
│   │   │   ├── translation_service.dart # Wrapper google_mlkit_translation (+ fallback TFLite)
│   │   │   ├── stt_service.dart         # Wrapper do motor STT (microfone → texto)
│   │   │   ├── tts_service.dart         # Wrapper flutter_tts (texto → áudio nativo)
│   │   │   ├── model_manager_service.dart # Download/exclusão dos pacotes ML Kit
│   │   │   ├── storage_service.dart     # Camada única sobre shared_preferences
│   │   │   └── connectivity_service.dart# Stream online/offline (connectivity_plus)
│   │   └── theme/
│   │       └── app_theme.dart           # ThemeData construído EXCLUSIVAMENTE dos tokens
│   ├── models/
│   │   ├── language.dart                # enum Language { pt, en, zh } + metadados (nome)
│   │   ├── translation_record.dart      # Registro de histórico/favorito (serializável JSON)
│   │   └── app_settings.dart            # Preferências persistidas do usuário
│   ├── state/
│   │   ├── translator_view_model.dart   # Módulo 1 — ChangeNotifier
│   │   ├── speech_view_model.dart       # Máquina de estados do microfone
│   │   ├── tts_view_model.dart          # Estado de reprodução de áudio
│   │   └── library_view_model.dart      # Histórico + favoritos + configurações
│   └── ui/
│       ├── screens/
│       │   ├── home_screen.dart         # Shell com NavigationBar (Traduzir/Histórico/Ajustes)
│       │   ├── translate_screen.dart    # Módulos 1–3 compostos
│       │   ├── history_screen.dart      # Módulo 4
│       │   ├── settings_screen.dart     # Módulo 4
│       │   └── model_manager_screen.dart# Gestão dos pacotes de idiomas
│       └── widgets/                     # language_pill, translation_card, mic_button,
│                                        # waveform_indicator, mini_player_tts,
│                                        # download_progress_card, connection_badge...
├── test/
│   ├── services/                        # Testes unitários com mocks dos plugins
│   └── state/                           # Testes dos ViewModels
└── pubspec.yaml
```

**Regras de dependência entre camadas (obrigatórias):**
1. `ui/` NUNCA importa pacotes de plugin (`google_mlkit_*`, o motor de STT, `flutter_tts`, `shared_preferences`) diretamente — somente ViewModels.
2. ViewModels importam apenas `core/services/` e `models/`. Serviços não conhecem Flutter Widgets.
3. Todo arquivo Dart declara imports na ordem: dart → flutter → packages → projeto.
4. Nenhuma cor literal fora de `app_colors.dart`; nenhuma string literal de UI fora de `app_strings.dart`.

---

# 3. ESCOPO DO PRODUTO (REQUISITOS FUNCIONAIS)

## 3.0 Visão Geral dos Módulos
| Módulo | Nome | Prioridade |
|---|---|---|
| **M1** | Tradução de Texto (núcleo on-device) | P0 |
| **M2** | Entrada por Voz — Speech-to-Text offline | P0 |
| **M3** | Saída por Voz — Text-to-Speech nativo | P0 |
| **M4** | Histórico, Favoritos, Configurações e Conectividade | P0 |

### Dependências do `pubspec.yaml` (fechadas — não substituir)
| Pacote | Uso | Observação |
|---|---|---|
| `google_mlkit_translation` | M1 — tradução on-device | Pacotes de idioma ~30 MB cada, download sob demanda |
| *(motor de STT — **a definir na spike F2.0**)* | M2 — STT 100% offline | `vosk_flutter` **removido da lista fechada na v1.1**: não resolve com Dart 3. Modelos embutidos em `assets/models/` |
| `flutter_tts` | M3 — TTS | Usa motor nativo do SO (já no cache do projeto, v4.2.5) |
| `tflite_flutter` | M1 — Plano B | Modelo TFLite embutido p/ cenários **sem acesso aos servidores de download do Google** (ver RF-M1-07; a v1.0 dizia "sem Google Play Services", premissa corrigida na v1.1) |
| `shared_preferences` | M4 — persistência local | Equivalente ao "LocalStorage" |
| `connectivity_plus` | M4 — status de rede / fallback híbrido | |
| `provider` | Estado global (ChangeNotifier) | |
| `permission_handler` | Permissão de microfone | |
| `path_provider` | Caminhos locais (modelos Vosk) | Já resolvido no projeto |
| `share_plus` | Compartilhar tradução | P1 (opcional na v1) |

---

## 3.1 MÓDULO 1 — TRADUÇÃO DE TEXTO

### Lógica de Funcionamento
- **RF-M1-01** — O aplicativo suporta exatamente os pares: `pt↔en`, `pt↔zh`, `en↔zh`. Os idiomas são um enum fechado (`Language { pt, en, zh }`) sem possibilidade de extensão pela UI.
- **RF-M1-02** — Motor padrão: `google_mlkit_translation` (`OnDeviceTranslator`). Antes de traduzir o par `(origem, destino)`, verificar se ambos os modelos remotos estão baixados via `isModelDownloaded`. Se algum faltar, NÃO falhar silenciosamente: acionar o fluxo de download do **Card de Progresso de Modelo** (ver UI).
- **RF-M1-03** — Download de pacote: usar `downloadModel` com listener de progresso; exibir porcentagem; permitir cancelamento (`cancelDownloadModel`); permitir exclusão (`deleteRemoteModel`). Tamanho estimado exibido: ~30 MB por idioma.
- **RF-M1-04** — Tradução automática (live): após o usuário parar de digitar por **800 ms (debounce)**, disparar a tradução automaticamente, desde que o texto tenha ≥ 1 caractere. O botão **Traduzir** força execução imediata ignorando o debounce.
- **RF-M1-05** — Limite de caracteres: **5.000**. Contador visível `n/5000`. Ao exceder, o campo trunca a entrada em 5000 e exibe aviso. Textos maiores que o limite do ML Kit são divididos em blocos ≤ 4.500 chars respeitando quebras de parágrafo/frase, traduzidos sequencialmente e concatenados preservando a ordem.
- **RF-M1-06** — Botão inverter (⇄): troca origem↔destino E troca os textos dos dois cartões; recalcula a tradução para o novo par. Desabilitado durante tradução em andamento.
- **RF-M1-07** — **Plano B (motor alternativo)**. *Revisado na v1.1 — a justificativa da v1.0 ("dispositivos sem Google Play Services") era tecnicamente incorreta: o SDK ML Kit standalone é embarcado no APK e funciona sem GMS.* O gatilho correto é a **impossibilidade de obter os pacotes de idioma**: o download vem de servidores do Google, que podem estar bloqueados ou inacessíveis (cenário China continental), deixando o ML Kit sem modelos utilizáveis. Nesse caso — e em qualquer erro de inicialização do motor — o `TranslationService` faz fallback transparente para o interpretador `tflite_flutter` com modelo embutido em `assets/models/tflite/`. O usuário NUNCA vê stacktrace; vê apenas badge discreto "motor alternativo".
  - **Estado atual (v1.1)**: a spike `docs/tflite_spike.md` concluiu que não há modelo NMT compacto viável hoje para os 3 pares. O backend permanece atrás da interface `TranslationBackend` com a feature-flag `AppConstants.enableAlternativeEngine = false`. **Consequência assumida e documentada**: sem acesso à CDN do Google, o app não traduz. O fluxo de fallback segue testável por mocks e a flag pode ser ligada sem tocar em UI ou ViewModels.
- **RF-M1-08** — Enquanto traduz: cartão destino exibe skeleton shimmer; entradas ficam desabilitadas para novo envio até conclusão ou erro.
- **RF-M1-09** — Ações sobre o resultado: copiar (clipboard), compartilhar (P1), favoritar ⭐ (M4), reproduzir áudio 🔊 (M3).
- **RF-M1-10** *(novo na v1.1 — lacuna: os dois seletores expõem os 3 idiomas, e a v1.0 não definia o caso origem == destino)* — **Nunca existe estado com origem igual a destino.** Ao escolher, em um seletor, o idioma já usado no outro, o app **troca os dois** (comportamento de swap, idêntico ao botão ⇄) em vez de rejeitar a seleção ou exibir erro. Exemplo: par atual `pt→en`; usuário abre o seletor de destino e escolhe `pt` ⇒ o par vira `en→pt`, com os textos invertidos como em RF-M1-06. Regra válida para ambos os seletores e para o estado restaurado da persistência (par inválido salvo ⇒ volta ao default `pt→en`).

### Elementos de Interface (Tela Traduzir)
| Elemento | Especificação |
|---|---|
| AppBar | Logo "Translatoo" + `ConnectionBadge` (Módulo 4) à direita |
| Cartão Origem | Pill seletora de idioma (canto sup. esq.) · botão limpar ✕ (canto sup. dir.) · `TextField` multilinha auto-expansível · contador `n/5000` · linha de ações: 🎤 (M2) · colar 📋 |
| Botão ⇄ | Circular central entre cartões, 56 dp, elevação 2 |
| Cartão Destino | Pill seletora de idioma · área somente-leitura do resultado (ou skeleton) · linha de ações: 🔊 (M3) · copiar · ⭐ · compartilhar |
| Card Progresso Modelo | Aparece sobre o cartão afetado quando modelo ausente: nome do idioma, barra de progresso %, tamanho ~30 MB, botões **Baixar**/**Cancelar** |
| Botão Traduzir | Primário, largura total do cartão origem em layout compacto |

### Manipulação de Estado
`TranslatorViewModel extends ChangeNotifier` (via `provider`):
- Campos observáveis: `sourceLang`, `targetLang`, `sourceText`, `translatedText`, `status ∈ {idle, typing, translating, done, error}`, `modelStatus: Map<LanguagePair, ModelState{notDownloaded, downloading(progress), ready}>`.
- Métodos públicos: `setSourceLang()`, `setTargetLang()`, `swapLanguages()`, `onTextChanged()` (gerencia debounce interno), `translateNow()`, `clearSource()`, `copyResult()`, `toggleFavorite()`.
- Regras de notificação: usar `notifyListeners()` apenas em transições de estado; a UI consome com `Selector`/`context.select` para rebuild cirúrgico (nunca `Consumer` da ViewModel inteira nos campos de texto, evitando perda de foco/cursor).
- Persistência do último par usado: delegada ao Módulo 4 (`settings.srcLang` / `settings.tgtLang`).

## 3.2 MÓDULO 2 — ENTRADA POR VOZ (SPEECH-TO-TEXT OFFLINE)

### Lógica de Funcionamento
- **RF-M2-01** — **Requisito de motor** *(revisado na v1.1)*: STT **100% offline**, com modelos acústicos **embutidos nos assets** (`assets/models/`), sem depender de ditado offline configurado pelo usuário no SO e sem exigir Google Play Services. O pacote `speech_to_text` **NÃO** é aceitável como fonte primária justamente por delegar essa configuração ao usuário.
  - **Motor concreto: em aberto.** A v1.0 fixava `vosk_flutter`, mas essa versão (0.3.48) declara `sdk <3.0.0` e **não resolve com Dart 3** — está comentada no `pubspec.yaml`. A escolha final sai da spike **F2.0** (plano de implementação), que avalia fork do `vosk_flutter`, `sherpa-onnx` e `whisper.cpp` contra critérios de tamanho, qualidade PT/EN/ZH, licença e manutenção. **Nenhum outro requisito do M2 depende dessa escolha**: todos são expressos contra a interface `SttService`.
- **RF-M2-02** — Idioma da escuta = idioma de ORIGEM selecionado no Módulo 1. Ao iniciar escuta, o modelo Vosk correspondente é carregado on-demand; primeira carga exibe estado `initializing` (spinner no botão).
- **RF-M2-03** — Fluxo de permissão: ao tocar em 🎤, solicitar `RECORD_AUDIO`. Se negada permanentemente, exibir diálogo explicativo com botão "Abrir configurações" (`permission_handler.openAppSettings()`). Nenhuma exceção deve propagar à UI.
- **RF-M2-04** — Resultados parciais: o texto reconhecido aparece EM TEMPO REAL (streaming) no campo origem, em cor secundária/itálico enquanto parcial.
- **RF-M2-05** — Fim de fala: pausa de ≥ 1,5 s finaliza a frase; o texto final substitui o conteúdo do campo origem e dispara automaticamente a tradução do Módulo 1 (ignorando debounce).
- **RF-M2-06** — Limites: duração máxima contínua de **60 s** (auto-stop usando último resultado final); cancelar descarta tudo e restaura o texto anterior ao início da escuta.
- **RF-M2-07** — Durante a escuta, TTS é silenciado e o campo de digitação fica desabilitado.

### Elementos de Interface
| Elemento | Especificação |
|---|---|
| Botão 🎤 | 3 estados: `idle` (outline, cor primária) · `listening` (preenchido vermelho `colorError`, anel pulsante + waveform animada) · `error` (ícone com badge ! e tooltip da mensagem) |
| Overlay de Escuta | Bottom-sheet durante listening: texto parcial grande (rolável), timer mm:ss, waveform, botões **Cancelar** e **Concluir** |
| Feedback háptico | Vibração curta ao iniciar e encerrar a escuta (se suportado) |

### Manipulação de Estado
`SpeechViewModel extends ChangeNotifier`:
- Máquina de estados: `SpeechState { idle, initializing, listening, processing, error }` — transições inválidas ignoradas (ex.: `stop()` quando `idle`).
- Campos observáveis: `state`, `partialText`, `finalText`, `elapsedSeconds`, `errorMessage`.
- Métodos públicos: `start(Language lang)`, `stop()`, `cancel()`.
- Integração: ao emitir `finalText != null`, chama `TranslatorViewModel.acceptDictatedText(text)` que seta o campo origem e executa tradução imediata.

---

## 3.3 MÓDULO 3 — SAÍDA POR VOZ (TEXT-TO-SPEECH NATIVO)

### Lógica de Funcionamento
- **RF-M3-01** — Motor: `flutter_tts`, utilizando exclusivamente os motores de voz nativos do SO (Google/Samsung/Baidu no Android, Siri no iOS). Sem uso de internet.
- **RF-M3-02** — Idioma da fala = idioma de DESTINO da tradução. Antes de falar, consultar vozes instaladas (`getVoices`/`isLanguageAvailable`).
- **RF-M3-03** — Voz ausente: se o pacote de voz do idioma destino não estiver instalado no sistema, exibir **SnackBar persistente** com instrução explícita ("Instale o pacote de voz Chinês nas configurações do sistema → Idioma e entrada → Saída de síntese de voz") e ação sugerida para abrir as configurações do aparelho. O app não trava e mantém o resultado visível.
- **RF-M3-04** — Fila única: um novo `speak()` sempre executa `stop()` antes (nunca sobrepor áudios). Reprodução pode ser interrompida a qualquer momento pelo usuário.
- **RF-M3-05** — Parâmetros ajustáveis nas Configurações (M4): velocidade `rate ∈ [0.5, 2.0]` (default 1.0) e tom `pitch ∈ [0.5, 1.5]` (default 1.0), persistidos localmente.
- **RF-M3-06** — Autoplay opcional (default OFF): quando ativado, toda tradução concluída é falada automaticamente. Quando a tradução se originou de ditado por voz (M2), a reprodução automática ocorre independentemente do autoplay (fluxo conversacional).

### Elementos de Interface
| Elemento | Especificação |
|---|---|
| Botão 🔊 | No cartão destino; alterna play ▶ / stop ⏹ conforme estado; desabilitado se resultado vazio |
| Mini-player | Barra inferior durante reprodução: ícone animado, trecho sendo falado (scroll horizontal), botão stop |
| Painel de voz | Em Ajustes: sliders rotulados de velocidade/tom com valor numérico ao lado |

### Manipulação de Estado
`TtsViewModel extends ChangeNotifier`:
- Estados: `TtsState { idle, speaking }`; campos `currentText`, `currentLang`, `rate`, `pitch`, `voiceAvailable: Map<Language, bool>` (cache atualizado na abertura do app e ao retornar de segundo plano).
- Handlers registrados no `flutter_tts`: `onComplete` → volta a `idle`; `onError` → `idle` + mensagem mapeada (tabela de erros, §4.8).
- Regra: `speak()` é idempotente em relação a chamadas duplicadas do mesmo texto em ≤ 300 ms (debounce anti duplo-toque).

## 3.4 MÓDULO 4 — HISTÓRICO, FAVORITOS, CONFIGURAÇÕES E CONECTIVIDADE

### Lógica de Funcionamento
- **RF-M4-01 — Histórico automático**: toda tradução concluída (`status == done`) é salva com `{id, sourceText, translatedText, sourceLang, targetLang, timestamp, isFavorite}`. Deduplicação: se a última entrada tiver mesmo texto de origem + par de idiomas, apenas atualiza `timestamp` e resultado (sem duplicar).
- **RF-M4-02 — Capacidade**: histórico limitado a **200 entradas** (FIFO — a mais antiga é descartada). Favoritos são ilimitados e NUNCA são descartados automaticamente.
- **RF-M4-03 — Busca e filtro**: campo de busca case-insensitive por substring em `sourceText` OU `translatedText`; chips de filtro por par de idiomas (`Todos`, `PT↔EN`, `PT↔ZH`, `EN↔ZH`).
- **RF-M4-04 — Exclusão**: swipe para excluir item individual + SnackBar "Desfazer" por 5 s; ação "Limpar tudo" exige diálogo de confirmação e NÃO apaga favoritos.
- **RF-M4-05 — Persistência local** (`shared_preferences` — equivalente ao LocalStorage), chaves prefixadas:
  | Chave | Conteúdo |
  |---|---|
  | `translatoo.history` | JSON array de `TranslationRecord` (máx. 200) |
  | `translatoo.favorites` | JSON array de ids + registros |
  | `translatoo.settings.srcLang` / `tgtLang` | Último par usado |
  | `translatoo.settings.ttsRate` / `ttsPitch` / `autoPlay` | Preferências de voz |
  | `translatoo.settings.wifiOnly` | Download de modelos só via Wi-Fi (default `true`) |
  | `translatoo.settings.schemaVersion` | Controle de migração |
  Gravações agrupadas (debounce 500 ms) para evitar I/O excessivo. Toda leitura tolera JSON corrompido: reinicia coleção vazia e loga em modo debug.
  - **Política de migração de `schemaVersion`** *(novo na v1.1 — a v1.0 previa o campo mas não o que fazer com ele)*: no boot, `StorageService` compara a versão persistida com `AppConstants.schemaVersion`. **(a)** Iguais ⇒ leitura normal. **(b)** Persistida **menor** ⇒ aplica em sequência as funções de migração registradas para cada versão intermediária; se alguma falhar, a coleção afetada é descartada (não o conjunto todo) e o app segue com ela vazia. **(c)** Persistida **maior** que a do app (downgrade de versão) ⇒ dados **não** são interpretados: as coleções são descartadas e as preferências voltam ao default, evitando leitura de formato desconhecido. **(d)** Ausente ⇒ tratada como versão 1. Preferências (`settings.*`) são sempre migradas campo a campo com default para chaves novas, de modo que acrescentar uma preferência **não** exige nova versão de schema. Toda migração é registrada em log de debug e coberta por teste unitário.
- **RF-M4-06 — Gerenciador de Modelos**: tela dedicada listando os 3 idiomas com estado (`Não baixado` · `Baixando n%` · `Pronto`), tamanho estimado (~30 MB) e ações Baixar/Excluir. Se `wifiOnly == true` e rede = dados móveis, bloquear com aviso + opção explícita "Baixar mesmo assim" (não altera a preferência).
- **RF-M4-07 — Conectividade**: `connectivity_plus` expõe stream; `ConnectionBadge` no AppBar: 🟢 online / ⚪ offline. **Regra crítica: nenhum recurso da v1 é bloqueado por falta de internet** (tradução, ditado e voz são locais).
- **RF-M4-08 — Modo híbrido (Fase 2, flag `cloudEnabled=false` na v1)**: quando online e flag ativa, tentar API em nuvem (maior precisão) com timeout de 2 s; qualquer erro/timeout → fallback silencioso para o motor on-device, com badge discreto "local" no resultado. Implementação isolada atrás da interface `TranslationBackend`.
- **RF-M4-09 — Tela Ajustes**: par de idiomas padrão · autoplay TTS (switch) · velocidade/tom (sliders M3) · somente Wi-Fi (switch) · gerenciar modelos (link) · limpar histórico (ação destrutiva confirmada) · versão do app · declaração de privacidade ("Nenhum dado sai do seu aparelho").

### Elementos de Interface
| Elemento | Especificação |
|---|---|
| NavigationBar inferior | 3 destinos fixos: Traduzir · Histórico · Ajustes (ícone + rótulo, sempre visível) |
| Lista de Histórico | Card por item: origem (cor texto secundária), tradução (destaque), pills dos idiomas, horário relativo ("há 5 min"), ícone ⭐ se favorito; toque reabre no Tradutor |
| Barra de busca | Fixa no topo da lista + chips de filtro horizontal scrollável |
| Estados vazios | Ilustração leve + texto orientativo ("Suas traduções aparecerão aqui") |
| ConnectionBadge | Ícone 20 dp no AppBar com tooltip; nunca ocupa linha própria |

### Manipulação de Estado
`LibraryViewModel extends ChangeNotifier`:
- Campos observáveis: `history: List<TranslationRecord>`, `favorites: Set<String>`, `query`, `activeFilter`, `settings: AppSettings` (imutável, cópia-com-`copyWith`).
- Métodos públicos: `addRecord()`, `toggleFavorite(id)`, `delete(id)` (+`undoDelete()`), `clearHistory()`, `search(q)`, `filterBy(pair)`, `updateSettings(...)`.
- `StorageService` é o ÚNICO ponto de acesso a `shared_preferences` (serializa/desserializa JSON); ViewModels nunca importam o plugin.
- `ConnectivityService` expõe `ValueListenable<bool> isOnline`; consumido pelo badge sem rebuild das telas.

## 3.5 REGRAS DE NEGÓCIO TRANSVERSAIS
- **RN-01** — Idiomas são o enum fechado `Language { pt, en, zh }`; nenhum fluxo aceita idioma fora dele.
- **RN-02** — O app opera 100% offline por padrão; internet só é usada para download de pacotes ML Kit e (Fase 2) API em nuvem.
- **RN-03** — Nenhuma exceção de plugin chega crua à UI: todos os serviços capturam e convertem para `AppException(code)` da tabela §4.8.
- **RN-04** — Proibido cor literal fora de `app_colors.dart` e string de UI literal fora de `app_strings.dart` (i18n pt-BR/en/zh).
- **RN-05** — Logs apenas em modo debug (`kReleaseMode` guard); nunca logar conteúdo traduzido/falado.
- **RN-06** — Acessibilidade: `Semantics` em todo botão de ícone; contraste mínimo AA (4.5:1); áreas de toque ≥ 48 dp.
- **RN-07** — Ciclo de vida: ao ir para segundo plano durante escuta (M2), a escuta é encerrada com o resultado parcial finalizado; TTS (M3) continua até concluir ou ser interrompido pelo SO.

---

# 4. REQUISITOS NÃO-FUNCIONAIS (ESPECIFICAÇÕES TÉCNICAS)

## 4.1 Responsividade Mobile-First (obrigatória)
- Layout projetado primeiro para **telas compactas (< 600 dp)**, uma coluna empilhada (Cartão Origem → ⇄ → Cartão Destino), ações primárias no terço inferior.
- Breakpoints via `LayoutBuilder`/`MediaQuery`:
  | Largura | Layout |
  |---|---|
  | < 600 dp | Coluna única empilhada, `NavigationBar` inferior |
  | 600–1024 dp | Cartões origem/destino lado a lado horizontalmente; navegação inferior mantida |
  | ≥ 1024 dp | Conteúdo centralizado (`maxWidth` 720 dp), cartões lado a lado, `NavigationRail` à esquerda |
- `SafeArea` obrigatória em todas as telas; validação visual mínima em 320 dp de largura.

## 4.2 Armazenamento Local (equivalente ao LocalStorage)
- Persistência exclusivamente via `shared_preferences`, encapsulada em `StorageService` (§3.4 RF-M4-05). Nenhum dado sensível além de preferências e histórico de traduções.
- Sem backend, sem contas, sem sincronização. Desinstalar o app apaga 100% dos dados (comportamento aceito e documentado na tela Ajustes).
- Dados do usuário (textos/áudios) permanecem 100% no dispositivo — diferencial competitivo frente a tradutores em nuvem.

## 4.3 Organização do "CSS" — Tokens de Cor (equivalente a variáveis CSS)
Arquivo único `lib/core/constants/app_colors.dart` no topo do projeto de estilos, espelhando a convenção de variáveis CSS para mapeamento direto da paleta existente:

```dart
/// FONTE ÚNICA DA PALETA — altere APENAS aqui para trocar o tema.
class AppColors {
  // --color-primary
  static const Color colorPrimary       = Color(0xFF2563EB);
  // --color-secondary
  static const Color colorSecondary     = Color(0xFF10B981);
  // --color-background
  static const Color colorBackground    = Color(0xFFF8FAFC);
  // --color-surface
  static const Color colorSurface       = Color(0xFFFFFFFF);
  // --color-text-primary / --color-text-secondary
  static const Color colorTextPrimary   = Color(0xFF0F172A);
  static const Color colorTextSecondary = Color(0xFF64748B);
  // --color-success / --color-warning / --color-error
  static const Color colorSuccess       = Color(0xFF22C55E);
  static const Color colorWarning       = Color(0xFFF59E0B);
  static const Color colorError         = Color(0xFFEF4444);
  // --color-border / --color-overlay
  static const Color colorBorder        = Color(0xFFE2E8F0);
  static const Color colorOverlay       = Color(0x66000000);
}
```
- `app_theme.dart` constrói `ThemeData` EXCLUSIVAMENTE a partir desses tokens (proibido `Color(0x…)` em qualquer outro arquivo).
- Espaçamentos/raios também tokenizados em `app_spacing.dart` (escala 4/8/16/24/32; raio 12 padrão).
- Modo escuro (P1): segunda classe `AppColorsDark` com os MESMOS nomes estáticos — troca de paleta sem tocar widgets.

## 4.4 Desempenho
| Métrica | Alvo |
|---|---|
| Cold start | < 2 s |
| Tradução (pacote pronto, ≤ 500 chars) | ≤ 300 ms |
| Início da escuta Vosk (modelo já carregado) | ≤ 500 ms |
| Animações | 60 fps sem jank (mic pulsante/waveform via `AnimationController` único) |

## 4.5 Privacidade e Permissões
- `RECORD_AUDIO` somente durante uso ativo (runtime permission, justificativa prévia em diálogo).
- iOS `Info.plist`: `NSMicrophoneUsageDescription` e `NSSpeechRecognitionUsageDescription` obrigatórios.
- Política: nenhum dado coletado/compartilhado; áudio processado localmente (Vosk) ou pelo motor nativo do SO (TTS).

## 4.6 Compatibilidade

| Plataforma | Mínimo | Origem da restrição |
|---|---|---|
| Android | **minSdk 23** | Definido pelo produto (plugin ML Kit exige apenas 21) |
| iOS | **15.5** | **Imposto** pelo pod `GoogleMLKit/Translate ~> 9.0.0`, dependência de `google_mlkit_translation` |

> **Correção v1.1 — iOS.** A v1.0 declarava "iOS 12+", o que é **impossível**: o pod do ML Kit exige deployment target **15.5**, e o projeto estava configurado em 15.0 (o `pod install` falharia). O valor correto e obrigatório é **15.5**, aplicado em `ios/Podfile` e no `IPHONEOS_DEPLOYMENT_TARGET` do target Runner.

- **Cenário China**: o ML Kit standalone **funciona sem Google Play Services** (§1.1). A validação necessária não é "aparelho sem GMS", e sim **aparelho sem acesso aos servidores do Google**: nesse caso não há como baixar pacotes, e a cobertura depende do Plano B TFLite (RF-M1-07), hoje com flag desligada.
- Web/Desktop: comportamento degradado aceitável (sem microfone/STT), mas tradução de texto e histórico devem funcionar.

## 4.7 Tamanho do Aplicativo e Flavors de Build

Os dois limites de tamanho só são alcançáveis com **dois flavors de build distintos** — a v1.0 citava as variantes sem definir o mecanismo. A especificação normativa é:

| Flavor | `applicationIdSuffix` | Conteúdo | Limite | Distribuição |
|---|---|---|---|---|
| **`lite`** | `.lite` | Sem modelos STT embutidos. Tradução via ML Kit (download sob demanda). Ditado (M2) **indisponível**: o botão 🎤 fica oculto, não desabilitado | **APK < 40 MB** | Play Store (padrão) |
| **`full`** | *(nenhum)* | Modelos STT dos 3 idiomas + modelo TFLite (quando existir) embutidos em `assets/models/` | **AAB ≤ 180 MB** | Play Store (variante offline garantido) / distribuição direta |

- A seleção do flavor é **compile-time**: `AppConstants.hasEmbeddedSttModels` (via `--dart-define`) controla a exibição de todo o M2. Nenhuma checagem de flavor pode vazar para `ui/` — ela é lida uma única vez e exposta pelos ViewModels.
- Trade-off documentado e aceito: offline garantido × tamanho do download.
- Medição dos limites faz parte do DoD da fase de release (plano F4.6).

## 4.9 Tipografia de Idiomas CJK (obrigatório)

> *Seção nova na v1.1 — lacuna crítica: um terço do produto é mandarim, e nem o PRD nem o plano tratavam da renderização dos glifos.*

- **Problema**: Flutter não embute fontes CJK. Em aparelhos Android **fora do mercado chinês**, muitas ROMs não trazem cobertura de Han, e todo texto em `zh` renderiza como **tofu** (`□□□`) — atingindo a tela Traduzir, o histórico e os seletores.
- **RF-CJK-01** — O app **DEVE** embutir uma fonte com cobertura de Han simplificado (referência: **Noto Sans SC**), declarada em `pubspec.yaml` e aplicada via `fontFamilyFallback` no `TextTheme` de `app_theme.dart` — nunca widget a widget.
- **RF-CJK-02** — A fonte entra como **fallback**, não como fonte primária: PT e EN continuam na tipografia padrão da plataforma, preservando a identidade visual e o hinting nativo.
- **RF-CJK-03** — Para respeitar o limite do flavor `lite` (< 40 MB), a fonte **DEVE** ser um *subset* dos glifos necessários, e não o arquivo completo (~16 MB). Meta: **≤ 5 MB** no APK.
- **RF-CJK-04** — Verificação obrigatória no DoD: renderizar 中文 em um emulador **sem locale chinês instalado** e confirmar ausência de tofu.

## 4.10 Identidade Visual e Conformidade de Loja (obrigatório para release)

> *Seção nova na v1.1 — a v1.0 mencionava apenas "screenshots e descrição"; os itens abaixo são bloqueadores de publicação.*

| ID | Entregável | Especificação |
|---|---|---|
| RF-REL-01 | **Ícone do app** | Substituir o ícone padrão do Flutter. Adaptive icon Android (foreground + background separados, área segura 66 dp de 108 dp) e conjunto iOS completo. Derivado da paleta Verde & Branco |
| RF-REL-02 | **Splash screen** | Nativa (Android 12+ `SplashScreen` API), fundo `colorBackground` e logo central; versões light e dark. Sem tela branca entre splash e primeiro frame |
| RF-REL-03 | **Política de privacidade** | Documento **publicamente acessível por URL** (exigência do Play). Deve afirmar: nenhum dado coletado, nenhum texto/áudio enviado, download de pacotes é a única conexão, desinstalar apaga tudo |
| RF-REL-04 | **Formulário Data Safety** | Preenchido no Play Console coerente com RF-REL-03: nenhuma coleta, nenhum compartilhamento. Divergência entre formulário e comportamento é motivo de rejeição |
| RF-REL-05 | **Declaração de permissões** | Justificar `RECORD_AUDIO` (ditado local) e `INTERNET` (somente download de pacotes) no formulário da loja |
| RF-REL-06 | **Store listing** | Screenshots light e dark, descrição enfatizando privacidade/offline, notas da v1.0 |

## 4.8 Tabela Única de Erros (mapeamento obrigatório)
| Código | Gatilho | Mensagem exibida | Ação sugerida |
|---|---|---|---|
| `ERR_MODEL_NOT_DOWNLOADED` | Par sem pacote local | "Pacote de {idioma} não instalado" | Botão Baixar |
| `ERR_DOWNLOAD_FAILED` | Falha/rede no download | "Falha ao baixar pacote" | Tentar novamente |
| `ERR_WIFI_ONLY` | Download em dados móveis | "Download restrito a Wi-Fi" | "Baixar mesmo assim" |
| `ERR_MIC_PERMISSION` | Permissão negada | "Precisamos do microfone para ouvir você" | Abrir configurações |
| `ERR_STT_ENGINE` | Erro Vosk/modelo | "Não foi possível ouvir agora" | Tentar novamente |
| `ERR_TTS_VOICE_MISSING` | Voz do SO ausente | "Instale a voz {idioma} nas configurações do sistema" | Abrir configurações |
| `ERR_STORAGE` | shared_preferences falhou | "Não foi possível salvar" | Repetir ação |
| `ERR_TRANSLATION_FAILED` | Motor falhou nos dois backends | "Tradução indisponível neste momento" | Tentar novamente |

# 5. CRITÉRIOS DE ACEITE (USER STORIES)

Formato obrigatório: **Dado que… Quando… Então…** Mínimo exigido: 2 por módulo.

## US-1 — Tradução de Texto (Módulo 1)
> **Como** usuário, **quero** traduzir texto entre PT, EN e ZH instantaneamente, **para que** eu me comunique sem internet.

- **AC-M1-1** — **Dado que** os pacotes de idiomas `pt` e `zh` estão baixados e o aparelho está em modo avião, **quando** digito "Bom dia" com origem PT e destino ZH, **então** o cartão destino exibe a tradução em até 300 ms após o debounce de 800 ms, sem nenhuma mensagem de erro de rede.
- **AC-M1-2** — **Dado que** o pacote do idioma destino ainda não foi baixado, **quando** seleciono esse idioma pela primeira vez, **então** o Card de Progresso Modelo aparece com barra %, tamanho estimado (~30 MB) e botões Baixar/Cancelar; ao concluir, o estado muda para "Pronto" e a tradução pendente executa automaticamente.
- **AC-M1-3** — **Dado que** existem textos nos dois cartões, **quando** toco no botão ⇄, **então** idiomas e textos são invertidos, uma nova tradução é calculada para o par inverso e o botão fica desabilitado apenas durante o processamento.
- **AC-M1-4** *(reformulado na v1.1 — a redação original partia da premissa incorreta de que o ML Kit exige Google Play Services)* — **Dado que** estou em um aparelho **sem acesso aos servidores de download do Google** (cenário China), de modo que os pacotes de idioma não podem ser obtidos, **quando** tento traduzir e o ML Kit fica sem modelos utilizáveis, **então** o app recorre automaticamente ao motor alternativo embutido (badge "motor alternativo"), sem exibir stacktrace ou travar.
  - **Verificação enquanto `enableAlternativeEngine = false`**: validado por mock da interface `TranslationBackend`. Em aparelho real, o comportamento esperado hoje é a mensagem `ERR_MODEL_NOT_DOWNLOADED` com ação sugerida — nunca um crash.

## US-2 — Entrada por Voz / STT (Módulo 2)
> **Como** usuário, **quero** ditar minha fala e vê-la transcrita, **para que** eu não precise digitar.

- **AC-M2-1** — **Dado que** concedi permissão de microfone e o idioma de origem é PT, **quando** toco no 🎤 e digo "onde fica o banheiro", **então** vejo o texto parcial aparecendo em tempo real no campo origem e, após pausa de ~1,5 s, o texto final substitui o campo e dispara a tradução automaticamente.
- **AC-M2-2** — **Dado que** neguei permanentemente a permissão de microfone, **quando** toco no 🎤, **então** é exibido um diálogo explicativo com botão "Abrir configurações", nenhuma exceção é lançada e o restante do app permanece utilizável.
- **AC-M2-3** — **Dado que** estou gravando há mais de 60 s continuamente, **quando** o tempo máximo é atingido, **então** a escuta encerra sozinha e o último resultado final reconhecido permanece no campo origem.
- **AC-M2-4** — **Dado que** a escuta está ativa, **quando** toco em Cancelar no overlay, **então** o texto volta a ser exatamente o anterior ao início da ditadura e nenhuma tradução é disparada.

## US-3 — Saída por Voz / TTS (Módulo 3)
> **Como** usuário, **quero** ouvir a tradução falada, **para que** eu aprenda a pronúncia e me comunique verbalmente.

- **AC-M3-1** — **Dado que** existe uma tradução pronta com destino ZH, **quando** toco no 🔊, **então** ouço a frase em mandarim pelo motor nativo do sistema, o botão alterna para estado ⏹ e retorna a ▶ automaticamente ao concluir.
- **AC-M3-2** — **Dado que** o celular não possui o pacote de voz chinesa instalado, **quando** aciono a reprodução, **então** aparece SnackBar persistente instruindo instalar a voz nas configurações do sistema; o app não trava e mantém o resultado visível.
- **AC-M3-3** — **Dado que** um áudio está tocando, **quando** reproduzo outra tradução, **então** o áudio anterior é interrompido imediatamente (nunca há sobreposição de vozes).
- **AC-M3-4** — **Dado que** ajustei a velocidade para 1.5 nos sliders de Ajustes, **quando** fecho e reabro o aplicativo, **então** a velocidade 1.5 permanece configurada e aplicada na próxima reprodução (persistência local).

## US-4 — Histórico, Favoritos e Configurações (Módulo 4)
> **Como** usuário, **quero** reencontrar traduções passadas e manter minhas preferências, **para que** o app se adapte a mim.

- **AC-M4-1** — **Dado que** realizei 3 traduções distintas, **quando** abro a aba Histórico, **então** vejo as 3 entradas ordenadas da mais recente para a mais antiga, cada uma com origem, tradução, pills dos idiomas e horário relativo.
- **AC-M4-2** — **Dado que** deslizo um item do histórico para excluí-lo, **quando** confirmo a exclusão, **então** o item desaparece da lista imediatamente e um SnackBar oferece "Desfazer" por 5 s, restaurando o item na posição original.
- **AC-M4-3** — **Dado que** fechei completamente o app (ou reiniciei o aparelho), **quando** o reabro, **então** o último par de idiomas, as preferências de voz (rate/pitch/autoplay), o histórico e os favoritos estão exatamente como deixei (persistência via `shared_preferences`).
- **AC-M4-4** — **Dado que** estou conectado via dados móveis e a opção "Somente Wi-Fi" está ativa, **quando** tento baixar um modelo no Gerenciador, **então** vejo aviso explicativo com opção "Baixar mesmo assim"; ao confirmar, o download prossegue e a preferência original permanece inalterada.
- **AC-M4-5** — **Dado que** o aparelho perdeu totalmente a internet, **quando** uso qualquer função do app, **então** nada é bloqueado, o ConnectionBadge mostra offline e todas as operações (traduzir/ditar/ouvir/histórico) funcionam normalmente.

# 6. ROADMAP, PRIORIDADES E DEFINIÇÃO DE PRONTO

## 6.1 Priorização
| Fase | Itens |
|---|---|
| **P0 (v1 — obrigatório)** | M1 tradução texto on-device + download de modelos; **fonte CJK embutida (§4.9)**; M2 ditado offline (motor definido na spike F2.0); M3 TTS nativo com aviso de voz ausente; M4 histórico/favoritos/configurações/persistência; tokens de cor; responsividade mobile-first; tabela de erros; **flavors lite/full (§4.7)**; **entregáveis de loja (§4.10)** |
| **P1** | Compartilhar tradução (`share_plus`); modo escuro (`AppColorsDark`); flavor leve sem modelos embutidos; NavigationRail desktop |
| **P2 (Fase 2)** | Modo híbrido nuvem→local com `connectivity_plus` (flag `cloudEnabled`, timeout 2 s, badge "local"); detecção automática de idioma (ML Kit Language ID) |

## 6.2 Definição de Pronto (DoD) por funcionalidade
1. `flutter analyze` sem warnings; formatado com `dart format`.
2. Testes unitários dos ViewModels/serviços envolvidos passando (`flutter test`).
3. Todos os critérios de aceite do módulo verificados manualmente em Android físico.
4. Nenhuma cor fora de `app_colors.dart`; nenhuma string de UI fora de `app_strings.dart`.
5. Funcionamento validado em **modo avião** quando aplicável.
6. Erros mapeados para a tabela §4.8 (nenhuma exceção crua na UI).

## 6.3 Glossário
| Termo | Definição |
|---|---|
| On-device | Processamento executado no processador do celular, sem servidores |
| Pacote de idioma | Modelo de tradução ML Kit baixável (~30 MB por idioma) |
| GMS | Google Mobile Services — ausente em celulares chineses nativos |
| STT / TTS | Speech-to-Text (fala→texto) / Text-to-Speech (texto→fala) |
| Token de cor | Constante nomeada que substitui variáveis CSS (`colorPrimary` ≙ `--color-primary`) |

## 6.4 Referências — Decisões herdadas do documento `share.txt`
| Decisão do `share.txt` | Como foi incorporada ao PRD |
|---|---|
| ML Kit como coração da tradução offline (~30 MB/idioma, gestão dinâmica) | RF-M1-02/03, US AC-M1-2 |
| Plano B `tflite_flutter` para celulares sem Play Services (cenário China) | RF-M1-07, AC-M1-4, §4.6 |
| Vosk como solução robusta de STT offline (modelo embutido ~50 MB mandarim) | RF-M2-01, arquitetura `assets/models/` |
| `flutter_tts` offline via motor nativo + aviso sobre pacote de voz chinês no sistema | RF-M3-01/03, AC-M3-2 |
| Arquitetura híbrida (nuvem melhor → fallback local silencioso via `connectivity_plus`) | RF-M4-08, P2 |
| Trade-offs nuvem × offline (precisão × velocidade × tamanho × privacidade) | §1.1, §4.7, RN-02 |

---

# 7. REGISTRO DE REVISÕES

## v1.1 — 2026-08-28

Revisão de completude conduzida sobre o código já entregue (F0 e F1 concluídas). Nenhum requisito foi removido; as mudanças corrigem premissas incorretas, resolvem contradições internas e preenchem lacunas que impediriam concluir o produto.

| # | Mudança | Seções | Motivo |
|---|---|---|---|
| 1 | **Premissa do Plano B corrigida** | §1.1, RF-M1-07, §4.6 | O plugin usa `com.google.mlkit:translate:17.0.3` — SDK **standalone**, embarcado no APK, que **funciona sem Google Play Services**. A justificativa "para celulares sem GMS" era falsa. O gatilho real é a **inacessibilidade dos servidores de download do Google** (cenário China) |
| 2 | **Motor de STT despromovido a decisão em aberto** | §1.1, RF-M2-01 | `vosk_flutter` 0.3.48 declara `sdk <3.0.0` e **não resolve com Dart 3** (está comentado no `pubspec.yaml`). Um módulo P0 inteiro estava apoiado numa dependência que não instala. Motor será definido pela spike **F2.0** |
| 3 | **iOS mínimo: 12+ → 15.5** | §4.6 | Três valores conflitantes (PRD 12, projeto 15.0, pod ML Kit **15.5**). O `pod install` falharia. 15.5 é imposto pela dependência |
| 4 | **Métricas de sucesso reclassificadas** | §1.3 | §1.3 exigia crash-rate e latência média enquanto RN-05/§4.5 proíbem telemetria — nenhuma era medível. Agora são metas de **QA manual** com roteiro definido, preservando a promessa de privacidade |
| 5 | **Tipografia CJK (novo requisito)** | §4.9 | Sem fonte embutida, mandarim renderiza como tofu (□□□) em Androids sem cobertura Han — quebra visualmente um terço do produto |
| 6 | **Flavors lite/full especificados** | §4.7 | Os limites de 40 MB / 180 MB eram citados sem mecanismo que os produzisse |
| 7 | **Identidade visual e conformidade de loja (novo)** | §4.10 | Ícone, splash, política de privacidade por URL e Data Safety são bloqueadores de publicação e não constavam |
| 8 | **Comportamento origem == destino** | RF-M1-10 | Os dois seletores expõem os 3 idiomas; o estado origem == destino não tinha regra definida |
| 9 | **Política de migração de `schemaVersion`** | RF-M4-05 | O campo existia desde a v1.0 sem nenhuma regra sobre o que fazer quando a versão muda |

**Consciente e deliberadamente NÃO incluído nesta revisão**: pipeline de CI (analyze/format/test automatizados por push) — avaliado e **dispensado pelo product owner**; o DoD segue verificado manualmente.

---
*Fim do documento — Translatoo PRD v1.1 (2026-08-28).*
