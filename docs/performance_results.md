# Medições de performance — resultados (F4.4 · #40)

Roteiro em [`performance.md`](performance.md). Este arquivo guarda o que já foi
**medido em aparelho físico**; o que falta está marcado.

## Aparelho

| | |
|---|---|
| Modelo | Xiaomi/Redmi `2412DPC0AG` (rodin_global) |
| Tela | 1220×2712, 520 dpi, sw375dp |
| Android | MIUI, locale `pt_BR` |
| Build | `--flavor full`, **debug** — o número pior que o usuário veria |
| Rede | Wi-Fi, DNS `114.114.114.114` / `180.76.76.76` (China), VPN WireGuard ativa |

## Resultados

| Métrica | Alvo | Medido | Veredito |
|---|---|---|---|
| Cold start | < 2000 ms | **1008 ms**, **1022 ms** | ✅ ~50% do orçamento |
| Início de escuta (1ª vez na sessão) | — | **1086 ms** | ⚠️ ver nota |
| Início de escuta (modelo carregado) | ≤ 500 ms | **320 ms** | ✅ |
| Tradução | ≤ 300 ms | — | ⛔ bloqueado |

**Nota sobre o ditado.** O orçamento de 500 ms vale para "modelo já carregado",
e é exatamente o que a medição mostra: 1086 ms na primeira vez (inclui copiar o
`.bin` do whisper para disco e carregar), 320 ms na segunda. O lazy-load da F4.4
está funcionando como projetado — o custo existe, aparece uma vez, e fica fora
do caminho crítico das vezes seguintes.

**Tradução: bloqueada por rede, não por código.** Precisa do pacote de idioma
baixado, e nesta rede o download do ML Kit anda a **3–5 KB/s**:

```
[274] en_pt: 13.950.880 / 37.652.526 bytes   mSpeed=3013
[275] en_zh:    843.776 / 35.347.571 bytes   mSpeed=4093
```

`ping` para `dl.google.com`, `storage.googleapis.com` e
`firebaseml.googleapis.com`: **50% de perda de pacotes**, RTT de 670 a 1810 ms.
O download é real e resumível (HTTP 206), mas leva horas. É o **cenário China**
do PRD (§4.6 · AC-M1-4), e não um defeito do app.

No emulador, na mesma base de código, a tradução mediu **137 ms** na primeira e
**28 ms** na seguinte (pt→en), e **230 ms** / **33 ms** (pt→zh) — dentro do
orçamento, com o pré-aquecimento visível na diferença. Falta repetir em
aparelho físico assim que houver pacote instalado.

## O que falta

- [ ] Tradução em aparelho, curta e de ~500 chars, com o pacote instalado
- [ ] Cenário 4 do roteiro (tradução **fria**, sem deixar aquecer)
- [ ] 60 fps com o overlay de performance do DevTools
- [ ] Repetir cada cenário 5× e registrar a **mediana** (o que está acima são
      amostras isoladas, não medianas)
