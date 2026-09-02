# Regras de Design — Translatoo

> Extraído do case de referência em [`docs/design/`](design/) (redesign de tradutor,
> 3 pranchas) · Complementa `prd.md §4.9` e `implementation_plan.md §3.3`
> Data: 2026-08-31

## Escopo desta extração

**Foi extraído**: forma dos widgets, anatomia das telas, hierarquia de camadas,
composição de componentes, estados, movimento — e, a partir da revisão de
2026-08-31, **a cor primária**.

A extração original preservava a paleta Verde & Branco e apenas registrava que
ela não sustentava o cabeçalho do case. Medido o contraste, a decisão de produto
foi **trocar a identidade para Azul & Branco**, com a primária `#3954FD`
amostrada dos próprios arquivos do case — ver [§8](#8-a-cor-primária).

`app_colors.dart` segue sendo a única fonte de cor do app (RN-04): sempre que
este documento diz "bloco de marca", leia `colorPrimary` do tema vigente, nunca
um hex escrito à mão.

---

## 1. Princípios de forma

Cinco decisões carregam a identidade inteira do case. Se só cinco coisas forem
seguidas, que sejam estas.

**P1 — A tela é uma pilha de painéis, não uma lista de caixas.**
O conteúdo não flutua sobre um fundo: painéis de largura total **sobem por cima**
uns dos outros, cada um com o topo arredondado, sangrando nas laterais. A borda
inferior de um painel é sempre coberta pelo painel seguinte.

**P2 — Raio grande é a assinatura.**
Cantos de 24–32 dp em painéis e cards; nada anguloso, nada com raio tímido. O
raio 12 atual do projeto lê como Material genérico e apaga a identidade.

**P3 — Separação por tom e sombra, nunca por borda.**
Cards não têm contorno. O card de origem é um degrau mais escuro que o de
destino; a hierarquia sai da diferença de superfície. Bordas de 1 dp só existem
em elementos *selecionáveis não selecionados* (§5.5).

**P4 — Um botão de ação primária flutuante, encaixado no recorte.**
O canto superior direito tem um squircle branco elevado que **transborda** o
limite entre o bloco de marca e o painel de conteúdo. É o único elemento que
quebra a grade, e por isso é o que o olho encontra primeiro.

**P5 — Ação principal ancorada no polegar.**
O controle mais usado (troca de idiomas) vive colado no rodapé, em largura total.
O topo é informação; o fundo é ação.

---

## 2. Escala de raios

O case usa três níveis, e a diferença entre eles é o que cria profundidade. Até
a issue #53 o projeto tinha **um** raio (12) para tudo — o que a §P2 descreve
como "Material genérico que apaga a identidade".

| Token | Valor | Uso |
|---|---|---|
| `radiusSm` | **8 dp** | chips, badges, campos pequenos, indicadores |
| `radiusMd` | **16 dp** | botões, inputs, snackbars, diálogos |
| `radiusLg` | **28 dp** | painéis, cards de tradução, sheets, squircles do grid |
| `radiusPill` | `StadiumBorder` | pílulas de idioma, botão "falar agora", tags |

`AppSpacing.radius` permanece como **alias de `radiusMd`** para não quebrar o
código da F0/F1 num único commit.

> **Implementados** em `app_spacing.dart` (issue #53). `AppSpacing.radius`
> permaneceu como alias de `radiusMd`, e `test/architecture/radius_tokens_test.dart`
> falha se algum raio cru voltar a `lib/`.

**Curva assimétrica dos painéis.** Medindo `docs/design/home.webp`, os painéis
têm **apenas o canto superior esquerdo arredondado** — o direito é reto. Não é
descuido do case: os dois painéis medem igual (raio esquerdo ~38–40 dp, direito
0). É a assimetria que faz o painel parecer deslizar por baixo do bloco de marca
em vez de ser um cartão simétrico pousado na tela.

> **Divergência registrada.** O case mede ~38–40 dp nesse canto; a tabela acima
> define `radiusLg` = 28 dp, e a §P2 fala em "24–32 dp". A implementação usa
> `radiusLg`, ficando dentro da faixa que o próprio documento declara. Subir a
> escala para 40 dp é decisão de produto — mexeria em todo painel, sheet e
> squircle do app.

**Regra do squircle.** Botões quadrados de ícone (grid de modos, botão de modo no
topo) usam lado ≥ 96 dp com `radiusLg`. Abaixo de 96 dp o raio grande deforma o
quadrado em círculo; use `radiusMd`.

---

## 3. Elevação e camadas

Quatro planos, e só quatro:

| Plano | Conteúdo | Superfície | Sombra |
|---|---|---|---|
| 0 — fundo | atrás de tudo | `colorBackground` | nenhuma |
| 1 — bloco de marca | cabeçalho, waveform | `colorPrimary` | nenhuma |
| 2 — painel | cards de tradução, sheets | `colorSurface` | difusa, y+2, blur 16, ~6% preto |
| 3 — flutuante | botão de modo, botão de swap | `colorSurface` | y+4, blur 20, ~12% preto |

**A sombra é difusa e quase invisível.** Nada de sombra dura de Material. Ela
existe para descolar o painel do fundo, não para ser vista.

**Card de origem × card de destino.** Origem usa `colorBackground` (um degrau
mais escuro), destino usa `colorSurface`. Essa inversão — o card "de baixo" mais
claro que o "de cima" — é deliberada: puxa o olho para a tradução, que é o
resultado que importa.

---

## 4. Anatomia da tela de tradução

De cima para baixo, quatro faixas:

```
┌─────────────────────────────────────┐
│ ☰   Título do modo        [ ⬤ ]     │ ← bloco de marca (plano 1)
│                                     │    o squircle transborda para baixo
│ ╭───────────────────────────────╮   │ ← painel sobe cobrindo o bloco
│ │ ))) Idioma            ✕       │   │   card ORIGEM (radiusLg no topo)
│ │ Texto de origem…              │   │
│ │                          72   │   │   contador ancorado embaixo à direita
│ ╰───────────────────────────────╯   │
│ ╭───────────────────────────────╮   │
│ │ ))) Idioma      ★  ⧉  ⋮       │   │   card DESTINO
│ │ Texto traduzido…              │   │
│ ╰───────────────────────────────╯   │
│                                     │
│ ╭──────────╮◯╭──────────────────╮   │ ← pílula partida, largura total
│ │ Origem   │⇄│ Destino          │   │   ancorada no rodapé
│ ╰──────────╯ ╰──────────────────╯   │
└─────────────────────────────────────┘
```

**Proporções medidas** em `docs/design/home.webp` (prancha do modo voz):

| Faixa | Altura |
|---|---|
| Bloco de marca | **40%** medidos no modo voz · 12–15% no modo texto |
| Cards | o que sobrar, com o card de destino crescendo mais |
| Pílula de idiomas | 64 dp fixos + safe area |

**Margens.** `AppSpacing.md` (16) nas laterais do conteúdo dos cards. Os painéis
em si sangram até a borda da tela — **não** têm margem lateral.

**Duas divergências do desenho, registradas na implementação:**

1. **O botão de modo (§5.3) não existe ainda.** A v1 tem dois modos, mas "Voz"
   não é um modo de tela — é o 🎤 dentro do painel de origem (§5.8). Construir o
   seletor exige antes transformar o ditado em modo próprio, que é
   funcionalidade nova, não redesenho. Fica para issue própria.
2. **Existe um botão TRADUZIR** entre os painéis e a barra de idiomas, que o
   case não tem. A tradução é automática por debounce (RF-M1-03), mas o botão
   manual é requisito coberto por teste. Some se o produto decidir que o
   debounce basta.

---

## 5. Componentes

Formato das tabelas: uma linha por propriedade, uma coluna por estado. Estados
não listados herdam o default.

### 5.1 Card de tradução

> **Implementado** em `lib/ui/widgets/translation_panel.dart` (`TranslationPanel`
> + `PanelHeader`). Substituiu o `TranslationCard` da F1.7, que era um `Card` do
> Material com borda e margem lateral.

Composição fixa, de cima para baixo: **linha de cabeçalho** → **texto** →
**contador**. O contador é sempre a última linha, alinhado à direita, e fica
colado no rodapé do card mesmo quando o texto é curto.

Linha de cabeçalho: ícone de áudio (`))`) + nome do idioma à esquerda; ações à
direita. As ações diferem por papel:

| Papel | Ações | Superfície |
|---|---|---|
| Origem | limpar (`✕`) | `colorBackground` |
| Destino | favoritar (`★`), copiar (`⧉`), mais (`⋮`) | `colorSurface` |

| Propriedade | Default | Vazio | Carregando | Erro |
|---|---|---|---|---|
| Texto | `bodyLarge`, `textPrimary` | placeholder em `textSecondary` | shimmer no lugar do texto | mensagem `§4.8` |
| Ações | visíveis | **ocultas** | desabilitadas | só "tentar de novo" |
| Contador | `n` atual | oculto | congelado | oculto |
| Altura | conteúdo | mínima 120 dp | mínima 120 dp | conteúdo |

**Regra do parcial de ditado** (F2.5, decorre de `docs/stt_spike.md`): texto
parcial usa `textSecondary` em itálico e é **substituído inteiro** a cada
emissão. Nunca concatenar — o whisper reescreve o parcial.

### 5.2 Pílula de idiomas (rodapé)

Um único widget de largura total, dividido em duas metades assimétricas por um
botão circular de troca que **cavalga a junção**.

| Parte | Superfície | Texto |
|---|---|---|
| Metade origem | `colorSurface` | `textPrimary`, `labelLarge` |
| Metade destino | `colorPrimary` | `colorOnPrimary`, `labelLarge` |
| Botão de troca | `colorSurface`, plano 3 | ícone `colorPrimary` |

- Altura 64 dp; botão de troca 56 dp de diâmetro, centrado na junção.
- Cada metade é um alvo de toque próprio que abre o seletor dos 3 idiomas (RN-01).
- Ao trocar, o botão **gira 180°** e as metades trocam de cor em 200 ms.
- Os três alvos (origem, troca, destino) têm ≥ 48 dp — o botão de troca não pode
  encolher para caber texto longo; o texto trunca com reticências.

> **Implementada** em `lib/ui/widgets/language_bar.dart`. Substituiu o par de
> `LanguagePill` isoladas da F1.7 e o botão ⇄ circular que vivia solto entre os
> cards; o seletor dos 3 idiomas virou bottom sheet aberto por cada metade.

### 5.3 Botão de modo (canto superior direito)

Squircle de 64 dp, plano 3, ancorado no canto superior direito e posicionado
para transbordar o limite entre o bloco de marca e o painel.

| Estado | Ícone | Rotação |
|---|---|---|
| Fechado | ícone do modo ativo (`T` texto, onda para voz) | 0° |
| Aberto | `✕` | 90°, 200 ms |

**A transformação é in-place.** O mesmo botão vira o fechar do menu — não
aparece um `✕` novo em outro lugar. É o que dá a sensação de que o menu saiu
dali de dentro.

### 5.4 Menu de modos (overlay)

Painel que sobe cobrindo a tela, com o conteúdo anterior **esmaecido e
desfocado** atrás (não escurecido com scrim opaco).

- Grid de 2 colunas, squircles de ~140 dp, gap `AppSpacing.md`.
- Cada item: ícone linear centralizado + rótulo abaixo, em `labelMedium`.
- Indicador de páginas (dots) acima do grid, quando houver mais de uma página.

| Estado do item | Fundo | Borda | Ícone/rótulo |
|---|---|---|---|
| Padrão | `colorSurface` | 1 dp `colorBorder` | `textSecondary` |
| Selecionado | `colorSurface` | **2 dp `colorPrimary`** | `colorPrimary` |
| Pressionado | `colorPrimaryContainer` | 2 dp `colorPrimary` | `onPrimaryContainer` |
| Indisponível | `colorSurface` | 1 dp `colorBorder` | 38% de opacidade |

> **Este overlay não é usado na v1** — ver [§9.2](#92-como-o-seletor-evolui-com-a-contagem).
> Com 2 modos, o botão do canto alterna direto. A especificação acima fica pronta
> para quando o terceiro modo entrar.

### 5.5 Abas de conteúdo

Abas de texto puro, sem cápsula e sem fundo. Sublinhado de 3 dp em
`colorPrimary` **apenas** no ativo; ativo em `colorPrimary` + peso 600, inativos
em `textSecondary` + peso 400. Divisor de 1 dp `colorBorder` sob a fileira toda.

### 5.6 Chip

Pílula pequena, `radiusPill`, `colorPrimaryContainer` de fundo,
`onPrimaryContainer` de texto, `labelSmall`, padding `sm`/`xs`. Sem borda.

### 5.7 Visualizador de onda (modo voz)

Barras verticais de 2 dp com gap de 2 dp, `colorOnPrimary` sobre o bloco de
marca, altura proporcional à amplitude, ancoradas no centro vertical.

- Barras já reconhecidas: opacidade 100%. Barras à frente do cursor: 30%.
- Abaixo da onda: tempo decorrido (`titleMedium`) + botão-pílula de estado com
  um ponto de gravação em `colorError`.
- **Sem áudio real disponível, não anime aleatoriamente.** Onda falsa em app de
  ditado é mentira de interface: se o nível não vem do microfone, mostre um
  indicador de escuta neutro.

---

### 5.8 Botão de microfone (F2.5)

Ícone linear de 24 dp num alvo de 48 dp, na barra de ações do card de origem.
**Monocromático**, exceto no estado de escuta — a gravação é uma das três
exceções cromáticas da §6.

| Propriedade | Ocioso | Preparando | Escutando | Erro |
|---|---|---|---|---|
| Ícone | `mic_none` (contorno) | `mic_none` | `mic` | `mic_off` |
| Cor | `colorPrimary` | `textSecondary` | `colorError` | `colorError` |
| Fundo | nenhum | nenhum | `colorPrimaryContainer` | nenhum |
| Anel pulsante | — | — | `colorError` a 24%, 1,2 s | — |
| Toque | inicia | ignorado | encerra | limpa o erro |
| Semântica | `actionDictate` | `actionDictate` | `actionStopDictation` | `errMicPermission` |

- **Ausente, não desabilitado**, quando o build não tem modelo de STT: o widget
  não entra na árvore (`SpeechViewModel.canDictate`). Controle permanentemente
  inerte é pior que sua ausência.
- Háptico curto (`HapticFeedback.selectionClick`) ao iniciar e ao encerrar.

> **Desvio registrado da issue #25.** A issue pede "idle (outline verde)". Não
> existe verde de ação na paleta Azul & Branco (F0.10) — `colorSuccess` é
> semântico de sucesso, não de ação. O ocioso usa `colorPrimary`, que é a cor
> de ação do sistema. A issue precede a troca de paleta.

### 5.9 Folha de escuta (F2.5)

Bottom sheet modal sobre scrim `colorOverlay`, plano 2, topo arredondado.

| Propriedade | Escutando | Processando |
|---|---|---|
| Texto | parcial em `textSecondary` **itálico**, `headlineSmall`, rolável | último parcial, opacidade 60% |
| Indicador | ponto `colorError` pulsando + rótulo de escuta | indeterminado |
| Onda | 32 barras, nível real do microfone (§5.7) | congelada no último nível |
| Cronômetro | `mm:ss` em `titleMedium`, `textPrimary` | congelado |
| Botão esquerdo | Cancelar (texto) | desabilitado |
| Botão direito | Concluir (preenchido) | desabilitado |

- O parcial **substitui** o bloco inteiro a cada emissão (§5.1, regra do parcial).
- Rola sozinha para o fim quando o texto passa da altura visível.
- Fechar por gesto/`back` equivale a **Concluir**, não a Cancelar: coerente com
  a RN-07, que prefere preservar a fala a descartá-la.
- Um único `AnimationController` alimenta o pulso do ponto e o do anel do botão.

**A onda usa nível real** (F2.2b). O `record` entrega amplitude em dBFS; o
`SpeechViewModel` normaliza para 0..1 e mantém um histórico rolante de 32
posições. Se a fonte de áudio não souber medir, `hasAudioLevel` fica `false` e a
onda **não é desenhada** — a §5.7 proíbe suprir a falta com movimento aleatório.

Adaptação da §5.7 para esta superfície: lá as barras são `colorOnPrimary` porque
vivem sobre o bloco de marca; aqui a folha é `colorSurface`, então as barras usam
`colorPrimary`. A geometria (2 dp de largura, 2 dp de gap, ancoradas no centro
vertical) não muda.

> **Histórico.** A F2.5 entregou um indicador neutro no lugar da onda, porque
> ainda não havia captura de áudio e a §5.7 proíbe onda sem amplitude. A F2.2b
> trouxe a fonte real e o conflito deixou de existir.

---

## 6. Ícones

- **Lineares**, stroke 2 dp, terminações e junções arredondadas, sem preenchimento.
- Tamanho padrão 24 dp; 20 dp em cabeçalhos de card; 28 dp no grid de modos.
- **Monocromáticos**, herdando a cor do contexto. Três exceções, e só três:
  favorito ativo (`colorWarning`), ponto de gravação (`colorError`), indicador
  de sucesso (`colorSuccess`).
- Todo ícone que é ação precisa de `Semantics(button: true)` e alvo ≥ 48 dp,
  ainda que o desenho tenha 20 dp (RN-06).

---

## 7. Movimento

| Transição | Duração | Curva |
|---|---|---|
| Troca de idiomas (giro + cores) | 200 ms | `easeInOut` |
| Abertura do menu de modos | 280 ms | `easeOutCubic` |
| Ícone do botão de modo (`T` ↔ `✕`) | 200 ms | `easeInOut` |
| Painel subindo / sheet | 280 ms | `easeOutCubic` |
| Chegada de texto traduzido | 150 ms fade | `easeOut` |

Nada acima de 300 ms. Movimento serve para explicar de onde a coisa veio; passou
disso, vira espera.

---

## 8. A cor primária

O layout do case assenta **texto sobre um bloco de marca de largura total**. É
esse padrão que decide a primária, porque ele exige que a cor da marca seja um
fundo de texto legível — e não toda cor de marca é.

**O verde não era.** Branco sobre `#16A34A` dá **3,30:1**, abaixo do mínimo AA de
4,5:1; no tema escuro, branco sobre `#4ADE80` dá **1,74:1**. O cabeçalho do case
era inviável com aquela paleta.

**A primária foi amostrada do case, não escolhida a olho.** Analisando os pixels
dos três arquivos em [`docs/design/`](design/), a cor de marca dominante é
`#3954FD` (5,4% da prancha de voz), e o fundo tintado é `#F5F6FF`. Ambos entraram
na paleta com esses valores.

| Combinação | Contraste | AA texto normal |
|---|---|---|
| `onPrimary` sobre `colorPrimary` light (`#FFFFFF` / `#3954FD`) | **5,44:1** | ✅ |
| `onPrimary` sobre `colorPrimary` dark (`#080F33` / `#93A4FF`) | **7,99:1** | ✅ |
| `onPrimaryContainer` sobre `colorPrimaryContainer` | 12,79:1 | ✅ |
| `textSecondary` sobre `colorSurface` | 5,49:1 | ✅ |
| `colorPrimary` sobre `colorSurface` (ícone, link) | 5,44:1 | ✅ |

**Regras que permanecem obrigatórias**, mesmo com a margem folgada:

1. Nunca escrever `Colors.white` sobre `colorPrimary`. Sempre `colorOnPrimary` —
   no tema escuro ele é quase preto, e é o que sustenta os 7,99:1.
2. Texto pequeno sobre superfície de marca usa `colorPrimaryContainer` +
   `onPrimaryContainer` (12,79:1), nunca `colorPrimary`.
3. Toda combinação texto/fundo nova entra em
   [`test/theme/palette_contrast_test.dart`](../test/theme/palette_contrast_test.dart),
   que reprova o build abaixo de 4,5:1. Foi a ausência dessa trava que deixou o
   problema do verde passar da F0.2 até aqui.

**O que a troca custou em código: nada.** Só os 28 valores de `app_colors.dart`
mudaram. Nenhum widget, nenhum teste de UI, nenhum `ThemeData` — que era
exatamente a promessa feita na F0.2 e nunca antes exercitada.

**Cores de estado deixaram de disputar com a marca.** Com a primária verde,
`colorSuccess` era o mesmo hex da marca: "online" e "botão primário" tinham a
mesma cor. Agora `colorSuccess` (`#15803D`) é inequivocamente um estado.

---

## 9. Modos de tradução — v1 e roadmap

O case desenha **seis** modos. A v1 do Translatoo entrega **dois**. Os outros
quatro ficam especificados aqui de propósito: quando entrarem no roadmap, o
desenho já existe e ninguém precisa reabrir o case.

> ⚠️ **Especificado ≠ aprovado.** Nada abaixo de "roadmap" está no escopo do
> `prd.md` — Câmera/OCR e Conversa estão explicitamente **fora de escopo**, e
> Manuscrito e Importar nunca estiveram nele. Este capítulo é memória de design,
> não autorização de implementação. Cada modo precisa de decisão de produto,
> issue própria e revisão do PRD antes de virar código.

### 9.1 Estado atual

| Modo | Ícone | Situação | Fase |
|---|---|---|---|
| **Texto** | `T` serifado | ✅ v1 | M1 / F1 |
| **Voz** | onda sonora | ✅ v1 | M2+M3 / F2 |
| Câmera (OCR) | moldura de foco | 🔒 roadmap | fora de escopo (PRD) |
| Manuscrito | rabisco contínuo | 🔒 roadmap | nunca no escopo |
| Importar | imagem com seta | 🔒 roadmap | nunca no escopo |
| Conversa | dois balões | 🔒 roadmap | fora de escopo (PRD) |

### 9.2 Como o seletor evolui com a contagem

O componente **muda de forma conforme o número de modos disponíveis** — e é essa
a regra que evita construir hoje uma cerimônia vazia:

| Modos ativos | Forma do seletor |
|---|---|
| **2** (v1) | **Sem overlay.** O botão do canto (§5.3) alterna direto: um toque troca Texto ↔ Voz, com o ícone fazendo cross-fade de 200 ms |
| 3 a 4 | Overlay com grid 2×2 (§5.4), sem paginação |
| 5 a 6 | Overlay com grid 2×2 **paginado**, com os dots acima do grid |
| 7+ | Grid rolável, dots substituídos por barra de rolagem |

Um overlay de tela cheia para escolher entre duas coisas é cerimônia sem
conteúdo — por isso a v1 usa a primeira linha. A migração para as demais é
puramente aditiva: o grid da §5.4 já está especificado e não precisa ser
redesenhado quando o terceiro modo chegar.

### 9.3 Especificação dos modos de roadmap

Todos herdam a anatomia da §4: bloco de marca no topo, painel de resultado
subindo por cima, pílula de idiomas no rodapé. O que muda é **só a faixa
superior**, onde hoje mora o texto de origem ou a waveform.

**Câmera (OCR).** O bloco de marca vira o preview da câmera em tela cheia. Sobre
ele, um retângulo de foco com cantos em L (`colorOnPrimary`, stroke 3 dp) e, ao
detectar texto, blocos traduzidos sobrepostos no lugar do original. Obturador
como círculo de 72 dp no rodapé, acima da pílula. Congelado o quadro, o painel de
resultado sobe normalmente. Precisa de estado "procurando texto" distinto de
"nenhum texto encontrado" — o segundo é o caso comum e não pode parecer erro.

**Manuscrito.** O card de origem vira uma área de escrita com pauta pontilhada
em `colorBorder`. O traço é `colorPrimary`, largura 3 dp, com suavização.
Reconhecimento incremental: o texto interpretado aparece no topo da área, em
`textSecondary`, e é substituído a cada traço — mesma regra de parcial
substituível do ditado (§5.1). Ações fixas: desfazer, limpar, confirmar.

**Importar.** Não tem tela própria: é um item do grid que abre o seletor de
arquivos do sistema e cai no fluxo de OCR ou de texto conforme o tipo. O único
desenho necessário é o **estado de progresso** — card de origem com barra
determinada e nome do arquivo em `labelMedium`, cancelável.

**Conversa.** É o único que rompe a anatomia da §4, e por isso o mais caro. A
tela se divide em duas metades espelhadas, cada uma com seu idioma e sua
orientação de leitura — a de cima rotacionada 180°, para a pessoa do outro lado
da mesa. Cada metade tem seu botão de microfone; as falas empilham como bolhas
de conversa, alinhadas ao seu lado. A pílula de idiomas do rodapé some: cada
metade traz o seu. **Consequência a registrar antes de qualquer estimativa:**
este modo precisa de dois `SttService` simultâneos ou de troca rápida de idioma
no motor — com o whisper (`docs/stt_spike.md`), que carrega um modelo
multilíngue único, a troca é barata, mas a captura simultânea não é.

### 9.4 Abas de conteúdo secundário (Definitions / Synonyms)

O case mostra abas de **Translation / Definitions / Synonyms** sob o resultado.
O componente está especificado na §5.5 e é reaproveitável, mas o conteúdo não
existe: o ML Kit **traduz, não define**. Definições e sinônimos exigiriam um
dicionário embarcado por idioma — outro modelo, outro orçamento de tamanho,
outra licença.

Na v1 a fileira de abas **não é renderizada** (uma aba só não é uma aba). Se um
dicionário entrar no roadmap, a §5.5 já cobre a forma; o que falta é a fonte de
dados, e essa é uma decisão de produto do porte da spike F2.0.

## 10. Conflito estrutural em aberto

O rodapé está disputado. O app tem hoje uma `NavigationBar` de 3 abas
(Traduzir / Histórico / Ajustes, F0.8). O case ancora a **pílula de idiomas** no
rodapé em largura total. **Os dois não cabem no mesmo lugar** — empilhados dão
128 dp de crômio fixo, quase um quinto da tela num aparelho médio.

Três saídas:

| Opção | Como fica | Custo |
|---|---|---|
| **A. Gaveta** | `NavigationBar` sai; Histórico e Ajustes vão para o menu ☰ do canto superior esquerdo, como no case. A pílula fica sozinha no rodapé | Reescreve `HomeScreen` (F0.8) e o teste `home_shell_test.dart`; Histórico perde descoberta |
| **B. Pílula acima da barra** | Mantém as 3 abas e põe a pílula logo acima | Barato, mas é justamente o empilhamento de 128 dp — e a pílula deixa de estar na zona do polegar |
| **C. Pílula só na aba Traduzir** | A pílula é conteúdo da tela, não crômio; some em Histórico e Ajustes | Mantém a F0.8 intacta; a pílula flutua sobre a lista, com padding inferior reservado |

**Recomendação: C.** Preserva a navegação já entregue e testada, mantém a pílula
na zona do polegar dentro da tela onde ela faz sentido, e não força uma gaveta —
que no case existe porque aquele app tem 6 modos e muitas telas, e o Translatoo
tem 3.

> **DECIDIDA — opção A** (2026-09-02, product owner). A `NavigationBar` saiu; os
> três destinos vivem numa **gaveta** aberta pelo ☰ do canto superior esquerdo,
> como no case. O rodapé fica inteiro para a `LanguageBar` de largura total.
>
> A opção C chegou a ser decidida e implementada horas antes, e foi **revertida**
> na mesma sessão ao confrontar o case: a gaveta é o que o desenho pede. O custo
> previsto na tabela se confirmou — `HomeScreen` e `home_shell_test.dart` foram
> reescritos, e **Histórico e Ajustes perderam descoberta**: agora exigem dois
> toques e não têm affordance permanente na tela.

---

## 11. Aderência

Além das regras já invioláveis do `CLAUDE.md` (cor só em `app_colors.dart`,
string só em `app_strings.dart`, fonte só em `app_theme.dart`):

- ❌ **Raio cru.** Nada de `BorderRadius.circular(28)` num widget. Sempre token.
- ❌ **Borda para separar.** Se a intenção é hierarquia, mude a superfície (P3).
- ❌ **`Colors.white` / `Colors.black`.** Sempre `colorOnPrimary`, `colorSurface`,
  `textPrimary` — do contrário o tema escuro quebra.
- ❌ **Sombra dura.** `elevation` do Material está zerado no tema de propósito;
  use os planos da §3.
- ❌ **Ícone preenchido** onde a regra é linear (§6).
- ❌ **Texto pequeno sobre `colorPrimary`** — use `colorPrimaryContainer` (§8).
- ❌ **Par texto/fundo novo sem entrada em `palette_contrast_test.dart`** (§8).
- ✅ Todo componente novo entra neste documento com sua tabela de estados **antes**
  de virar widget.
