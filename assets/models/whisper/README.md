# Modelo de STT (M2)

Motor escolhido na spike **F2.0**: whisper.cpp via `whisper_ggml`
(ver `docs/stt_spike.md`).

Um único modelo multilíngue cobre **pt, en e zh**:

| Flavor | Arquivo | Tamanho |
|---|---|---|
| `full` | `ggml-base-q5_1.bin` | 56,9 MB |
| `lite` | `ggml-tiny-q5_1.bin` | 30,7 MB |

Os binários **não são versionados** (não cabem no repositório). São baixados na
**F2.1**, que também define o embutimento por flavor, a partir de
`https://huggingface.co/ggerganov/whisper.cpp`.
