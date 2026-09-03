# QA final — roteiro de execução dos ACs (F4.6)

O entregável da #42 é a **planilha de execução assinada**. Este documento é a
planilha em branco: cada linha é um AC do PRD, o que fazer, e o que precisa
acontecer. Marque `ok` / `falha` + observação, e cole aqui o resultado da
rodada antes de fechar a issue.

## 0. Antes de começar

- Aparelho **físico** Android de classe média (não emulador — o emulador não
  reproduz governador de CPU, ML Kit real nem motor de voz do fabricante).
- `flutter clean` antes de instalar. **Sempre passe `--flavor`**: sem ele o
  build pega o APK velho de `build/app/outputs/apk/debug/` e você testa a
  versão anterior sem perceber (aconteceu duas vezes neste projeto).
- Instale os pacotes `pt`, `en` e `zh` antes da bateria, salvo onde o cenário
  pedir o contrário.

## 1. Bateria de ACs

| AC | Cenário | Esperado | Resultado |
|---|---|---|---|
| AC-M1-1 | Modo avião, pacotes prontos, digitar "Bom dia" PT→ZH | Tradução ≤ 300 ms após o debounce de 800 ms, sem erro de rede | |
| AC-M1-2 | Selecionar idioma sem pacote | Card de progresso com %, ~30 MB, Baixar/Cancelar; ao concluir, a tradução pendente executa sozinha | |
| AC-M1-3 | Texto nos dois cartões, tocar ⇄ | Idiomas e textos invertidos, retradução, ⇄ desabilitado só durante o processamento | |
| AC-M1-4 | Aparelho **sem acesso aos servidores do Google** (cenário China) | Motor alternativo assume com badge, sem stacktrace nem travamento | |
| AC-F1-5 | Derrubar a rede durante um download | Mensagem da tabela §4.8 com ação sugerida — nunca exceção crua | |
| AC-F1-6 | Emulador limpo **sem pacote de idioma chinês** | Mandarim legível, zero tofu, em Traduzir, Histórico e seletores | |
| AC-M2-1 | Permissão dada, PT, dizer "onde fica o banheiro" | Parciais em tempo real; após ~1,5 s de pausa o final substitui o campo e traduz | |
| AC-M2-2 | Permissão negada **permanentemente**, tocar 🎤 | Diálogo com "Abrir configurações"; nenhuma exceção; resto do app usável | |
| AC-M2-3 | Gravar > 60 s continuamente | Escuta encerra sozinha, último final permanece no campo | |
| AC-M2-4 | Cancelar durante a escuta | Texto volta a ser EXATAMENTE o anterior; nada é traduzido | |
| AC-M3-1 | Tradução pronta com destino ZH, tocar 🔊 | Fala em mandarim pelo motor nativo; botão vira ⏹ e volta a ▶ ao concluir | |
| AC-M3-2 | Aparelho **sem voz chinesa instalada** | SnackBar persistente ensinando instalar a voz; app não trava, resultado permanece | |
| AC-M3-3 | Tocar outra tradução com áudio em andamento | O anterior corta na hora — nunca duas vozes sobrepostas | |
| AC-M3-4 | Velocidade 1.5 nos Ajustes, matar e reabrir o app | 1.5 persiste e vale na próxima reprodução | |
| AC-M4-1 | Fazer 3 traduções, abrir Histórico | Lista da mais recente para a mais antiga, com origem, tradução, pills e horário relativo | |
| AC-M4-2 | Swipe para excluir | "Desfazer" por 5 s restaurando a **posição original**, não o topo | |
| AC-M4-3 | Matar o app pelo gerenciador e reabrir | Par de idiomas, voz, histórico e favoritos intactos | |
| AC-M4-4 | `wifiOnly` ligado, em dados móveis, pedir download | Aviso + opção de baixar mesmo assim (sem alterar a preferência) | |
| RN-07 a | Ir para segundo plano **durante a escuta** | Escuta encerra com o parcial finalizado | |
| RN-07 b | Ir para segundo plano **durante a leitura** | A fala CONTINUA até concluir ou o SO interromper (deliberado — ver o teste em `translate_screen_test.dart`) | |

## 2. Robustez

| # | Cenário | Esperado | Resultado |
|---|---|---|---|
| R1 | Modo avião total, exercitar todas as funções | Nada quebra; só o download é bloqueado, com mensagem própria | |
| R2 | JSON corrompido no storage (editar via `adb`/debug e reabrir) | Reinício limpo, sem tela branca — coberto por `storage_service_test.dart`, confirmar no aparelho | |
| R3 | Perder rede no meio de um download | Erro acionável; retomar funciona | |
| R4 | Rotacionar a tela durante escuta e durante leitura | Estado preservado, sem duplicar sessão | |
| R5 | Fonte do sistema no máximo | Nada trunca nem se sobrepõe (item pendente da F4.5) | |
| R6 | TalkBack ligado, percorrer as três telas | Tudo anunciado, ordem de leitura coerente (item pendente da F4.5) | |
| R7 | Proxy de captura durante sessão completa | Só o download de pacotes sai; zero conteúdo do usuário (MS-03, pendente da F4.5) | |

## 3. Performance

Rode o roteiro de [`docs/performance.md`](performance.md) e cole as medianas.
Cenário acima do orçamento vira issue própria com o log colado.

## 4. Tamanho dos artefatos

| Flavor | Meta | Medido |
|---|---|---|
| `lite` | ⚠️ 40 MB é **inalcançável** — ver [#78](../../issues/78) | |
| `full` | ≤ 180 MB | |

## 5. Bloqueio conhecido

O build de release ([#44](../../issues/44)) está travado pela compatibilidade
com páginas de 16 KB do Android 15 ([#75](../../issues/75)): 11 bibliotecas
nativas reprovam, 6 delas vindas do ffmpeg por dependência transitiva. A
bateria acima pode ser executada em debug/profile, mas a **assinatura dos
números de tamanho** depende do artefato de release.
