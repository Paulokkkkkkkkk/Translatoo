---
trigger: always_on
---

# Workflow por Fase e Módulo

A cada fase ou subfase executada no projeto Translatoo, o agente deve obrigatoriamente:

1. **Utilizar as Skills & Agentes Especializados do Fluxo**:
   - **Planejamento/Arquitetura**: `sparc-methodology`, `code-architect`, `design-system`.
   - **Implementação**: `dart-flutter-patterns`, `tdd-workflow`, `tdd-guide`, `foundation-models-on-device`.
   - **Revisão/Qualidade**: `flutter-reviewer`, `silent-failure-hunter`, `a11y-architect`, `security-audit`, `performance-optimizer`.
   - **Filosofia Ponytail**: `ponytail`, `code-simplifier` (soluções concisas, reutilização de código existente).

2. **Executar o Pipeline de Testes e Análise**:
   - `flutter analyze`
   - `dart format --set-exit-if-changed .`
   - `flutter test`

3. **Atualizar o Grafo de Contexto com Graphify**:
   - Executar `python3 scripts/update_context_graph.py` para regenerar os arquivos em `graphify-out/` (`graph.html`, `graph.json`, `GRAPH_REPORT.md`).

4. **Atualizar o `README.md` e `implementation_plan.md`**:
   - Atualizar a tabela de progresso das fases (`F0`, `F1`, `F2`, `F3`, `F4`).
   - Documentar novos serviços, ViewModels ou endpoints na seção de Arquitetura.
