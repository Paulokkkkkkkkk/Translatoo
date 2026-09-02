# Modelos de STT — aquisição, embutimento e atualização

> Subfase **F2.1** · RF-M2-01 · PRD §4.7 · Motor decidido na spike
> [F2.0](stt_spike.md): whisper.cpp via `whisper_ggml`.

## O que está embutido

Um único modelo multilíngue cobre **pt, en e zh** — foi essa propriedade que
decidiu a spike contra o Vosk (3 modelos, 113 MB).

| Flavor | Arquivo | Bytes | SHA-256 (prefixo) |
|---|---|---|---|
| `full` | `assets/models/whisper/ggml-base-q5_1.bin` | 59.707.625 (56,9 MB) | `422f1ae4…` |
| `lite` | `assets/models/whisper/ggml-tiny-q5_1.bin` | 32.152.673 (30,7 MB) | `81871056…` |

Origem: <https://huggingface.co/ggerganov/whisper.cpp> · licença MIT, a mesma
do plugin. Os hashes completos vivem em `scripts/fetch_whisper_models.sh`, que
é a fonte única desses valores.

**Os binários são versionados no repositório.** A alternativa (baixar sob
demanda) foi descartada: um clone que não builda sem passo manual quebra o
onboarding, e o app precisa ditar offline desde a primeira execução — RN-02
limita a rede ao download de pacotes de idiomas do M1.

## Por que a cópia para o diretório de dados

O whisper.cpp abre o modelo **por caminho de arquivo**, via FFI. Um asset do
bundle Flutter não tem caminho que o código nativo saiba abrir — no Android ele
vive comprimido dentro do APK. Por isso o
[`WhisperModelInstaller`](../lib/core/services/whisper_model_installer.dart)
materializa o asset como arquivo real em `getApplicationSupportDirectory()` na
primeira escuta, e devolve o caminho absoluto que o `SttService` (F2.2) passa a
`transcribeLive(modelPath:)`.

A cópia é idempotente: o critério de "já instalado" é o **tamanho em bytes**
bater com o do asset. Isso cobre tanto a primeira execução quanto a troca de
modelo por atualização do app (`base` e `tiny` diferem em 27 MB) sem pagar o
hash de 57 MB a cada abertura do app.

## Atualizar os modelos

```bash
# 1. Verificar o que está no repositório (não usa rede)
bash scripts/fetch_whisper_models.sh

# 2. Trocar de versão: edite os SHA-256 em scripts/fetch_whisper_models.sh
#    para os do upstream novo e rebaixe
bash scripts/fetch_whisper_models.sh --force

# 3. Reinstalar no device — a mudança de tamanho dispara a recópia sozinha
flutter run
```

Trocar a **quantização** (`q5_1` → outra) ou o **tamanho** (`base` → `small`)
não é atualização de rotina: é reverter uma decisão da spike F2.0. Atualize
`docs/stt_spike.md` junto, com as medições que justificam a troca.

## ⚠️ Pendência herdada da spike: latência não medida

A F2.0 registrou como **ação obrigatória da F2.1** medir, em **Android físico
de gama média**, três números:

| Medida | Alvo | Status |
|---|---|---|
| Tempo de carga do modelo | mitigado por `keepModelLoaded: true` | ⛔ não medido |
| Latência do primeiro parcial | — | ⛔ não medido |
| Latência do final após pausa de 1,5 s | ≤ 500 ms para início da escuta (PRD) | ⛔ não medido |

**Não foi possível medir**: não há Android físico disponível no ambiente atual
(o emulador não serve — ele roda a CPU do host e superestima o desempenho de
gama média por uma margem que invalida a comparação).

Escada de recuo, se a medição reprovar o `base-q5_1`:
`tiny-q5_1` (30,7 MB, já embutido no flavor `lite`) → plano B `sherpa_onnx`,
aceitando ~176 MB e a ausência de parciais em pt.

Enquanto a medição não acontecer, o risco **R4** (latência > 300 ms em devices
fracos) permanece aberto para o M2.
