# Contribuindo com o Translatoo

Este projeto é desenvolvido **por fases**, seguindo o
[`implementation_plan.md`](implementation_plan.md) e o [`prd.md`](prd.md).
Cada subfase do plano corresponde a **uma issue** no GitHub.

---

## ⚠️ Regra de créditos (obrigatória)

> **Toda issue concluída deve creditar quem a desenvolveu na seção
> "Créditos por issue" do [README.md](README.md).**

A atualização dessa tabela faz parte do PR que fecha a issue — **não é uma
etapa posterior nem opcional**. Um PR que entrega a funcionalidade mas não
credita o autor **não é aprovado**.

**Por que a regra existe.** O README é o único lugar onde a autoria do
trabalho fica visível para quem chega ao projeto: o histórico do git se dilui,
mas a tabela permanece. Ela também deixa claro quem procurar quando alguém
precisa entender uma parte específica do app.

**Como creditar** — adicione uma linha na tabela do README:

```markdown
| F2.0 | #21 | Spike do motor de STT offline | [@seu-usuario](https://github.com/seu-usuario) |
```

- Use seu handle real do GitHub no formato `[@usuario](https://github.com/usuario)`.
- Se mais de uma pessoa trabalhou na issue, liste todas separadas por vírgula.
- Mantenha a ordem crescente de subfase.
- **Nunca remova nem edite linhas de outras pessoas.**

---

## Fluxo de trabalho

1. **Escolha uma issue** que não esteja atribuída e cujas dependências já
   estejam fechadas (a issue declara suas dependências no topo).
2. **Atribua-se** a ela (`Assignees`) para evitar trabalho duplicado.
3. **Crie uma branch** a partir da `main`:
   ```bash
   git checkout -b f2.0-spike-stt      # <subfase>-<resumo-curto>
   ```
4. **Implemente** respeitando as regras invioláveis (abaixo).
5. **Rode o pipeline de qualidade** — todos os quatro comandos precisam passar.
6. **Atualize o README** com seu crédito.
7. **Abra o PR** usando o template, referenciando `Closes #<n>`.

---

## Pipeline de qualidade (obrigatório antes de todo PR)

```bash
flutter analyze                          # zero warnings
dart format --set-exit-if-changed .      # formatação
flutter test                             # todos verdes
flutter run --release                    # validação manual no device
```

Um PR com qualquer um destes vermelho não entra em revisão.

---

## Regras invioláveis (arquitetura)

Estas regras vêm do PRD §2 e §4.3 e valem para **todo** código do projeto:

1. **Camadas**: `ui/` → ViewModels (`state/`) → `core/services/` → plugins.
   A UI **nunca** importa um plugin diretamente.
2. **Cores** existem somente em `app_colors.dart` (RN-04). Nenhum `Color(0x…)`
   fora dele — widgets consomem via `Theme.of(context)`.
3. **Strings de UI** existem somente em `app_strings.dart`
   (`AppStrings.of(context)`), em pt/en/zh.
4. **Erros**: toda exceção cruza a fronteira de serviço convertida em
   `AppException(ErrorCode)` da tabela única (PRD §4.8). Nenhum stacktrace
   chega à UI.
5. **Design**: [`docs/design_system.md`](docs/design_system.md) é a fonte única
   das regras de forma, raio, elevação, anatomia de tela, componentes, ícones e
   movimento. **Leia antes de tocar em qualquer widget** — não é preciso pedir
   autorização nem esperar alguém apontar o documento. Proibido: raio cru
   (`BorderRadius.circular(28)`), borda para separar, `Colors.white`/`Colors.black`,
   `elevation` do Material, ícone preenchido e texto pequeno sobre `colorPrimary`.
   Componente novo entra no documento com sua tabela de estados **antes** de virar
   widget.
6. **Idiomas**: enum fechado `Language { pt, en, zh }` (RN-01).
7. **Privacidade**: sem telemetria; logs somente em debug; nenhum conteúdo do
   usuário sai do aparelho.
8. **Acessibilidade**: `Semantics` em todo botão de ícone; alvos ≥ 48 dp;
   contraste AA 4.5:1 (RN-06).
9. **Imports** ordenados: dart → flutter → packages → projeto.

---

## Definition of Done

Uma issue só é fechada quando **tudo** isto vale (PRD §6.2):

- [ ] `flutter analyze` sem warnings e código formatado.
- [ ] Testes dos ViewModels/serviços envolvidos passando.
- [ ] Critérios de aceite da issue verificados em Android físico.
- [ ] Nenhuma cor fora de `app_colors.dart`; nenhuma string de UI fora de `app_strings.dart`.
- [ ] UI conforme [`docs/design_system.md`](docs/design_system.md): sem raio cru, sem borda
      para separar, sem `elevation`, sem `Colors.white`/`Colors.black`, ícones lineares.
- [ ] Funcionamento validado em **modo avião** (quando aplicável).
- [ ] Erros mapeados para a tabela §4.8 — nenhuma exceção crua na UI.
- [ ] Mandarim renderizado sem tofu quando a tela exibir `zh`.
- [ ] **Crédito adicionado ao README.**

---

## Commits

Formato convencional, em português:

```
feat(f2.0): registra decisão do motor de STT
fix(f1.9): corrige fallback CJK em telas de histórico
docs(readme): credita autor da F2.0
```
