# AGENTS.md — Diretrizes Multi-Agente do Projeto Translatoo

Este repositório segue regras estritas de desenvolvimento, qualidade e documentação contínua para todos os agentes de IA.

## 1. Comandos Essenciais

```bash
# Setup e Execução
flutter pub get
flutter run

# Pipeline de Qualidade Obrigatório
flutter analyze
dart format --set-exit-if-changed .
flutter test

# Atualização do Grafo de Contexto (Graphify)
python3 scripts/update_context_graph.py
```

## 2. Filosofia de Código (Ponytail & Minimalismo)
- **Lazy & Minimal**: Siga a escada de decisão — YAGNI → Reutilizar helpers/padrões existentes → Stdlib/APIs nativas do Flutter/Dart → Dependências já instaladas → Código mínimo de 1 linha antes de escrever 50.
- Use a skill `ponytail` e o agente `code-simplifier` para prevenir over-engineering e reduzir o consumo de tokens.
- Não introduza dependências novas sem necessidade explícita.
- Mantenha conformidade estrita com o `PRD.md` e o `implementation_plan.md`.

## 3. Skills e Agentes Obrigatórios no Fluxo de Desenvolvimento

Os agentes e skills instalados em `.agents/` devem ser ativados nas seguintes etapas:

### A. Planejamento & Arquitetura
- **`sparc-methodology`** & **`code-architect`**: Para planejar e desenhar interfaces e fluxos complexos antes de codificar.
- **`design-system`**: Para garantir uso estrito de [`docs/design_system.md`](docs/design_system.md) — regras de forma, raios, elevação e componentes — além dos tokens de cor Azul & Branco (`app_colors.dart`) e tipografia/espaçamentos.

### B. Implementação & Testes (TDD)
- **`dart-flutter-patterns`**: Padrões de composição assíncrona, Provider/ChangeNotifier e rebuilds cirúrgicos (`Selector`).
- **`tdd-workflow`** & **`tdd-guide`**: Criação de testes unitários isolados para ViewModels e serviços antes ou junto da implementação.
- **`foundation-models-on-device`**: Padrões para inferência offline (ML Kit, Vosk, TFLite).

### C. Revisão & Auditoria de Qualidade
- **`flutter-reviewer`**: Revisão estática de widgets, ciclo de vida e estado.
- **`silent-failure-hunter`** & **`error-handling`**: Garantia de que nenhuma exceção fique solta e seja convertida em `AppException(ErrorCode)`.
- **`a11y-architect`** & **`frontend-a11y`**: Auditoria de Semantics, alvos de toque ≥ 48 dp e contraste AA.
- **`security-reviewer`** & **`security-audit`**: Validação de privacidade on-device e restrição de logs.
- **`performance-optimizer`** & **`latency-critical-systems`**: Orçamento de frames (60 fps) e latência ≤ 300 ms.

### D. Verificação e Fechamento de Fase
- **`verification-loop`**: Execução do pipeline de testes e análise.
- **`doc-updater`**: Atualização do `README.md` e `implementation_plan.md`.

## 4. Regra Obrigatória por Fase / Módulo (Definition of Done)
Ao concluir qualquer fase, subfase ou módulo do projeto:
1. **Pipeline de Qualidade**:
   - `flutter analyze` sem erros nem warnings.
   - `dart format` aplicado em todos os arquivos modificados.
   - `flutter test` rodando e com 100% dos testes passando.
2. **Atualização do Grafo de Contexto (Graphify)**:
   - Rodar `python3 scripts/update_context_graph.py` para re-indexar AST e atualizar `graphify-out/` (`graph.html`, `graph.json`, `GRAPH_REPORT.md`).
3. **Atualização do `README.md` e `implementation_plan.md`**:
   - Atualizar a tabela de status de fases no `README.md`.
   - Documentar novos componentes, ViewModels ou serviços criados.
   - Marcar subfases concluídas no `implementation_plan.md`.

## 5. Regras de Arquitetura Invioláveis
- **Camadas**: `ui/` → ViewModels (`state/`) → `core/services/` → plugins. A `ui/` nunca importa plugins diretamente.
- **Tokens de Cor**: 100% das cores devem vir de `app_colors.dart` (Light/Dark Azul & Branco). Proibido `Color(0x…)` em outros arquivos. Todo par texto/fundo precisa passar em `test/theme/palette_contrast_test.dart` (AA 4,5:1).
- **Strings de UI**: 100% das strings de interface em `app_strings.dart` (i18n manual pt/en/zh). Proibido strings literais nos widgets.
- **Erros**: Toda falha deve ser convertida em `AppException(ErrorCode)` com ação acionável (PRD §4.8).
- **Design (forma, layout e componentes)**: [`docs/design_system.md`](docs/design_system.md) é a **fonte única e obrigatória** das regras visuais — raios, elevação, anatomia de tela, composição de componentes, ícones e movimento. Vale para todo trabalho de UI **sem precisar ser solicitado**. Antes de criar ou alterar qualquer widget, leia o documento; ao criar um componente novo, ele entra lá com sua tabela de estados **antes** de virar código (§11).
  - ❌ **Raio cru**: nada de `BorderRadius.circular(28)`. Sempre token de `app_spacing.dart`.
  - ❌ **Borda para separar**: hierarquia se faz mudando a superfície, não com contorno (§P3). Borda de 1 dp só em elemento selecionável não selecionado.
  - ❌ **`Colors.white` / `Colors.black`**: sempre `colorOnPrimary`, `colorSurface`, `textPrimary` — do contrário o tema escuro quebra.
  - ❌ **Sombra dura / `elevation` do Material**: está zerado no tema de propósito; use os quatro planos da §3.
  - ❌ **Ícone preenchido**: ícones são lineares, stroke 2 dp, monocromáticos herdando a cor do contexto. Exceções apenas para favorito (`colorWarning`), gravação (`colorError`) e sucesso (`colorSuccess`) (§6).
  - ❌ **Texto pequeno sobre `colorPrimary`**: use `colorPrimaryContainer` + `onPrimaryContainer` (§8).
  - ❌ **Par texto/fundo novo sem entrada em `test/theme/palette_contrast_test.dart`** (§8).
  - ⚠️ **Duas pendências registradas — não resolva por conta própria**: (a) os tokens de raio da §2 (`radiusSm/Md/Lg/Pill`) **ainda não existem** em `app_spacing.dart`, que tem só `radius = 12` — enquanto não entrarem por issue própria, nenhum widget novo deve usar número cru; (b) o conflito estrutural do rodapé da §10 (`NavigationBar` de 3 abas × pílula de idiomas em largura total) é **decisão de produto em aberto** e precisa de issue antes de virar código.
- **Idiomas**: Enum fechado `Language { pt, en, zh }` (RN-01).
- **Privacidade & Offline**: Operação 100% local por padrão. Logs apenas em modo debug.
