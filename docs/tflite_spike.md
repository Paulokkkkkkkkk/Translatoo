# SPIKE F1.4 — Plano B: tradução NMT on-device via LiteRT (TFLite)

> RF-M1-07 / AC-M1-4 · Status: **inconclusiva → feature-flag DESLIGADA**
> (`AppConstants.enableAlternativeEngine = false`) · Data: 2026-08-26

## Objetivo

Cobrir aparelhos sem Google Play Services (cenário China) com um segundo
motor de tradução, atrás da mesma interface `TranslationBackend`.

## Opções avaliadas

| Opção | Peso/pair | Qualidade | Veredicto |
|---|---|---|---|
| OPUS-MT destilada → ONNX → LiteRT | ~40–80 MB | Boa p/ en↔pt; zh fraco | Conversão ONNX→TFLite de attention imatura; ops ausentes no runtime atual |
| Marian (MarianMT) convertida | ~70 MB+ | Boa | Sem pipeline de conversão mantido; risco R1 alto |
| CTranslate2 → TFLite | n/a | n/a | CTranslate2 não exporta LiteRT; exigiria runtime próprio |
| MLKit (Plano A) | ~30 MB | Referência | Requer GMS — lacuna que motivou esta spike |

Bloqueio transversal: **tokenização**. Todos os candidatos usam
SentencePiece/BPE e não existe tokenizador NMT estável no ecossistema Dart
sem FFI custom por plataforma — custo incompatível com a v1.

## Decisão (conforme "limitação honesta" do plano)

- `TfliteTranslationBackend` permanece implementado atrás da interface,
  reportando `not-ready`; nenhum modelo é embutido em `assets/models/tflite/`.
- O fluxo **AC-M1-4 continua testável** via fakes da interface
  (ver `translation_service_test.dart` — cenário de fallback).
- UI nunca vê stacktrace: apenas o badge discreto "Motor alternativo"
  quando a flag for ligada no futuro.

## Revisão futura

Reabrir na F4 se: (a) LiteRT ganhar suporte oficial a modelos seq2seq +
SentencePiece; ou (b) o modo híbrido nuvem (P2) assumir este nicho.
Trade-off tamanho × qualidade fica registrado nesta nota como apêndice do PRD.
