# SPIKE F2.0 — Motor de STT offline

> RF-M2-01 · Risco **R5b** · Status: **decidida → `whisper_ggml` (whisper.cpp)**
> Time-box: 5 dias úteis · Data: 2026-08-31

## Problema

O M2 — módulo **P0** — estava sem dependência viável. `vosk_flutter` 0.3.48
saiu da lista fechada de dependências porque não instala. Verificação nesta
spike (`flutter pub add --dry-run vosk_flutter`) mostra que o bloqueio é hoje
ainda mais duro do que o registrado na v1.1:

```
Because every version of vosk_flutter depends on permission_handler ^10.2.0
and translatoo depends on permission_handler ^11.3.1, vosk_flutter is forbidden.
```

Além do `sdk <3.0.0`, o pacote colide com o `permission_handler` que o próprio
M2 precisa para pedir o microfone. **Upstream reprovado nos eliminatórios.**

## Critérios (escritos ANTES de testar)

Reproduzidos do plano, para que a decisão não seja justificada pelo esforço já
investido em nenhum candidato.

| Critério | Peso | Limiar de reprovação |
|---|---|---|
| Resolve com Dart 3 / Flutter atual | Eliminatório | Não resolver |
| Cobertura offline real de pt, en, zh | Eliminatório | Faltar qualquer idioma |
| Licença compatível com app comercial | Eliminatório | Copyleft viral |
| Tamanho somado dos 3 idiomas | Alto | > 180 MB (estoura o flavor `full`) |
| Manutenção ativa (commits < 12 meses) | Alto | Abandonado |
| Resultados parciais em streaming | Alto | Ausente (quebra RF-M2-04) |
| Esforço de integração | Médio | — |

## Candidatos avaliados

### 1. Fork do `vosk_flutter` → `vosk_flutter_2` 1.0.5

Não foi preciso manter um fork próprio: já existe um publicado no pub.dev com a
constraint corrigida, e ele **resolve** com o projeto.

| Critério | Resultado |
|---|---|
| Resolve com Dart 3 | ✅ verificado com `pub add --dry-run` |
| Cobertura pt/en/zh | ✅ modelos oficiais Vosk (Apache-2.0) |
| Licença | ✅ Apache-2.0 |
| Tamanho | ✅ **113 MB** — `small-pt-0.3` 31 MB + `small-en-us-0.15` 40 MB + `small-cn-0.22` 42 MB |
| Manutenção | ❌ **último release há ~2 anos**, uploader não verificado |
| Parciais em streaming | ✅ nativos (`getPartialResult`) |
| Plataformas | ❌ **Android apenas** — sem iOS |

**Reprovado.** Bate no limiar "abandonado" do critério de manutenção, e o
Android-only elimina a plataforma secundária do PRD (§iOS 15.5). Adotá-lo
significaria assumir a manutenção de um binding de terceiro sobre um upstream
estagnado para um módulo P0.

### 2. `sherpa_onnx` 1.13.6

| Critério | Resultado |
|---|---|
| Resolve com Dart 3 | ✅ verificado (`1.13.6`, publicado há 13 dias) |
| Cobertura pt/en/zh | ⚠️ existe, mas **fragmentada** |
| Licença | ✅ Apache-2.0 |
| Tamanho | ⚠️ ~176 MB — 4 MB abaixo do teto |
| Manutenção | ✅ o mais ativo dos três |
| Parciais em streaming | ⚠️ ✅ zh/en · ❌ **pt** |
| Plataformas | ✅ Android, iOS, macOS, Linux, Windows, Web |

O catálogo oficial não tem modelo **streaming** de português. A única cobertura
de pt é o NeMo FastConformer (`stt_pt_fastconformer_hybrid_large_pc-int8`,
103 MB), **não-streaming** — o idioma principal do produto ficaria sem os
resultados parciais que a RF-M2-04 exige. Somando o streaming zipformer
zh(+en) medido nesta spike (73,1 MB de arquivos int8 reais), o total fica em
~176 MB: dentro do teto, mas sem margem alguma.

Também foi medido o whisper-tiny servido pelo próprio sherpa-onnx, como forma
de cobrir os 3 idiomas com um modelo só: **98,8 MB** (`tiny-encoder.int8`
12,3 MB + `tiny-decoder.int8` 85,7 MB + tokens 0,8 MB). A quantização int8 do
decoder em ONNX é ineficiente — ver a comparação no candidato 3.

**Não escolhido**, mas é o **plano B formal** (ver abaixo).

### 3. `whisper.cpp` via `whisper_ggml` 2.6.0 — **ESCOLHIDO**

whisper.cpp v1.9.1 empacotado como plugin Flutter, publisher verificado.

| Critério | Resultado |
|---|---|
| Resolve com Dart 3 | ✅ verificado (`2.6.0`, publicado há 27 dias) |
| Cobertura pt/en/zh | ✅ **um único modelo multilíngue** cobre os três |
| Licença | ✅ MIT (plugin) + MIT (whisper.cpp) — sem copyleft |
| Tamanho | ✅ **56,9 MB** — `ggml-base-q5_1.bin`, os 3 idiomas juntos |
| Manutenção | ✅ ativa, publisher verificado |
| Parciais em streaming | ✅ com ressalva (ver abaixo) |
| Plataformas | ✅ Android 21+, iOS 15.6+, macOS, Windows, Linux |

