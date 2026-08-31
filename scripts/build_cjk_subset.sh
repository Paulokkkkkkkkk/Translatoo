#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# F1.9 — Gera o subset CJK (Noto Sans SC) embutido em assets/fonts/.
#
# Reproduz byte a byte os arquivos versionados no repositório. Ver a nota de
# origem, licença e orçamento de tamanho em docs/cjk_font.md.
#
# Uso:  bash scripts/build_cjk_subset.sh
# Requer: python3 (>= 3.9) e rede apenas na primeira execução (baixa a fonte).
# ---------------------------------------------------------------------------
set -euo pipefail

# Build reprodutível: fixa head.modified das fontes (fontTools honra a variável).
export SOURCE_DATE_EPOCH=0

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/assets/fonts"
WORK="${TMPDIR:-/tmp}/translatoo-cjk-subset"
UPSTREAM="https://raw.githubusercontent.com/google/fonts/main/ofl/notosanssc"
# Limite do orçamento por arquivo (PRD §4.9 — os dois pesos somam <= 5 MB).
MAX_BYTES=$((5 * 1024 * 1024 / 2))

mkdir -p "$WORK" "$OUT"

# 1. Ambiente isolado com fonttools (não polui o Python do sistema).
if [ ! -x "$WORK/venv/bin/pyftsubset" ]; then
  python3 -m venv "$WORK/venv"
  "$WORK/venv/bin/pip" -q install fonttools brotli
fi

# 2. Fonte original: variable font oficial do Google Fonts (SIL OFL 1.1).
[ -f "$WORK/NotoSansSC-VF.ttf" ] || \
  curl -fsSL -o "$WORK/NotoSansSC-VF.ttf" "$UPSTREAM/NotoSansSC%5Bwght%5D.ttf"
curl -fsSL -o "$OUT/OFL.txt" "$UPSTREAM/OFL.txt"

# 3. Conjunto de caracteres: os 6.763 hanzi do GB2312 (nível 1 + 2) mais sua
#    pontuação, ASCII e Latin-1 — cobertura de uso corrente do mandarim
#    simplificado. Derivado do codec do próprio Python: nada é digitado à mão.
python3 - "$WORK/charset.txt" <<'PY'
import sys
chars = set()
for b1 in range(0xA1, 0xFF):
    for b2 in range(0xA1, 0xFF):
        try:
            chars.add(bytes([b1, b2]).decode('gb2312'))
        except UnicodeDecodeError:
            pass
chars |= {chr(c) for c in range(0x20, 0x7F)}      # ASCII imprimível
chars |= {chr(c) for c in range(0xA0, 0x100)}     # Latin-1 suplementar
chars |= set('“”‘’—…·、。《》〈〉【】（）％￥°±×÷')   # pontuação CJK usual
with open(sys.argv[1], 'w', encoding='utf-8') as f:
    f.write(''.join(sorted(chars)))
PY

# 4. Instancia o peso estático e recorta ao conjunto acima.
for spec in "400:Regular" "700:Bold"; do
  wght="${spec%%:*}"; style="${spec##*:}"
  "$WORK/venv/bin/fonttools" varLib.instancer --update-name-table \
    "$WORK/NotoSansSC-VF.ttf" "wght=$wght" -o "$WORK/inst-$wght.ttf" >/dev/null

  "$WORK/venv/bin/pyftsubset" "$WORK/inst-$wght.ttf" \
    --output-file="$OUT/NotoSansSC-$style.subset.ttf" \
    --text-file="$WORK/charset.txt" \
    --layout-features='' --no-hinting --desubroutinize \
    --drop-tables+=BASE,vhea,vmtx,DSIG \
    --name-IDs='*' --notdef-outline --recalc-bounds

  size=$(wc -c < "$OUT/NotoSansSC-$style.subset.ttf")
  printf '%-32s %6.2f MB\n' "NotoSansSC-$style.subset.ttf" "$(echo "$size/1048576" | bc -l)"
  if [ "$size" -gt "$MAX_BYTES" ]; then
    echo "ERRO: $style estourou o orçamento de $MAX_BYTES bytes." >&2
    exit 1
  fi
done
