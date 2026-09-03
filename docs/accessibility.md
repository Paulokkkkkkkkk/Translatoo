# Acessibilidade e privacidade — checklist da F4.5

Requisitos: PRD `RN-05`, `RN-06`, §4.5, `MS-03`.

Cada linha aqui é **verificada por teste**, não por inspeção. Auditoria manual
envelhece: passa uma vez e o próximo widget reintroduz o problema.

## 1. Acessibilidade

| Item | Como é garantido |
|---|---|
| Todo botão de ícone é anunciado | `test/architecture/accessibility_test.dart` reprova `IconButton` sem `tooltip` — sem ele o leitor de tela diz só "botão". |
| Alvo de toque ≥ 48 dp | Mesmo arquivo, sobre `BoxConstraints` (só o que constrange área **tocável**: `minHeight` de barra de progresso não é alvo). Token único: `AppSpacing.minTouchTarget`. |
| Contraste AA de texto (4,5:1) | `test/theme/palette_contrast_test.dart`, nas duas paletas, para todo par texto/fundo em uso. |
| Contraste de objeto gráfico (3:1) | Mesmo arquivo, grupo separado — a SC 1.4.11 pede 3:1, e misturar os limiares reprovaria desenho correto. |
| Rótulo semântico em elemento tocável não-botão | `Semantics(button: true, label: …)` nos cartões e blocos tocáveis (histórico, painel, bloco de voz, barra de idiomas, mini-player, badge). |
| Ordem de foco coerente com a tela | `translate_screen_test.dart` → "a ordem de foco segue a ordem VISUAL". O botão de modo é o último filho do `Stack` (desenha por cima) mas está no alto da tela; a `ReadingOrderTraversalPolicy` padrão ordena por geometria, e o teste trava essa política. |
| Estado anunciado, não só pintado | `ConnectionBadge` é live region; o ditado muda `Semantics` conforme o estado do `SpeechViewModel`. |

**Pendente de aparelho** (não dá para automatizar): percorrer as três telas com
TalkBack ligado e com "tamanho de fonte" no máximo do sistema, confirmando que
nada trunca nem se sobrepõe. Entra no roteiro da #42.

## 2. Privacidade (MS-03: zero coleta)

| Item | Como é garantido |
|---|---|
| Nenhum cliente HTTP próprio em `lib/` | `accessibility_test.dart` reprova `package:http`, `package:dio`, `web_socket_channel` e `HttpClient(`. A única conexão permitida é o download de pacotes do ML Kit, que acontece **dentro do plugin**. |
| Só duas permissões | Mesmo arquivo compara o manifesto com exatamente `{INTERNET, RECORD_AUDIO}` — `INTERNET` para baixar pacotes (RN-02), `RECORD_AUDIO` para o ditado on-device. Uma terceira permissão atrai revisão manual na loja. |
| Logs só em debug | `kDebugMode` guarda toda impressão, inclusive as sondas de `PerfTrace`. Conteúdo do usuário nunca sai em build de release. |
| Tradução em nuvem desligada por padrão | `cloudEnabled = false` na v1 (F4.3). Ligada, ela é opt-in explícito — e a política de privacidade da loja precisa mudar junto **antes** de o padrão inverter. |

**Pendente de aparelho**: captura de tráfego (proxy) durante uma sessão
completa — traduzir, ditar, ouvir, navegar — confirmando que nada além do
download de pacotes sai. É a evidência que o critério de aceite da #41 pede, e
ela precisa de um aparelho com proxy configurado.

## 3. Fora de escopo nesta versão

A **política de privacidade publicada** (RF-REL-03/04) ficou fora do MVP por
decisão de produto. O texto acima descreve o comportamento que ela precisará
declarar quando a v1 for para a loja.
