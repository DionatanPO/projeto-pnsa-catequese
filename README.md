# PNSA Catequese

Sistema de gestão para catequese paroquial desenvolvido em Flutter. Gerencia catequistas, catequizandos, turmas e relatórios da Paróquia Nossa Senhora Auxiliadora (PNSA).

## Funcionalidades

- **Login** — Tela de autenticação com credenciais pré-definidas
- **Catequistas** — Cadastro, edição e listagem de catequistas
- **Catequizandos** — Cadastro completo via wizard de 6 etapas (identificação, histórico sacramental, contatos, saúde, documentos, termos)
- **Turmas** — Cadastro e gerenciamento de turmas com número de alunos
- **Relatórios** — Visualização de dados consolidados
- **Perfil** — Informações do usuário logado
- **Menu responsivo** — NavigationRail em telas largas, Drawer em telas estreitas

## Tecnologias

- **Flutter** 3.24+ — Framework cross-platform
- **Dart** 3.5+ — Linguagem
- **GetX** 4.7 — Gerenciamento de estado, injeção de dependência e navegação
- **Material Design 3** — Tema expressivo com全套 de componentes (cards, botões, navegação, formulários, pickers)

## Estrutura

```
lib/
├── main.dart                          # Entry point
├── app/
│   ├── core/
│   │   ├── bindings/                  # Injeção de dependências
│   │   └── theme/                     # Tema M3 (cores, tipografia, shapes)
│   ├── modules/
│   │   ├── catequista/                # Módulo de catequistas
│   │   ├── catequizandos/             # Módulo de catequizandos (wizard)
│   │   ├── home/                      # Tela principal com menu
│   │   ├── login/                     # Tela de login
│   │   ├── profile/                   # Perfil do usuário
│   │   ├── relatorio/                 # Relatórios
│   │   └── turma/                     # Módulo de turmas
│   └── routes/                        # Definição de rotas GetX
```

Cada módulo segue o padrão MVVM:
- `models/` — Dados e lógica de negócio
- `viewmodels/` — Estado e controle (GetX controllers)
- `views/` — Interface do usuário

## Como executar

```bash
flutter pub get
flutter run
```

## Credenciais de teste

- **E-mail:** admin@pnsa.com
- **Senha:** 123456

## Licença

Este projeto é de uso interno da Paróquia Nossa Senhora Auxiliadora.
