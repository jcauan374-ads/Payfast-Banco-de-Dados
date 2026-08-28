DROP TABLE IF EXISTS liquidacoes CASCADE;
DROP TABLE IF EXISTS transacoes CASCADE;
DROP TABLE IF EXISTS chaves_pix CASCADE;
DROP TABLE IF EXISTS limites_transacao CASCADE;
DROP TABLE IF EXISTS contas CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    cpf CHAR(11) NOT NULL UNIQUE,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_usuarios_cpf CHECK (cpf ~ '^[0-9]{11}$')
);

CREATE TABLE contas (
    id_conta SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    numero_conta VARCHAR(20) NOT NULL UNIQUE,
    agencia VARCHAR(10) NOT NULL,
    tipo_conta VARCHAR(20) NOT NULL DEFAULT 'CORRENTE',
    saldo DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_contas_usuario FOREIGN KEY (id_usuario)
        REFERENCES usuarios (id_usuario) ON DELETE CASCADE,
    CONSTRAINT ck_contas_tipo CHECK (tipo_conta IN ('CORRENTE', 'POUPANCA', 'PAGAMENTO')),
    CONSTRAINT ck_contas_saldo CHECK (saldo >= 0.00)
);

CREATE TABLE chaves_pix (
    id_chave SERIAL PRIMARY KEY,
    id_conta INT NOT NULL,
    tipo_chave VARCHAR(20) NOT NULL,
    valor_chave VARCHAR(140) NOT NULL UNIQUE,
    status VARCHAR(15) NOT NULL DEFAULT 'ATIVA',
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_chaves_conta FOREIGN KEY (id_conta)
        REFERENCES contas (id_conta) ON DELETE CASCADE,
    CONSTRAINT ck_chaves_tipo CHECK (tipo_chave IN ('CPF', 'EMAIL', 'TELEFONE', 'ALEATORIA')),
    CONSTRAINT ck_chaves_status CHECK (status IN ('ATIVA', 'INATIVA'))
);

CREATE TABLE transacoes (
    id_transacao SERIAL PRIMARY KEY,
    id_conta_origem INT NOT NULL,
    id_conta_destino INT NOT NULL,
    id_chave_pix INT NULL,
    valor DECIMAL(14,2) NOT NULL,
    tipo_transacao VARCHAR(20) NOT NULL DEFAULT 'PIX',
    status VARCHAR(15) NOT NULL DEFAULT 'PENDENTE',
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transacoes_conta_origem FOREIGN KEY (id_conta_origem)
        REFERENCES contas (id_conta) ON DELETE RESTRICT,
    CONSTRAINT fk_transacoes_conta_destino FOREIGN KEY (id_conta_destino)
        REFERENCES contas (id_conta) ON DELETE RESTRICT,
    CONSTRAINT fk_transacoes_chave FOREIGN KEY (id_chave_pix)
        REFERENCES chaves_pix (id_chave) ON DELETE SET NULL,
    CONSTRAINT ck_transacoes_contas_diferentes CHECK (id_conta_origem <> id_conta_destino),
    CONSTRAINT ck_transacoes_valor CHECK (valor > 0.00),
    CONSTRAINT ck_transacoes_tipo CHECK (tipo_transacao IN ('PIX', 'TED', 'DOC')),
    CONSTRAINT ck_transacoes_status CHECK (status IN ('PENDENTE', 'CONCLUIDA', 'FALHA', 'ESTORNADA'))
);

CREATE TABLE liquidacoes (
    id_liquidacao SERIAL PRIMARY KEY,
    id_transacao INT NOT NULL UNIQUE,
    codigo_autenticacao VARCHAR(60) NOT NULL UNIQUE,
    canal_liquidacao VARCHAR(20) NOT NULL DEFAULT 'SPI',
    status_liquidacao VARCHAR(15) NOT NULL DEFAULT 'PROCESSANDO',
    data_liquidacao TIMESTAMP NULL,
    CONSTRAINT fk_liquidacoes_transacao FOREIGN KEY (id_transacao)
        REFERENCES transacoes (id_transacao) ON DELETE CASCADE,
    CONSTRAINT ck_liquidacoes_canal CHECK (canal_liquidacao IN ('SPI', 'INTERNO')),
    CONSTRAINT ck_liquidacoes_status CHECK (status_liquidacao IN ('PROCESSANDO', 'LIQUIDADA', 'REJEITADA'))
);

CREATE TABLE limites_transacao (
    id_limite SERIAL PRIMARY KEY,
    id_conta INT NOT NULL UNIQUE,
    valor_limite_diario DECIMAL(14,2) NOT NULL DEFAULT 5000.00,
    valor_utilizado_dia DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    data_referencia DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_limites_conta FOREIGN KEY (id_conta)
        REFERENCES contas (id_conta) ON DELETE CASCADE,
    CONSTRAINT ck_limites_valor CHECK (valor_limite_diario >= 0.00),
    CONSTRAINT ck_limites_utilizado CHECK (valor_utilizado_dia >= 0.00),
    CONSTRAINT ck_limites_utilizado_ate_limite CHECK (valor_utilizado_dia <= valor_limite_diario)
);

