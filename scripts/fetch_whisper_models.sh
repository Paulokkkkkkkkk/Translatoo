#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# F2.1 — Baixa e verifica os modelos ggml de STT embutidos em assets/.
#
# Os binários SÃO versionados no repositório; este script existe para o
# procedimento de ATUALIZAÇÃO ser reproduzível: baixa do upstream, confere o
# SHA-256 contra o valor fixado aqui e só então substitui o arquivo. Rodar sem
# argumento também serve como verificação de integridade do que já está no
# repositório. Ver docs/whisper_models.md.
#
# Uso:  bash scripts/fetch_whisper_models.sh          # verifica os dois
#       bash scripts/fetch_whisper_models.sh --force  # rebaixa e substitui
# Requer: curl e shasum. Rede só quando um arquivo falta ou com --force.
# ---------------------------------------------------------------------------
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/assets/models/whisper"
UPSTREAM="https://huggingface.co/ggerganov/whisper.cpp/resolve/main"

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

# Modelos fixados: <arquivo> <sha256> <flavor>. A quantização q5_1 é a decisão
# da spike F2.0 (docs/stt_spike.md) — não troque sem atualizar a spike.
MODELS=(
  "ggml-base-q5_1.bin 422f1ae452ade6f30a004d7e5c6a43195e4433bc370bf23fac9cc591f01a8898 full"
  "ggml-tiny-q5_1.bin 818710568da3ca15689e31a743197b520007872ff9576237bda97bd1b469c3d7 lite"
)

mkdir -p "$OUT"

for entry in "${MODELS[@]}"; do
  read -r file expected flavor <<< "$entry"
  target="$OUT/$file"

  if [ "$FORCE" = 1 ] || [ ! -f "$target" ]; then
    echo "baixando $file (flavor $flavor)…"
    curl -fL --progress-bar -o "$target.part" "$UPSTREAM/$file"
    mv "$target.part" "$target"
  fi

  actual="$(shasum -a 256 "$target" | cut -d' ' -f1)"
  if [ "$actual" != "$expected" ]; then
    echo "ERRO: SHA-256 de $file não confere." >&2
    echo "  esperado: $expected" >&2
    echo "  obtido:   $actual" >&2
    exit 1
  fi
  echo "ok  $file  ($(du -h "$target" | cut -f1), flavor $flavor)"
done
