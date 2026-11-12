-- Backup SQLite do sistema Seek Pack (estrutura equivalente ao SQL PostgreSQL fornecido).
-- Restaurar com: sqlite3 seek_pack.sqlite < seek_pack_sqlite.sql

BEGIN TRANSACTION;
CREATE TABLE encomendas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    usuario_id INTEGER NOT NULL REFERENCES usuarios(id),
    codigo_rastreio VARCHAR(20) NOT NULL UNIQUE,
    origem VARCHAR(100) NOT NULL,
    destino VARCHAR(100) NOT NULL,
    previsao_entrega DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'POSTADO'
        CHECK (status IN ('POSTADO', 'EM_TRANSITO', 'AGUARDANDO_RETIRADA', 'ENTREGUE'))
);
INSERT INTO "encomendas" VALUES(1,1,'SP000000001BR','Florianópolis/SC','Porto Alegre/RS','2026-12-01','POSTADO');
INSERT INTO "encomendas" VALUES(2,2,'SP000000002BR','Curitiba/PR','Mondaí/SC','2026-12-02','EM_TRANSITO');
INSERT INTO "encomendas" VALUES(3,3,'SP000000003BR','Goiânia/GO','Brasília/DF','2026-12-03','ENTREGUE');
INSERT INTO "encomendas" VALUES(4,4,'SP000000004BR','São Paulo/SP','Rio de Janeiro/RJ','2026-12-04','POSTADO');
INSERT INTO "encomendas" VALUES(5,5,'SP000000005BR','Belo Horizonte/MG','Vitória/ES','2026-12-05','EM_TRANSITO');
INSERT INTO "encomendas" VALUES(6,6,'SP000000006BR','Salvador/BA','Recife/PE','2026-12-06','AGUARDANDO_RETIRADA');
INSERT INTO "encomendas" VALUES(7,7,'SP000000007BR','Fortaleza/CE','Natal/RN','2026-12-07','POSTADO');
INSERT INTO "encomendas" VALUES(8,8,'SP000000008BR','Manaus/AM','Belém/PA','2026-12-08','EM_TRANSITO');
INSERT INTO "encomendas" VALUES(9,9,'SP000000009BR','Campinas/SP','Curitiba/PR','2026-12-09','ENTREGUE');
INSERT INTO "encomendas" VALUES(10,10,'SP000000010BR','Joinville/SC','Chapecó/SC','2026-12-10','AGUARDANDO_RETIRADA');
CREATE TABLE eventos_rastreamento (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    encomenda_id INTEGER NOT NULL REFERENCES encomendas(id),
    status VARCHAR(30) NOT NULL
        CHECK (status IN ('POSTADO', 'EM_TRANSITO', 'AGUARDANDO_RETIRADA', 'ENTREGUE')),
    descricao VARCHAR(255) NOT NULL,
    localizacao VARCHAR(100) NOT NULL,
    data_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "eventos_rastreamento" VALUES(1,1,'POSTADO','Encomenda postada.','Florianópolis/SC','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(2,2,'EM_TRANSITO','Encomenda em transporte.','Curitiba/PR','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(3,3,'ENTREGUE','Encomenda entregue.','Brasília/DF','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(4,4,'POSTADO','Encomenda postada.','São Paulo/SP','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(5,5,'EM_TRANSITO','Encomenda em transporte.','Belo Horizonte/MG','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(6,6,'AGUARDANDO_RETIRADA','Disponível para retirada.','Recife/PE','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(7,7,'POSTADO','Encomenda postada.','Fortaleza/CE','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(8,8,'EM_TRANSITO','Encomenda em transporte.','Manaus/AM','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(9,9,'ENTREGUE','Encomenda entregue.','Curitiba/PR','2026-11-12 17:45:36');
INSERT INTO "eventos_rastreamento" VALUES(10,10,'AGUARDANDO_RETIRADA','Disponível para retirada.','Chapecó/SC','2026-11-12 17:45:36');
CREATE TABLE usuarios (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "usuarios" VALUES(1,'Ana Silva','ana@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(2,'Bruno Costa','bruno@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(3,'Carla Souza','carla@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(4,'Daniel Santos','daniel@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(5,'Eduarda Lima','eduarda@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(6,'Felipe Alves','felipe@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(7,'Gabriela Rocha','gabriela@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(8,'Henrique Dias','henrique@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(9,'Isabela Martins','isabela@example.com','2026-11-12 17:45:36');
INSERT INTO "usuarios" VALUES(10,'João Oliveira','joao@example.com','2026-11-12 17:45:36');
CREATE INDEX idx_encomendas_usuario ON encomendas(usuario_id);
CREATE INDEX idx_encomendas_status ON encomendas(status);
CREATE INDEX idx_eventos_encomenda_data
    ON eventos_rastreamento(encomenda_id, data_evento DESC, id DESC);
CREATE TRIGGER trg_atualizar_status
AFTER INSERT ON eventos_rastreamento
FOR EACH ROW
WHEN NEW.id = (
    SELECT id
    FROM eventos_rastreamento
    WHERE encomenda_id = NEW.encomenda_id
    ORDER BY data_evento DESC, id DESC
    LIMIT 1
)
BEGIN
    UPDATE encomendas
    SET status = NEW.status
    WHERE id = NEW.encomenda_id;
END;
CREATE VIEW vw_encomendas AS
SELECT
    e.id,
    e.codigo_rastreio,
    u.nome AS usuario,
    u.email,
    e.origem,
    e.destino,
    e.previsao_entrega,
    e.status
FROM encomendas e
JOIN usuarios u ON u.id = e.usuario_id;
DELETE FROM "sqlite_sequence";
INSERT INTO "sqlite_sequence" VALUES('usuarios',10);
INSERT INTO "sqlite_sequence" VALUES('encomendas',10);
INSERT INTO "sqlite_sequence" VALUES('eventos_rastreamento',12);
COMMIT;