INSERT INTO usuarios (id_usuario, cpf, nome, email, senha_hash) VALUES
(1, '11111111111', 'Ana Souza', 'ana.souza@payfast.com', 'hash_ana_001'),
(2, '22222222222', 'Bruno Lima', 'bruno.lima@payfast.com', 'hash_bruno_002'),
(3, '33333333333', 'Carla Mendes', 'carla.mendes@payfast.com', 'hash_carla_003'),
(4, '44444444444', 'Diego Alves', 'diego.alves@payfast.com', 'hash_diego_004'),
(5, '55555555555', 'Elaine Rocha', 'elaine.rocha@payfast.com', 'hash_elaine_005');

INSERT INTO contas (id_conta, id_usuario, numero_conta, agencia, tipo_conta, saldo) VALUES
(1, 1, '000001-1', '0001', 'CORRENTE', 2500.00),
(2, 2, '000002-2', '0001', 'PAGAMENTO', 1800.00),
(3, 3, '000003-3', '0002', 'POUPANCA', 7500.00),
(4, 4, '000004-4', '0002', 'CORRENTE', 4200.00),
(5, 5, '000005-5', '0003', 'PAGAMENTO', 950.00);

INSERT INTO chaves_pix (id_chave, id_conta, tipo_chave, valor_chave, status) VALUES
(1, 1, 'EMAIL', 'ana.souza@pix.com', 'ATIVA'),
(2, 2, 'CPF', '22222222222', 'ATIVA'),
(3, 3, 'TELEFONE', '+5511999990003', 'ATIVA'),
(4, 4, 'ALEATORIA', 'a1b2c3d4-e5f6-4789-abcd-123456789004', 'ATIVA'),
(5, 5, 'EMAIL', 'elaine.rocha@pix.com', 'INATIVA');

INSERT INTO transacoes (id_transacao, id_conta_origem, id_conta_destino, id_chave_pix, valor, tipo_transacao, status) VALUES
(1, 1, 2, 2, 150.00, 'PIX', 'CONCLUIDA'),
(2, 2, 3, 3, 275.50, 'PIX', 'CONCLUIDA'),
(3, 3, 4, 4, 1000.00, 'PIX', 'PENDENTE'),
(4, 4, 5, 5, 80.00, 'PIX', 'FALHA'),
(5, 5, 1, 1, 320.75, 'PIX', 'ESTORNADA');

INSERT INTO liquidacoes (id_liquidacao, id_transacao, codigo_autenticacao, canal_liquidacao, status_liquidacao, data_liquidacao) VALUES
(1, 1, 'E123456789202601010001', 'SPI', 'LIQUIDADA', CURRENT_TIMESTAMP),
(2, 2, 'E123456789202601010002', 'SPI', 'LIQUIDADA', CURRENT_TIMESTAMP),
(3, 3, 'E123456789202601010003', 'SPI', 'PROCESSANDO', NULL),
(4, 4, 'E123456789202601010004', 'SPI', 'REJEITADA', NULL),
(5, 5, 'E123456789202601010005', 'SPI', 'LIQUIDADA', CURRENT_TIMESTAMP);

INSERT INTO limites_transacao (id_limite, id_conta, valor_limite_diario, valor_utilizado_dia, data_referencia) VALUES
(1, 1, 5000.00, 150.00, CURRENT_DATE),
(2, 2, 3000.00, 275.50, CURRENT_DATE),
(3, 3, 10000.00, 1000.00, CURRENT_DATE),
(4, 4, 5000.00, 80.00, CURRENT_DATE),
(5, 5, 2000.00, 320.75, CURRENT_DATE);

SELECT setval(pg_get_serial_sequence('usuarios', 'id_usuario'), (SELECT MAX(id_usuario) FROM usuarios));
SELECT setval(pg_get_serial_sequence('contas', 'id_conta'), (SELECT MAX(id_conta) FROM contas));
SELECT setval(pg_get_serial_sequence('chaves_pix', 'id_chave'), (SELECT MAX(id_chave) FROM chaves_pix));
SELECT setval(pg_get_serial_sequence('transacoes', 'id_transacao'), (SELECT MAX(id_transacao) FROM transacoes));
SELECT setval(pg_get_serial_sequence('liquidacoes', 'id_liquidacao'), (SELECT MAX(id_liquidacao) FROM liquidacoes));
SELECT setval(pg_get_serial_sequence('limites_transacao', 'id_limite'), (SELECT MAX(id_limite) FROM limites_transacao));
