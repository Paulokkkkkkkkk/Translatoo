# DECISÃO F2.2b — Fonte de captura de áudio

> RF-M2-01 · Status: **decidida → `record` 7.1.1** · Data: 2026-09-02
> Fecha a lacuna aberta pela spike [F2.0](stt_spike.md).

## Problema

A F2.0 escolheu o **motor** de STT e refechou a lista de dependências — mas não
escolheu a **fonte de áudio**. O `whisper_ggml` transcreve um
`Stream<Uint8List>` de PCM16 e **não abre o microfone**. O M2 ficou completo de
ponta a ponta exceto o pedaço que transforma som em bytes.

Enquanto isso, o app montava uma `UnavailableAudioSource` e tocar no 🎤 levava a
`ERR_STT_ENGINE`.

## Critérios (os mesmos eliminatórios da F2.0)

| Critério | Peso | Limiar de reprovação |
|---|---|---|
| Resolve com Dart 3 / Flutter atual | Eliminatório | Não resolver |
| **Não colide com `permission_handler ^11.3.1`** | Eliminatório | Forçar downgrade |
| PCM16 16 kHz mono em **stream** | Eliminatório | Só gravação em arquivo |
| Licença compatível com app comercial | Eliminatório | Copyleft viral |
| Android **e** iOS | Eliminatório | Faltar plataforma |
| Amplitude para a onda (§5.7) | Alto | Ausente |
| Peso somado ao APK | Alto | O `lite` já estoura o orçamento |
| Manutenção ativa | Alto | Abandonado |

O segundo critério é o que **matou o `vosk_flutter`** na F2.0 — ele exigia
`permission_handler ^10.2.0`. Era o primeiro a verificar.

## `record` 7.1.1 — escolhido

Verificado com `flutter pub add record --dry-run` antes de qualquer código:

| Critério | Resultado |
|---|---|
| Resolve com Dart 3 | ✅ `record 7.1.1` |
| Colisão com `permission_handler` | ✅ **nenhuma** — segue em `11.4.0`, intocado |
| PCM16 16 kHz mono em stream | ✅ `startStream(RecordConfig(encoder: pcm16bits, …))` |
| Licença | ✅ BSD-3-Clause |
| Plataformas | ✅ Android, iOS, macOS, Windows, Linux, Web |
| Amplitude | ✅ `onAmplitudeChanged(interval)` → dBFS |
| Peso | ✅ sem binário embutido — usa as APIs nativas de gravação |
| Manutenção | ✅ ativa |

É também o pacote que a documentação do próprio `whisper_ggml` recomenda, com
exatamente esta `RecordConfig`.

**Nenhum concorrente foi medido**, e isso é deliberado: diferente da F2.0, aqui
não havia decisão em aberto — o candidato recomendado pelo motor passou em todos
os eliminatórios na primeira tentativa. Reabrir se algum deles deixar de valer.

## Consequências aplicadas

- `pubspec.yaml`: `record: ^7.1.1` entra e a lista fechada **volta a estar
  fechada**.
- `record_audio_source.dart` é o **único** arquivo que importa `record`, como
  `whisper_stt_engine.dart` é o único que importa `whisper_ggml`.
- `UnavailableAudioSource` foi **removida** — era código morto depois disto.
- `SttAudioSource` ganhou `Stream<double> get amplitude`, que destravou a onda da
  F2.5 (ver abaixo).

## Duas decisões de implementação

**Permissão não passa pelo `record`.** O pacote tem o próprio `hasPermission()`,
e usá-lo criaria um segundo dono da decisão, com outro fluxo de diálogo. Quem
manda continua sendo o `MicPermissionService` da F2.3, chamado pelo
`SpeechViewModel` antes de o áudio abrir.

**O piso da escala de amplitude é −45 dBFS**, não o mínimo real do `record`
(que chega a −160 dB). Mapeando a escala inteira, uma fala normal a −20 dB daria
0,875 e a onda ficaria praticamente reta. Com o piso em −45 dB a fala ocupa o
meio da escala e a onda respira. Há teste para essa propriedade.

## A onda deixou de ser um desvio

A F2.5 entregou um indicador neutro no lugar da waveform porque a §5.7 do design
system proíbe onda sem amplitude real:

> Sem áudio real disponível, não anime aleatoriamente. Onda falsa em app de
> ditado é mentira de interface.

Com o `record` há amplitude real, e o conflito desapareceu: a onda foi
implementada com nível medido de microfone. Quando a fonte não sabe medir,
`SpeechViewModel.hasAudioLevel` fica `false` e nada é desenhado — a regra
continua valendo, só deixou de morder.

## O que isto destrava

- Validação em device do `SttService` (#22), do `SpeechViewModel` (#24) e da UI
  (#25) — os três estavam com "verificado em device" desmarcado.
- A **medição de latência** herdada da F2.0 e ainda em aberto na F2.1 (risco R4):
  medir o primeiro parcial exige falar num microfone de verdade.
