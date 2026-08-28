<div align="center">

# ⚡ PayFast

### Motor de Transações e Liquidação de Pix

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=databricks&logoColor=white)](./sql/schema.sql)
[![DBML](https://img.shields.io/badge/Modelo-DBML-7B61FF?style=for-the-badge)](./sql/modelo.dbml)
[![Status](https://img.shields.io/badge/Status-Acadêmico-beef00?style=for-the-badge&logoColor=black)](#status-do-projeto)

> **Projeto acadêmico de modelagem, normalização e implementação física de um banco de dados para transações Pix.**

[📄 Documento acadêmico](./documentacao/ProjetoBancodeDadosParcial1.0.docx) · [🗄️ Script SQL](./sql/schema.sql) · [📐 Modelo DBML](./sql/modelo.dbml)

</div>

---

## 🧭 Visão geral

O **PayFast** é um projeto desenvolvido no curso de **Análise e Desenvolvimento de Sistemas da UNICID**. A proposta é aplicar conceitos de engenharia reversa, dependências funcionais, normalização e integridade referencial na construção de uma estrutura de banco de dados para um motor de transações e liquidação de Pix.

A organização foi pensada para representar cada assunto do domínio em uma tabela própria, reduzindo redundâncias e evitando anomalias de inserção, atualização e exclusão.

<div align="center">

| 📚 Disciplina | 🧱 Modelo | 🗄️ Banco | 🎯 Foco |
|:---:|:---:|:---:|:---:|
| Banco de Dados | Relacional | PostgreSQL | Normalização até a 3FN |

</div>

---

## 🎯 Objetivos do projeto

- Aplicar a **engenharia reversa** a partir de uma questão do ENADE.
- Identificar violações da **Primeira Forma Normal (1FN)**.
- Projetar um modelo lógico normalizado até a **Terceira Forma Normal (3FN)**.
- Implementar tabelas, chaves, relacionamentos e restrições em PostgreSQL.
- Demonstrar cargas iniciais com dados fictícios para testes acadêmicos.
- Documentar o dicionário de dados e o modelo físico do sistema.

---

## 🧠 Engenharia reversa — ENADE 2017

A fundamentação teórica utiliza a **Questão 34 do ENADE 2017**, que aborda as formas normais de bancos de dados.

O ponto central da análise é o atributo multivalorado `FoneEleitor`, que armazena mais de um telefone na mesma célula. Essa estrutura viola a **1FN**, pois os valores de uma relação devem ser atômicos.

<div align="center">

### ✅ Gabarito analisado

# **Alternativa A — I, apenas.**

</div>

> A análise demonstra que a normalização deve começar pela identificação de valores não atômicos. Como a 2FN e a 3FN pressupõem o atendimento inicial à 1FN, a tabela analisada não pode ser considerada adequada às formas normais seguintes.

<details>
<summary><b>📖 Ver resumo das afirmações</b></summary>

<br>

| Afirmação | Resultado | Justificativa |
|---|:---:|---|
| I | ✅ Verdadeira | O campo `FoneEleitor` possui múltiplos valores e viola a 1FN. |
| II | ❌ Falsa | Separar partido e candidato não resolve o atributo multivalorado. |
| III | ❌ Falsa | A estrutura proposta ainda mantém dependências transitivas. |
| IV | ❌ Falsa | `Numero` identifica o registro e determina os demais atributos. |

</details>

---

## 🧱 Modelo lógico e normalização

O banco é formado por **seis tabelas**, cada uma representando um assunto específico do sistema:

| Tabela | Responsabilidade | Relacionamentos principais |
|---|---|---|
| `usuarios` | Dados cadastrais dos titulares. | Um usuário pode possuir várias contas. |
| `contas` | Número, agência, tipo e saldo. | Pertence a um usuário e possui chaves Pix. |
| `chaves_pix` | Chaves CPF, e-mail, telefone ou aleatória. | Cada chave pertence a uma conta. |
| `transacoes` | Transferências, valores e status. | Relaciona contas de origem e destino. |
| `liquidacoes` | Processamento da liquidação. | Relação 1:1 com uma transação. |
| `limites_transacao` | Controle do limite diário. | Relação 1:1 com uma conta. |

### 🔄 Relacionamentos

```text
usuarios 1:N contas
contas 1:N chaves_pix
contas 1:N transacoes (como origem)
contas 1:N transacoes (como destino)
transacoes 1:1 liquidacoes
contas 1:1 limites_transacao
```

### 🧩 Por que o modelo está na 3FN?

O modelo inicial misturava dados do titular e da conta diretamente na tabela de transações, gerando dependências transitivas. A decomposição em seis tabelas elimina essas dependências e garante que cada atributo não chave dependa exclusivamente da chave primária da sua própria tabela.

Com isso, o projeto reduz redundâncias e evita situações como alterar o nome de um usuário em várias transações ou excluir dados da conta quando apenas uma transação é removida.

---

## 🗂️ Estrutura do repositório

```text
payfast-banco-de-dados/
├── README.md
├── documentacao/
│   └── ProjetoBancodeDadosParcial1.0.docx
└── sql/
    ├── modelo.dbml
    └── schema.sql
```

| Arquivo | Descrição |
|---|---|
| [`README.md`](./README.md) | Documentação visual e técnica do projeto. |
| [`sql/schema.sql`](./sql/schema.sql) | DDL, restrições, DML e ajustes das sequências. |
| [`sql/modelo.dbml`](./sql/modelo.dbml) | Modelo das tabelas e referências entre entidades. |
| [`documentacao/ProjetoBancodeDadosParcial1.0.docx`](./documentacao/ProjetoBancodeDadosParcial1.0.docx) | Documento acadêmico original da equipe. |

---

## ⚙️ Como executar o banco

É necessário ter o **PostgreSQL** instalado e uma base de dados criada. Em seguida, execute o script pelo terminal ou por uma ferramenta como o pgAdmin:

```bash
psql -U seu_usuario -d sua_base -f sql/schema.sql
```

O script realiza as seguintes operações:

1. Remove tabelas anteriores, quando existirem.
2. Cria as seis tabelas do modelo.
3. Aplica chaves primárias, chaves estrangeiras, `CHECK` e `UNIQUE`.
4. Insere cinco registros fictícios em cada tabela.
5. Ajusta as sequências dos campos `SERIAL`.

> Os dados incluídos no script são fictícios e destinam-se exclusivamente a fins acadêmicos e de teste.

---

## 🧰 Tecnologias e conceitos

<div align="center">

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat-square&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=flat-square&logo=databricks&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=white)

</div>

`Modelagem relacional` · `Engenharia reversa` · `Dependências funcionais` · `1FN` · `2FN` · `3FN` · `DDL` · `DML` · `Chaves primárias` · `Chaves estrangeiras` · `Integridade referencial`

---

## 👥 Equipe

Projeto desenvolvido por estudantes de **Análise e Desenvolvimento de Sistemas — UNICID**:

| Integrante | RGM |
|---|---:|
| José Cauan Ferreira da Silva | 42920949 |
| Kauã Bitencourt da Paixão | 41900464 |
| Renan Fernandes Beata Caetano | 1742064911 |
| Felipe Brito da Silva | 42710375 |
| Monica Castro Pacheco | 43703445 |
| Giovanna Peixoto Severo de Araújo | 42357764 |
| Elias Augusto Segura | 42496250 |
| Pedro Henrique Mattos da Costa | 42515297 |
| Cristhian Chagas da Silva | 42588553 |
| Felipe Rocha Amorim | 42494842 |

---

## 🚧 Status do projeto

<div align="center">

![Status](https://img.shields.io/badge/Status-Entrega_acadêmica-beef00?style=for-the-badge&logoColor=black)

</div>

O projeto contém a primeira etapa de concepção, normalização, documentação e implementação física do banco de dados. Novas etapas podem incluir consultas SQL, procedures, views, testes de integridade e uma aplicação de acesso ao sistema.

---

<div align="center">

### ⚡ PayFast

**Problemas reais merecem soluções bem estruturadas.**

[⬆️ Voltar ao início](#-payfast)

</div>
