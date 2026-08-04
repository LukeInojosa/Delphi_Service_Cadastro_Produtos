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
- [Relationships](#relationships)
- [Database Diagram](#database-diagram)
- [Sql Create Tables](#sql-create-tables)
- [Triggers and Generators](#triggers-and-generators)

## Introduction

## Database type

- **Database system:** MySQL
## Table structure

### Produtos

| Name          | Type         | Settings        | References | Note |
| ------------- | ------------ | --------------- | ---------- | ---- |
| **codigo**    | CHAR(13)     | 🔑 PK, not null |            |      |
| **descricao** | VARCHAR(255) | not null        |            |      |
| **medida**    | VARCHAR(10)  | not null        |            |      | 


### Almoxarifados

| Name          | Type         | Settings                | References | Note |
| ------------- | ------------ | ----------------------- | ---------- | ---- |
| **codigo**    | CHAR(14) | 🔑 PK, not null         |            |      |
| **descricao** | VARCHAR(255) | not null                |            |      |
| **ativo**     | BOOLEAN      | not null, default: true |            |      | 


### Notas

| Name                    | Type         | Settings                 | References 			 | Note |
| ----------------------- | ------------ | ------------------------ | ---------------------  | ---- |
| **id**                  | VARCHAR(255) | 🔑 PK, not null          |            			 |      |
| **tipo_operacao**       | INTEGER      | not null, (entrada, saida, balanço)                 |            			 |      |
| **data_registro**       | DATETIME     | not null                 |           			 | data + hora      |
| **observacao**          | VARCHAR(255) | null                     |           			 |      |
| **concluida**           | BOOLEAN      | not null, default: false |           			 |      |
| **usuario_responsavel** | BIGINT       | not null                 | **Usuario.id**         |      |
| **codigo_almoxarifado** | CHAR(14) | not null                 | **Almoxarifado.codigo**|      | 


### Estorno_Info

| Name                  | Type         | Settings         | References       | Note |
| --------------------- | ------------ | ---------------- | ---------------- | ---- |
| **id_nota_estorno**   | VARCHAR(255) | 🔑 PK, not null  | **Notas.id** |      |
| **id_nota_estornada** | VARCHAR(255) | not null | **Notas.id** |      |
| **motivo**            | VARCHAR(255) | not null         |                  |      | 


### Movimentacao

| Name                    | Type         | Settings                       | References | Note |
| ----------------------- | ------------ | ------------------------------ | ---------- | ---- |
| **id**                  | BIGINT       | 🔑 PK, not null, autoincrement |            |      |
| **quantidade**          | INTEGER      | not null, >= 0                       |            |      |
| **codigo_produto**      | CHAR(13)     | not null, unique(codigo_produto, id_nota)                       | **Produto.codigo**           |      |
| **codigo_almoxarifado** | CHAR(14) | not null                       |   **Almoxarifado.codigo**        |      |
| **id_nota**             | VARCHAR(255) | not null, unique(codigo_produto, id_nota)                       | **Notas.id**           |      | 


### Usuario

| Name                    | Type         | Settings                   | References | Note |
| ----------------------- | ------------ | -------------------------- | ---------- | ---- |
| **id**                  | BIGINT       | 🔑 PK, null, autoincrement |            |      |
| **nome**                | VARCHAR(255) | not null, unique           |            |      |
| **senha**               | VARCHAR(255) | not null                   |            |      |
| **codigo_almoxarifado** | CHAR(14) | not null                   | **Almoxarifado.codigo**            |      | 


### Estoque

| Name                    | Type         | Settings                | References | Note |
| ----------------------- | ------------ | ----------------------- | ---------- | ---- |
| **codigo_produto**      | CHAR(13)     | 🔑 PK, not null         | **Produto.codigo**            |      |
| **codigo_almoxarifado** | CHAR(14) | 🔑 PK, not null         | **Almoxarifado.codigo**           |      |
| **quantidade**          | INTEGER      | not null, >= 0, default: 0 |            |      |
| **ativo**               | BOOLEAN      | not null, default: true |            |      | 


### Contagem

| Name                    | Type         | Settings                | References | Note |
| ----------------------- | ------------ | ----------------------- | ---------- | ---- |
| **id_nota**             | VARCHAR(255) | 🔑 PK, not null         | **Notas.id**           |      |
| **codigo_almoxarifado** | CHAR(14) | 🔑 PK, not null         | **Almoxarifado.codigo**           |      |
| **codigo_produto**      | CHAR(13)     | 🔑 PK, not null         | **Produto.codigo**           |      |
| **quantidade**          | INTEGER      | not null, >= 0, default: 0 			|            |      | 



## Relationships

- **Almoxarifados (1) → (N) Usuario**
  - `Usuario.codigo_almoxarifado` → `Almoxarifados.codigo`
  - Cada usuário pertence a um almoxarifado, e um almoxarifado pode possuir vários usuários.

- **Usuario (1) → (N) Notas**
  - `Notas.usuario_responsavel` → `Usuario.id`
  - Um usuário pode ser responsável por diversas notas.

- **Almoxarifados (1) → (N) Notas**
  - `Notas.codigo_almoxarifado` → `Almoxarifados.codigo`
  - Cada nota está associada a um único almoxarifado.

- **Notas (1) → (N) Movimentacao**
  - `Movimentacao.id_nota` → `Notas.id`
  - Uma nota pode conter várias movimentações.

- **Produtos (1) → (N) Movimentacao**
  - `Movimentacao.codigo_produto` → `Produtos.codigo`
  - Um produto pode aparecer em diversas movimentações.

- **Almoxarifados (1) → (N) Movimentacao**
  - `Movimentacao.codigo_almoxarifado` → `Almoxarifados.codigo`
  - Cada movimentação ocorre em um único almoxarifado.

- **Produtos (1) ↔ (N) Estoque**
  - `Estoque.codigo_produto` → `Produtos.codigo`
  - Um produto pode possuir um registro de estoque em cada almoxarifado.

- **Almoxarifados (1) ↔ (N) Estoque**
  - `Estoque.codigo_almoxarifado` → `Almoxarifados.codigo`
  - Um almoxarifado mantém registros de estoque para diversos produtos.

- **Produtos (1) → (N) Contagem**
  - `Contagem.codigo_produto` → `Produtos.codigo`
  - Um produto pode aparecer em diversas contagens de estoque.

- **Almoxarifados (1) → (N) Contagem**
  - `Contagem.codigo_almoxarifado` → `Almoxarifados.codigo`
  - Uma contagem é realizada em um único almoxarifado.

- **Notas (1) → (N) Contagem**
  - `Contagem.id_nota` → `Notas.id`
  - Uma nota de contagem pode conter vários produtos contados.

- **Notas (1) ↔ (0..1) Estorno_Info (como nota de estorno)**
  - `Estorno_Info.id_nota_estorno` → `Notas.id`
  - Uma nota de estorno possui exatamente um registro de informações de estorno.

- **Notas (1) ↔ (0..1) Estorno_Info (como nota estornada)**
  - `Estorno_Info.id_nota_estornada` → `Notas.id`
  - Uma nota pode ser estornada por, no máximo, uma nota de estorno.
  
## Database Diagram

```mermaid
erDiagram
	Produtos {
		CHAR(13) codigo
		VARCHAR(255) descricao
		VARCHAR(10) medida
	}

	Almoxarifados {
		VARCHAR(255) codigo
		VARCHAR(255) descricao
		BOOLEAN ativo
	}

	Notas {
		VARCHAR(255) id
		INTEGER tipo_operacao
		DATETIME data_registro
		VARCHAR(255) observacao
		BOOLEAN concluida
		BIGINT usuario_responsavel
		VARCHAR(255) codigo_almoxarifado
	}

	Estorno_Info {
		VARCHAR(255) id_nota_estorno
		VARCHAR(255) id_nota_estornada
		VARCHAR(255) motivo
	}

	Movimentacao {
		BIGINT id
		INTEGER quantidade
		CHAR(13) codigo_produto
		VARCHAR(255) codigo_almoxarifado
		VARCHAR(255) id_nota
	}

	Usuario {
		BIGINT id
		VARCHAR(255) nome
		VARCHAR(255) senha
		VARCHAR(255) codigo_almoxarifado
	}

	Estoque {
		CHAR(13) codigo_produto
		VARCHAR(255) codigo_almoxarifado
		INTEGER quantidade
		BOOLEAN ativo
	}

	Contagem {
		VARCHAR(255) id_nota
		VARCHAR(255) codigo_almoxarifado
		CHAR(13) codigo_produto
		INTEGER quantidade
	}
```

## Sql Create Tables


```sql
CREATE TABLE PRODUTOS(
	CODIGO CHAR(13) PRIMARY KEY,
	DESCRICAO VARCHAR(255) NOT NULL,
	MEDIDA VARCHAR(10) NOT NULL);

CREATE TABLE ALMOXARIFADO(
    CODIGO CHAR(14) PRIMARY KEY,
    DESCRICAO VARCHAR(255) NOT NULL,
    ATIVO CHAR(1) DEFAULT 1 NOT NULL
);

CREATE TABLE USUARIO(
    ID BIGINT PRIMARY KEY,
    NOME VARCHAR(255) NOT NULL UNIQUE,
    SENHA VARCHAR(255) NOT NULL,
    CODIGO_ALMOXARIFADO VARCHAR(14) NOT NULL
);

CREATE TABLE NOTAS(
    ID VARCHAR(255) PRIMARY KEY,
    TIPO_OPERACAO INTEGER NOT NULL,
    DATA_REGISTRO TIMESTAMP NOT NULL,
    OBSERVACAO VARCHAR(255),
    CONCLUIDA CHAR(1) DEFAULT 0 NOT NULL,
    USUARIO_RESPONSAVEL BIGINT NOT NULL,
    CODIGO_ALMOXARIFADO VARCHAR(255) NOT NULL
);

CREATE TABLE ESTORNO_INFO(
    ID_NOTA_ESTORNO VARCHAR(255) PRIMARY KEY,
    ID_NOTA_ESTORNADA VARCHAR(255) NOT NULL,
    MOTIVO VARCHAR(255) NOT NULL
);

CREATE TABLE MOVIMENTACAO(
    ID BIGINT PRIMARY KEY,
    QUANTIDADE INTEGER NOT NULL CHECK (QUANTIDADE >= 0),
    CODIGO_PRODUTO CHAR(13) NOT NULL,
    CODIGO_ALMOXARIFADO CHAR(14) NOT NULL,
    ID_NOTA VARCHAR(255) NOT NULL
);

CREATE TABLE ESTOQUE(
    CODIGO_PRODUTO CHAR(13),
    CODIGO_ALMOXARIFADO CHAR(14),
    QUANTIDADE INTEGER DEFAULT 0 NOT NULL CHECK (QUANTIDADE >= 0),
    ATIVO CHAR(1) DEFAULT 1 NOT NULL,
    PRIMARY KEY (CODIGO_PRODUTO, CODIGO_ALMOXARIFADO)
);

CREATE TABLE CONTAGEM(
    ID_NOTA VARCHAR(255),
    CODIGO_ALMOXARIFADO CHAR(14),
    CODIGO_PRODUTO CHAR(13),
    QUANTIDADE INTEGER DEFAULT 0 NOT NULL CHECK (QUANTIDADE >= 0),
	PRIMARY KEY (ID_NOTA,CODIGO_ALMOXARIFADO, CODIGOO_PRODUTO)
);

ALTER TABLE NOTAS
    ADD CONSTRAINT FK_NOTAS_USUARIO
    FOREIGN KEY (USUARIO_RESPONSAVEL)
    REFERENCES USUARIO(ID);

ALTER TABLE NOTAS
    ADD CONSTRAINT FK_NOTAS_ALMOXARIFADO
    FOREIGN KEY (CODIGO_ALMOXARIFADO)
    REFERENCES ALMOXARIFADO(CODIGO);

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
    FOREIGN KEY (CODIGO_PRODUTO)
    REFERENCES PRODUTOS(CODIGO);

ALTER TABLE MOVIMENTACAO
    ADD CONSTRAINT FK_MOVIMENTACAO_ALMOXARIFADO
    FOREIGN KEY (CODIGO_ALMOXARIFADO)
    REFERENCES ALMOXARIFADO(CODIGO);

ALTER TABLE MOVIMENTACAO
    ADD CONSTRAINT FK_MOVIMENTACAO_NOTA
    FOREIGN KEY (ID_NOTA)
    REFERENCES NOTAS(ID);

ALTER TABLE ESTOQUE
    ADD CONSTRAINT FK_ESTOQUE_PRODUTO
    FOREIGN KEY (CODIGO_PRODUTO)
    REFERENCES PRODUTOS(CODIGO);

ALTER TABLE ESTOQUE
    ADD CONSTRAINT FK_ESTOQUE_ALMOXARIFADO
    FOREIGN KEY (CODIGO_ALMOXARIFADO)
    REFERENCES ALMOXARIFADO(CODIGO);

ALTER TABLE CONTAGEM
    ADD CONSTRAINT FK_CONTAGEM_NOTAS
    FOREIGN KEY (ID_NOTA)
    REFERENCES NOTAS(ID);

ALTER TABLE CONTAGEM
    ADD CONSTRAINT FK_CONTAGEM_ALMOXARIFADO
    FOREIGN KEY (CODIGO_ALMOXARIFADO)
    REFERENCES ALMOXARIFADO(CODIGO);

ALTER TABLE CONTAGEM
    ADD CONSTRAINT FK_CONTAGEM_PRODUTO
    FOREIGN KEY (CODIGO_PRODUTO)
    REFERENCES PRODUTOS(CODIGO);

ALTER TABLE MOVIMENTACAO
	ADD CONSTRAINT U_CODIGO_PRODUTO_ID_NOTA UNIQUE (CODIGO_PRODUTO, ID_NOTA);
```

## Triggers and Generators
<details>
<summary></summary>
-
```sql
```
</details>

<details>
<summary>PEGAR TODO ESTOQUE DE UM ALMOXARIFADO ESPECIFICO POR CODIGO</summary>
	```sql
	SET TERM ^ ;
	
	create or alter procedure ESTOQUE_DE (
	    ICODIGO_ALMOXARIFADO char(14))
	returns (
	    CODIGO_PRODUTO char(13),
	    CODIGO_ALMOXARIFADO char(14),
	    ATIVO char(1),
	    QUANTIDADE integer)
	as
	begin
	    FOR SELECT
	            CODIGO_PRODUTO,
	            CODIGO_ALMOXARIFADO,
	            QUANTIDADE,
	            ATIVO
	        FROM ESTOQUE
	        WHERE CODIGO_ALMOXARIFADO =  :Icodigo_almoxarifado
	    INTO
	        :codigo_produto,
	        :codigo_almoxarifado,
	        :quantidade,
	        :ativo
	    do suspend;
	end^
	
	SET TERM ; ^
	
	/* Following GRANT statements are generated automatically */
	
	GRANT SELECT ON ESTOQUE TO PROCEDURE ESTOQUE_DE;
	
	/* Existing privileges on this procedure */
	
	GRANT EXECUTE ON PROCEDURE ESTOQUE_DE TO SYSDBA;
	```
</details>

<details>
<summary>PEGAR TODA MOVIMENTAÇÃO DE UMA NOTA ESPECÍFICA</summary>
	```sql
	SET TERM ^ ;
	
	create or alter procedure MOVIMENTACAO_POR_NOTA (
	    IID_NOTA varchar(255))
	returns (
	    ID bigint,
	    QUANTIDADE integer,
	    CODIGO_PRODUTO char(13),
	    CODIGO_ALMOXARIFADO char(14),
	    ID_NOTA varchar(255))
	as
	begin
	    FOR SELECT ID, QUANTIDADE, CODIGO_PRODUTO,CODIGO_ALMOXARIFADO, ID_NOTA
	        FROM MOVIMENTACAO
	        WHERE ID_NOTA = :iid_nota
	    INTO
	        :id,
	        :quantidade,
	        :codigo_produto,
	        :codigo_almoxarifado,
	        :id_nota
	
	    do suspend;
	end^
	
	SET TERM ; ^
	
	/* Following GRANT statements are generated automatically */
	
	GRANT SELECT ON MOVIMENTACAO TO PROCEDURE MOVIMENTACAO_POR_NOTA;
	
	/* Existing privileges on this procedure */
	
	GRANT EXECUTE ON PROCEDURE MOVIMENTACAO_POR_NOTA TO SYSDBA;
	```
</details>






<details>
<summary>Quando alterar o campo NOTAS.concluido para true, adicionar todas as movimentações desta nota em ESTOQUE</summary>
	```sql
	/*
		INSERE DADOS DE UMA NOTA ESPECÍFICA EM UM ESTOQUE ESPECÍFICO 
	 */
	SET TERM ^ ;
	CREATE TRIGGER TR_MOVIMENTA_ESTOQUE for NOTAS
	ACTIVE BEFORE UPDATE OR INSERT
	AS
	declare variable ICodigoProduto         CHAR(13);
	declare variable ICodigoAlmoxarifado    CHAR(14);
	declare variable Iquantidade            INTEGER;
	begin
	   IF (new.CONCLUIDA = 1 AND COALESCE(old.CONCLUIDA,0) = 0) THEN
	    BEGIN
	        FOR SELECT M_NOTA.CODIGO_PRODUTO,
	                  new.CODIGO_ALMOXARIFADO AS CODIGO_ALMOXARIFADO, 
	                  M_NOTA.QUANTIDADE + COALESCE(EST_PROD_NOTA.QUANTIDADE, 0) AS QUANTIDADE
	            FROM (SELECT MOVIMENTACAO.CODIGO_PRODUTO, MOVIMENTACAO.QUANTIDADE
	                  FROM MOVIMENTACAO
	                  WHERE MOVIMENTACAO.ID_NOTA = new.ID) M_NOTA
	            LEFT JOIN (SELECT ESTOQUE.CODIGO_PRODUTO, ESTOQUE.QUANTIDADE 
	                        FROM ESTOQUE 
	                        WHERE ESTOQUE.CODIGO_ALMOXARIFADO = new.CODIGO_ALMOXARIFADO) EST_PROD_NOTA
	            ON EST_PROD_NOTA.CODIGO_PRODUTO = M_NOTA.CODIGO_PRODUTO
	        INTO :ICodigoProduto, :ICodigoAlmoxarifado, :Iquantidade
	        DO
	        BEGIN
	            UPDATE OR INSERT INTO ESTOQUE(CODIGO_PRODUTO, CODIGO_ALMOXARIFADO, QUANTIDADE)
	            VALUES (:ICodigoProduto, :ICodigoAlmoxarifado, :Iquantidade)
	            MATCHING(CODIGO_PRODUTO, CODIGO_ALMOXARIFADO);
	        END
	    END
</details>

END^
SET TERM ; ^

```
