# Modelo de STT (M2)

Motor escolhido na spike **F2.0**: whisper.cpp via `whisper_ggml`
(ver `docs/stt_spike.md`).

Um único modelo multilíngue cobre **pt, en e zh**:

| Flavor | Arquivo | Tamanho |
|---|---|---|
| `full` | `ggml-base-q5_1.bin` | 56,9 MB |
| `lite` | `ggml-tiny-q5_1.bin` | 30,7 MB |

Os binários **são versionados** aqui desde a F2.1. Para verificar a integridade
ou atualizar para outra versão do upstream:

```bash
bash scripts/fetch_whisper_models.sh          # confere os SHA-256
bash scripts/fetch_whisper_models.sh --force  # rebaixa e substitui
```

Procedimento completo, origem e licença em `docs/whisper_models.md`.
