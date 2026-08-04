# Delphi_Service_Cadastro_Produtos

# Estoque de Produtos documentation
## Summary

- [Introduction](#introduction)
- [Database Type](#database-type)
- [Table Structure](#table-structure)
	- [Produtos](#produtos)
	- [Almoxarifados](#almoxarifados)
	- [Notas](#notas)
	- [Estorno_Info](#estorno_info)
	- [Movimentacao](#movimentacao)
	- [Usuario](#usuario)
	- [Estoque](#estoque)
	- [Contagem](#contagem)
- [Sql Create Tables](#sql-create-tables)
- [Generators](#generators)
- [Procedures](#procedures)
- [Triggers](#triggers)

## Introduction

## Database type

- **Database system:** MySQL
## Table structure

### Produtos

| Name          | Type         | Settings        | References | Note |
| ------------- | ------------ | --------------- | ---------- | ---- |
| **id**    | BIGINT    | 🔑 PK, not null, , autoincrement |            |      |
| **codigo**    | CHAR(13)     | unique |            |      |
| **descricao** | VARCHAR(255) | not null        |            |      |
| **medida**    | VARCHAR(10)  | not null        |            |      | 


### Almoxarifados

| Name          | Type         | Settings                | References | Note |
| ------------- | ------------ | ----------------------- | ---------- | ---- |
| **id**    | BIGINT | 🔑 PK, not null, autoincrement         |            |      |
| **codigo**    | CHAR(14) | unique       |            |      |
| **descricao** | VARCHAR(255) | not null                |            |      |
| **ativo**     | BOOLEAN      | not null, default: true |            |      | 


### Notas

| Name                    | Type         | Settings                 | References 			 | Note |
| ----------------------- | ------------ | ------------------------ | ---------------------  | ---- |
| **id**                  | BIGINT | 🔑 PK, not null, autoincrement          |            			 |      |
| **tipo_operacao**       | INTEGER      | not null, (entrada, saida, balanço)                 |            			 |      |
| **data_registro**       | DATETIME     | not null                 |           			 | data + hora      |
| **observacao**          | VARCHAR(255) | null                     |           			 |      |
| **concluida**           | BOOLEAN      | not null, default: false |           			 |      |
| **usuario_responsavel** | BIGINT       | not null                 | **Usuario.id**         |      |
| **id_almoxarifado** | BIGINT | not null                 | **Almoxarifado.id**|      | 


### Estorno_Info

| Name                  | Type         | Settings         | References       | Note |
| --------------------- | ------------ | ---------------- | ---------------- | ---- |
| **id_nota_estorno**   | BIGINT | 🔑 PK, not null  | **Notas.id** |      |
| **id_nota_estornada** | BIGINT | not null | **Notas.id** |      |
| **motivo**            | VARCHAR(255) | not null         |                  |      | 


### Movimentacao

| Name                    | Type         | Settings                       | References | Note |
| ----------------------- | ------------ | ------------------------------ | ---------- | ---- |
| **id**                  | BIGINT       | 🔑 PK, not null, autoincrement |            |      |
| **quantidade**          | INTEGER      | not null, >= 0                       |            |      |
| **id_produto**      | BIGINT     | not null, unique(id_produto, id_nota)                       | **Produto.id**           |      |
| **id_nota**             | VARCHAR(255) | not null, unique(id_produto, id_nota)                       | **Notas.id**           |      | 


### Usuario

| Name                    | Type         | Settings                   | References | Note |
| ----------------------- | ------------ | -------------------------- | ---------- | ---- |
| **id**                  | BIGINT       | 🔑 PK, null, autoincrement |            |      |
| **nome**                | VARCHAR(255) | not null, unique           |            |      |
| **senha**               | VARCHAR(255) | not null                   |            |      |
| **id_almoxarifado** | BIGINT | not null                   | **Almoxarifado.id**            |      | 


### Estoque

| Name                    | Type         | Settings                | References | Note |
| ----------------------- | ------------ | ----------------------- | ---------- | ---- |
| **id_produto**      | BIGINT      | 🔑 PK, not null         | **Produto.id**            |      |
| **id_almoxarifado** | BIGINT | 🔑 PK, not null         | **Almoxarifado.id**           |      |
| **quantidade**          | INTEGER      | not null, >= 0, default: 0 |            |      |
| **ativo**               | BOOLEAN      | not null, default: true |            |      | 


### Contagem

| Name                    | Type         | Settings                | References | Note |
| ----------------------- | ------------ | ----------------------- | ---------- | ---- |
| **id_nota**             | VARCHAR(255) | 🔑 PK, not null         | **Notas.id**           |      |
| **id_produto**      | BIGINT     | 🔑 PK, not null         | **Produto.id**           |      |
| **quantidade**          | INTEGER      | not null, >= 0, default: 0 			|            |      | 


## Sql Create Tables


```sql
CREATE TABLE PRODUTOS(
	ID BIGINT PRIMARY KEY,
	CODIGO CHAR(13) UNIQUE,
	DESCRICAO VARCHAR(255) NOT NULL,
	MEDIDA VARCHAR(10) NOT NULL);

CREATE TABLE ALMOXARIFADO(
	ID BIGINT PRIMARY KEY,
    CODIGO CHAR(14) UNIQUE,
    DESCRICAO VARCHAR(255) NOT NULL,
    ATIVO CHAR(1) DEFAULT 1 NOT NULL
);

CREATE TABLE USUARIO(
    ID BIGINT PRIMARY KEY,
    NOME VARCHAR(255) NOT NULL UNIQUE,
    SENHA VARCHAR(255) NOT NULL,
    ID_ALMOXARIFADO BIGINT NOT NULL
);

CREATE TABLE NOTAS(
    ID BIGINT PRIMARY KEY,
    TIPO_OPERACAO INTEGER NOT NULL,
    DATA_REGISTRO TIMESTAMP NOT NULL,
    OBSERVACAO VARCHAR(255),
    CONCLUIDA CHAR(1) DEFAULT 0 NOT NULL,
    USUARIO_RESPONSAVEL BIGINT NOT NULL,
    ID_ALMOXARIFADO BIGINT NOT NULL
);

CREATE TABLE ESTORNO_INFO(
    ID_NOTA_ESTORNO BIGINT PRIMARY KEY,
    ID_NOTA_ESTORNADA BIGINT NOT NULL,
    MOTIVO VARCHAR(255) NOT NULL
);

CREATE TABLE MOVIMENTACAO(
    ID BIGINT PRIMARY KEY,
    QUANTIDADE INTEGER NOT NULL CHECK (QUANTIDADE >= 0),
    ID_PRODUTO BIGINT NOT NULL,
    ID_NOTA BIGINT NOT NULL
);

CREATE TABLE ESTOQUE(
    ID_PRODUTO BIGINT,
    ID_ALMOXARIFADO BIGINT,
    QUANTIDADE INTEGER DEFAULT 0 NOT NULL CHECK (QUANTIDADE >= 0),
    ATIVO CHAR(1) DEFAULT 1 NOT NULL,
    PRIMARY KEY (ID_PRODUTO, ID_ALMOXARIFADO)
);

CREATE TABLE CONTAGEM(
    ID_NOTA BIGINT,
    ID_PRODUTO BIGINT,
    QUANTIDADE INTEGER DEFAULT 0 NOT NULL CHECK (QUANTIDADE >= 0),
	PRIMARY KEY (ID_NOTA, ID_PRODUTO)
);

ALTER TABLE USUARIO
    ADD CONSTRAINT FK_USUARIO_ALMOXARIFADO
    FOREIGN KEY (ID_ALMOXARIFADO)
    REFERENCES ALMOXARIFADO(ID);

ALTER TABLE NOTAS
    ADD CONSTRAINT FK_NOTAS_USUARIO
    FOREIGN KEY (USUARIO_RESPONSAVEL)
    REFERENCES USUARIO(ID);

ALTER TABLE NOTAS
    ADD CONSTRAINT FK_NOTAS_ALMOXARIFADO
    FOREIGN KEY (ID_ALMOXARIFADO)
    REFERENCES ALMOXARIFADO(ID);

ALTER TABLE ESTORNO_INFO
    ADD CONSTRAINT FK_ESTORNO_NOTAS
    FOREIGN KEY (ID_NOTA_ESTORNO)
    REFERENCES NOTAS(ID);

ALTER TABLE ESTORNO_INFO
    ADD CONSTRAINT FK_ESTORNO_NOTAS_ESTORNADA
    FOREIGN KEY (ID_NOTA_ESTORNADA)
    REFERENCES NOTAS(ID);

ALTER TABLE MOVIMENTACAO
    ADD CONSTRAINT FK_MOVIMENTACAO_PRODUTO
    FOREIGN KEY (ID_PRODUTO)
    REFERENCES PRODUTOS(ID);

ALTER TABLE MOVIMENTACAO
    ADD CONSTRAINT FK_MOVIMENTACAO_NOTA
    FOREIGN KEY (ID_NOTA)
    REFERENCES NOTAS(ID);

ALTER TABLE ESTOQUE
    ADD CONSTRAINT FK_ESTOQUE_PRODUTO
    FOREIGN KEY (ID_PRODUTO)
    REFERENCES PRODUTOS(ID);

ALTER TABLE ESTOQUE
    ADD CONSTRAINT FK_ESTOQUE_ALMOXARIFADO
    FOREIGN KEY (ID_ALMOXARIFADO)
    REFERENCES ALMOXARIFADO(ID);

ALTER TABLE CONTAGEM
    ADD CONSTRAINT FK_CONTAGEM_NOTAS
    FOREIGN KEY (ID_NOTA)
    REFERENCES NOTAS(ID);

ALTER TABLE CONTAGEM
    ADD CONSTRAINT FK_CONTAGEM_PRODUTO
    FOREIGN KEY (ID_PRODUTO)
    REFERENCES PRODUTOS(ID);

ALTER TABLE MOVIMENTACAO
	ADD CONSTRAINT U_ID_PRODUTO_ID_NOTA UNIQUE (ID_PRODUTO, ID_NOTA);
```
## Generators
```sql
CREATE SEQUENCE GEN_ID_PRODUTOS;
ALTER SEQUENCE  GEN_ID_PRODUTOS RESTART WITH 0;

SET TERM ^ ;
CREATE OR ALTER TRIGGER TR_GEN_ID_PRODUTOS FOR PRODUTOS
ACTIVE BEFORE INSERT
AS
begin
	new.id = GEN_ID(GEN_ID_PRODUTOS,1);
END^
SET TERM ; ^

CREATE SEQUENCE GEN_ID_USUARIO;
ALTER SEQUENCE GEN_ID_USUARIO RESTART WITH 0;

SET TERM ^ ;
CREATE OR ALTER TRIGGER TR_GEN_ID_USUARIO FOR PRODUTOS
ACTIVE BEFORE INSERT
AS
begin
	new.id = GEN_ID(GEN_ID_USUARIO,1);
END^
SET TERM ; ^

CREATE SEQUENCE GEN_ID_ALMOXARIFADO ;
ALTER SEQUENCE GEN_ID_ALMOXARIFADO RESTART WITH 0;

SET TERM ^ ;
CREATE OR ALTER TRIGGER TR_GEN_ID_ALMOXARIFADO FOR PRODUTOS
ACTIVE BEFORE INSERT
AS
begin
	new.id = GEN_ID(GEN_ID_ALMOXARIFADO,1);
END^
SET TERM ; ^

CREATE SEQUENCE GEN_ID_NOTAS ;
ALTER SEQUENCE GEN_ID_NOTAS RESTART WITH 0;

SET TERM ^ ;
CREATE OR ALTER TRIGGER TR_GEN_ID_NOTAS FOR PRODUTOS
ACTIVE BEFORE INSERT
AS
begin
	new.id = GEN_ID(GEN_ID_NOTAS,1);
END^
SET TERM ; ^

CREATE SEQUENCE GEN_ID_MOVIMENTACAO ;
ALTER SEQUENCE GEN_ID_MOVIMENTACAO RESTART WITH 0;

SET TERM ^ ;
CREATE OR ALTER TRIGGER TR_GEN_ID_MOVIMENTACAO FOR PRODUTOS
ACTIVE BEFORE INSERT
AS
begin
	new.id = GEN_ID(GEN_ID_MOVIMENTACAO,1);
END^
SET TERM ; ^
*/
```
## Procedures
-
```sql
```
- PEGAR TODO ESTOQUE DE UM ALMOXARIFADO ESPECIFICO POR CODIGO
```sql
SET TERM ^ ;

create or alter procedure ESTOQUE_DE (
  IID_ALMOXARIFADO BIGINT)
returns (
  ID_PRODUTO BIGINT,
  ID_ALMOXARIFADO BIGINT,
  ATIVO char(1),
  QUANTIDADE integer)
as
begin
  FOR SELECT
      ID_PRODUTO,
      ID_ALMOXARIFADO,
      QUANTIDADE,
      ATIVO
    FROM ESTOQUE
    WHERE CODIGO_ALMOXARIFADO =  :Iid_almoxarifado
  INTO
    :id_produto,
    :id_almoxarifado,
    :quantidade,
    :ativo
  do suspend;
end^

SET TERM ; ^
GRANT SELECT ON ESTOQUE TO PROCEDURE ESTOQUE_DE;
GRANT EXECUTE ON PROCEDURE ESTOQUE_DE TO SYSDBA;
```


- PEGAR TODA MOVIMENTAÇÃO DE UMA NOTA ESPECÍFICA
```sql
SET TERM ^ ;

create or alter procedure MOVIMENTACAO_POR_NOTA (
  IID_NOTA varchar(255))
returns (
  ID bigint,
  QUANTIDADE integer,
  ID_PRODUTO BIGINT,
  ID_NOTA varchar(255))
as
begin
  FOR SELECT ID, QUANTIDADE, ID_PRODUTO, ID_NOTA
    FROM MOVIMENTACAO
    WHERE ID_NOTA = :iid_nota
  INTO
    :id,
    :quantidade,
    :id_produto,
    :id_nota

  do suspend;
end^

SET TERM ; ^
GRANT SELECT ON MOVIMENTACAO TO PROCEDURE MOVIMENTACAO_POR_NOTA;
GRANT EXECUTE ON PROCEDURE MOVIMENTACAO_POR_NOTA TO SYSDBA;
```

## Triggers
	
- Quando alterar o campo NOTAS.concluido para true, adicionar todas as movimentações desta nota em ESTOQUE
```sql
/*
	INSERE DADOS DE UMA NOTA ESPECÍFICA EM UM ESTOQUE ESPECÍFICO 
 */
SET TERM ^ ;
CREATE TRIGGER TR_MOVIMENTA_ESTOQUE for NOTAS
ACTIVE BEFORE UPDATE OR INSERT
AS
declare variable Vid_produto         CHAR(13);
declare variable Vid_almoxarifado    CHAR(14);
declare variable Vquantidade            INTEGER;
begin
   IF (new.CONCLUIDA = 1 AND COALESCE(old.CONCLUIDA,0) = 0) THEN
	BEGIN
		FOR SELECT M_NOTA.ID_PRODUTO,
				  new.ID_ALMOXARIFADO AS ID_ALMOXARIFADO, 
				  M_NOTA.QUANTIDADE + COALESCE(EST_PROD_NOTA.QUANTIDADE, 0) AS QUANTIDADE
			FROM (SELECT MOVIMENTACAO.ID_PRODUTO, MOVIMENTACAO.QUANTIDADE
				  FROM MOVIMENTACAO
				  WHERE MOVIMENTACAO.ID_NOTA = new.ID) M_NOTA
			LEFT JOIN (SELECT ESTOQUE.ID_PRODUTO, ESTOQUE.QUANTIDADE 
						FROM ESTOQUE 
						WHERE ESTOQUE.ID_ALMOXARIFADO = new.ID_ALMOXARIFADO) EST_PROD_NOTA
			ON EST_PROD_NOTA.ID_PRODUTO = M_NOTA.ID_PRODUTO
		INTO :Vid_Produto, :Vid_almoxarifado, :Vquantidade
		DO
		BEGIN
			UPDATE OR INSERT INTO ESTOQUE(ID_PRODUTO, ID_ALMOXARIFADO, QUANTIDADE)
			VALUES (:Vid_produto, :Vid_almoxarifado, :Vquantidade)
			MATCHING(ID_PRODUTO, ID_ALMOXARIFADO);
		END
	END
END^
SET TERM ; ^
```
- Quando alterar o campo NOTAS.concluido para true, adicionar todas as movimentações desta nota em ESTOQUE utilizando procedures
```sql
SET SQL DIALECT 3;



SET TERM ^ ;



CREATE OR ALTER TRIGGER TR_MOVIMENTA_ESTOQUE FOR NOTAS
ACTIVE BEFORE INSERT OR UPDATE POSITION 0
AS
declare variable Vid_produto         BIGINT;
declare variable Vid_almoxarifado    BIGINT;
declare variable Vquantidade            INTEGER;
begin
   IF (new.CONCLUIDA = 1 AND COALESCE(old.CONCLUIDA,0) = 0) THEN
    BEGIN
        FOR SELECT M_NOTA.ID_PRODUTO,
                  new.ID_ALMOXARIFADO AS ID_ALMOXARIFADO, 
                  M_NOTA.QUANTIDADE + COALESCE(EST_PROD_NOTA.QUANTIDADE, 0) AS QUANTIDADE
            FROM MOVIMENTACAO_POR_NOTA(new.ID) M_NOTA
            LEFT JOIN ESTOQUE_DE(new.ID_ALMOXARIFADO) EST_PROD_NOTA
            ON EST_PROD_NOTA.ID_PRODUTO = M_NOTA.ID_PRODUTO
        INTO :Vid_produto, :Vid_almoxarifado, :Vquantidade
        DO
        BEGIN
            UPDATE OR INSERT INTO ESTOQUE(ID_PRODUTO, ID_ALMOXARIFADO, QUANTIDADE)
            VALUES (:Vid_produto, :Vid_almoxarifado, :Vquantidade)
            MATCHING(ID_PRODUTO, ID_ALMOXARIFADO);
        END
    END
END
^

SET TERM ; ^
```