## Medições

Tamanhos aferidos nesta spike, extraindo os pacotes e medindo os arquivos que
de fato entrariam no APK — não os `.tar.bz2`, que embalam várias quantizações.

| Motor | Cobertura pt+en+zh | Tamanho real | Parciais |
|---|---|---|---|
| **whisper_ggml** `ggml-base-q5_1` | 1 modelo | **56,9 MB** | refinados |
| whisper_ggml `ggml-tiny-q5_1` | 1 modelo | 30,7 MB | refinados |
| sherpa-onnx whisper-tiny int8 | 1 modelo | 98,8 MB | não |
| Vosk small ×3 | 3 modelos | 113,0 MB | nativos |
| sherpa-onnx zipformer zh/en int8 + NeMo pt int8 | 2 modelos | ~176 MB | só zh/en |

O dado que decidiu: **o whisper `base` em ggml q5_1 (56,9 MB) é menor que o
whisper `tiny` em ONNX int8 (98,8 MB)** — modelo maior, arquivo quase metade.
O formato ggml quantiza o decoder muito melhor que o int8 do ONNX, e é o
decoder que domina o peso do whisper.

## Decisão

**`whisper_ggml: ^2.6.0`, com `ggml-base-q5_1.bin` embutido no flavor `full`.**

Justificativa contra os critérios ponderados:

1. **Tamanho** — 56,9 MB contra 113 MB (Vosk) e ~176 MB (sherpa). Sobram mais
   de 120 MB de orçamento no flavor `full`, e abre a possibilidade de o flavor
   `lite` embarcar `ggml-tiny-q5_1` (30,7 MB) em vez de nenhum STT.
2. **Um modelo, três idiomas** — elimina o gerenciamento de pacotes por idioma
   no M2 e o estado `initializing` por troca de idioma (RF-M2-02 simplifica).
3. **Qualidade em ZH** — é o ponto mais fraco do Vosk small e o mais forte do
   whisper; o mandarim é um terço do produto.
4. **Licença e manutenção** — MIT, publisher verificado, release há 27 dias.
5. **Plataformas** — preserva o iOS, que o fork do Vosk descartaria.

### Ressalva registrada: os parciais não são nativos

whisper.cpp **não** tem streaming incremental como o Vosk. O `whisper_ggml`
implementa sessões ao vivo que emitem transcrições parciais **progressivamente
refinadas**: o texto já exibido pode ser **reescrito**, não apenas estendido.

Consequência de design, a respeitar na **F2.5**: o overlay de escuta deve
tratar o parcial como um bloco substituível a cada emissão, nunca concatenar
emissões. A RF-M2-04 é atendida — há feedback contínuo durante a fala — mas a
semântica difere da assumida na v1.0, e o `SttService` deve documentá-la no
contrato.

### Risco em aberto: latência em device médio

**Não medido nesta spike** — não havia Android físico disponível no ambiente em
que ela rodou. whisper.cpp é mais pesado em CPU que um zipformer streaming, e
o alvo do PRD §latência é **≤ 500 ms para o início da escuta** com o modelo já
carregado. Mitigadores já disponíveis no pacote: `keepModelLoaded: true`
(evita o carregamento de vários segundos a cada uso) e o *adaptive energy gate*
contra alucinação em silêncio.

**Ação obrigatória na F2.1**: medir, em Android físico de gama média, (a) tempo
de carga do modelo, (b) latência do primeiro parcial e (c) latência do final
após a pausa de 1,5 s. Se `base-q5_1` não couber no orçamento, a escada de
recuo é: `tiny-q5_1` (30,7 MB) → **plano B: `sherpa_onnx`** com zipformer
streaming para zh/en e NeMo para pt, aceitando os ~176 MB e a ausência de
parciais em pt.

O plano de contingência do plano de implementação (`SttService` como
`Unavailable`, botão 🎤 oculto, M2 rebaixado para v1.1) **não foi acionado**:
não exige aprovação do product owner porque nenhum eliminatório reprovou todos
os candidatos.

## Consequências aplicadas

- `pubspec.yaml`: `whisper_ggml: ^2.6.0` entra e a **lista fechada de
  dependências volta a estar fechada**; o bloco comentado do `vosk_flutter`
  sai.
- `assets/models/vosk-small-{pt,en,zh}/` → **`assets/models/whisper/`**, um só
  diretório, coerente com um só modelo.
- `Language.voskCode` → **`Language.sttCode`**: o enum é a fonte única dos
  códigos externos (RN-01) e não pode nomear um motor que não é mais o nosso.
  Os valores (`pt`, `en`, `zh`) coincidem com os códigos de idioma do whisper.
- RF-M2-01 do PRD atualizado com o motor escolhido.

## Revisão futura

Reabrir se: (a) o sherpa-onnx publicar um modelo **streaming de português** —
resolve a única fraqueza real do plano B; ou (b) a medição de latência da F2.1
reprovar o whisper em gama média.
