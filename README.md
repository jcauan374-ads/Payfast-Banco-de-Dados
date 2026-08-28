# PayFast — Motor de Transações e Liquidação de Pix

Projeto acadêmico desenvolvido no curso de **Análise e Desenvolvimento de Sistemas (UNICID)**. O trabalho apresenta a concepção, a normalização e a implementação física de um banco de dados relacional para um motor de transações e liquidação de Pix.

## Objetivos

O projeto aplica conceitos de engenharia reversa, dependências funcionais, normalização até a **Terceira Forma Normal (3FN)**, integridade referencial e criação de scripts SQL executáveis em PostgreSQL.

A solução foi organizada para separar cada assunto do domínio em uma tabela própria, reduzindo redundâncias e evitando anomalias de inserção, atualização e exclusão.

## Engenharia reversa do ENADE

A fundamentação teórica parte da questão 34 do ENADE 2017, relacionada às formas normais de bancos de dados. O ponto central é a identificação de um atributo multivalorado, `FoneEleitor`, que armazena mais de um telefone na mesma célula e, por isso, viola a Primeira Forma Normal (1FN).

**Gabarito analisado:** alternativa A — somente a afirmação I está correta.

## Modelo lógico

O banco de dados é composto por seis tabelas:

| Tabela | Finalidade |
|---|---|
| `usuarios` | Armazena os dados cadastrais dos titulares. |
| `contas` | Registra número, agência, tipo e saldo das contas. |
| `chaves_pix` | Mantém as chaves Pix vinculadas às contas. |
| `transacoes` | Registra origem, destino, valor, tipo e status das transferências. |
| `liquidacoes` | Controla a liquidação de uma transação junto ao SPI ou internamente. |
| `limites_transacao` | Controla o limite diário e o valor utilizado por conta. |

Os relacionamentos principais são: um usuário pode possuir várias contas; uma conta pode possuir várias chaves Pix; uma conta pode participar de várias transações como origem ou destino; cada transação pode possuir no máximo uma liquidação; e cada conta possui um registro de limite diário.

## Normalização em 3FN

O modelo inicial misturava dados do titular e da conta diretamente na tabela de transações. A decomposição em seis tabelas elimina dependências transitivas e garante que os atributos não chave dependam exclusivamente da chave primária da própria tabela.

Essa estrutura também evita que a alteração do nome de um usuário exija mudanças em várias transações ou que a exclusão de uma transação apague informações cadastrais ou bancárias.

## Estrutura do repositório

| Caminho | Conteúdo |
|---|---|
| `sql/schema.sql` | Script PostgreSQL com DDL, restrições, carga inicial e ajustes das sequências. |
| `sql/modelo.dbml` | Modelo do banco em DBML, compatível com ferramentas como dbdiagram.io. |
| `documentacao/ProjetoBancodeDadosParcial1.0.docx` | Documento acadêmico original enviado pela equipe. |

## Como executar

É necessário ter o PostgreSQL instalado e uma base de dados criada. Depois, execute o script pelo `psql` ou por uma ferramenta gráfica, como pgAdmin:

```bash
psql -U seu_usuario -d sua_base -f sql/schema.sql
```

O script recria as tabelas, insere cinco registros de exemplo em cada entidade e ajusta as sequências dos campos `SERIAL`.

> Os dados presentes no script são fictícios e foram incluídos exclusivamente para fins acadêmicos e de teste.

## Integrantes

José Cauan Ferreira da Silva; Kauã Bitencourt da Paixão; Renan Fernandes Beata Caetano; Felipe Brito da Silva; Monica Castro Pacheco; Giovanna Peixoto Severo de Araújo; Elias Augusto Segura; Pedro Henrique Mattos da Costa; Cristhian Chagas da Silva; Felipe Rocha Amorim.

## Tecnologias e conceitos

PostgreSQL, SQL, modelagem relacional, diagrama entidade-relacionamento, engenharia reversa, dependências funcionais, 1FN, 2FN, 3FN, chaves primárias, chaves estrangeiras, `CHECK`, `UNIQUE` e integridade referencial.

## Licença

Material acadêmico desenvolvido para fins educacionais.
