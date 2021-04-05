-- Lista 10

-- 4.1
CREATE VIEW empregado_resumo (enome,sexo,salario)
AS SELECT enome,sexo,salario FROM empregado

-- 4.2
SELECT enome FROM empregado_resumo INNER JOIN (
	SELECT max(salario) as "salario" FROM empregado_resumo
) AS “maior_salario” ON empregado_resumo.salario = “maior_salario”.salario;

-- 4.3: Atualização realizada. UPDATE empregado SET salario = salario * 1.10;
UPDATE empregado_resumo SET salario = salario * 1.10;

select * from empregado;

-- 4.4
CREATE VIEW departamento_gerente(departamento,gerente)
AS
	SELECT departamento.dnome,empregado.enome FROM departamento 
	INNER JOIN empregado ON empregado.cpf = departamento.gerente

-- 4.5: Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_gerente SET gerente = 'Fulano' WHERE departamento  = 'Marketing';

-- 4.6: Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_gerente SET departamento = 'Novo Departamento' WHERE gerente = 'Henrique Vieira';

-- 4.7
CREATE VIEW menor_10000(nome,sexo,salario) AS SELECT enome,sexo,salario FROM empregado WHERE salario < 10000;

-- 4.8 Atualização realizada. UPDATE empregado SET salario = salario + 3000;
UPDATE menor_10000 SET salario = salario + 3000;

-- 4.9 Atualização realizada. DELETE FROM empregado WHERE salario > 5000 AND salario < 8000;
DELETE FROM menor_10000 WHERE salario > 5000 AND salario < 8000;

-- 4.10: Atualização não permitida pois resultaria em uma linha sem chave primária preenchida.
INSERT INTO menor_10000 (nome,sexo,salario) VALUES ('Fulano','F',5000);

-- 4.11
CREATE VIEW departamento_resumo_2(departamento_codigo,departamento_nome,cpf_gerente,nome_gerente)
AS
	SELECT departamento.codigo,departamento.dnome,empregado.cpf,empregado.enome FROM departamento
	INNER JOIN empregado ON empregado.cpf = departamento.gerente;

-- 4.12: Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_resumo_2 SET departamento_codigo = 2 WHERE departamento_nome = 'Marketing';

-- 4.13: Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_resumo_2 SET cpf_gerente = '1234' WHERE nome_gerente = 'Berlofa';

-- 4.14: Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_resumo_2 SET nome_gerente = 'Berlofa Reloaded' WHERE cpf_gerente = '1234';

-- 4.15
CREATE VIEW departamento_resumo_3 (codigo,dpt_nome,dpt_qtd,max_salario,min_salario,avg_salario) AS
	SELECT departamento.codigo,departamento.dnome,"dpt_qtd".qtd,"max_dpt".salario,
	"min_dpt".salario,"avg_dpt".salario FROM departamento
	INNER JOIN (SELECT COUNT(*) as "qtd",cdep FROM empregado GROUP BY cdep) as "dpt_qtd" ON "dpt_qtd".cdep = departamento.codigo
	INNER JOIN (SELECT MAX(salario) as "salario",cdep FROM empregado GROUP BY cdep) as "max_dpt" ON "max_dpt".cdep = departamento.codigo
	INNER JOIN (SELECT MIN(salario) as "salario",cdep FROM empregado GROUP BY cdep) as "min_dpt" ON "min_dpt".cdep = departamento.codigo
	INNER JOIN (SELECT AVG(salario) as "salario",cdep FROM empregado GROUP BY cdep) as "avg_dpt" ON "avg_dpt".cdep = departamento.codigo

-- 4.16
-- Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_resumo_3 SET avg_salario = 4000 WHERE codigo = 2;
-- Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_resumo_3 SET dpt_qtd = 4 WHERE codigo = 2;
-- Atualização não permitida devido a View ser originada de mais de uma tabela.
DELETE FROM departamento_resumo_3 WHERE codigo = 2;
-- Atualização não permitida devido a View ser originada de mais de uma tabela.
INSERT INTO departamento_resumo_3 (codigo,dpt_nome,dpt_qtd,max_salario,min_salario,avg_salario) VALUES (5,'DPT 5',3,10000,4000,6000);
-- Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_resumo_3  SET dpt_nome = 'DPT RELOADED' WHERE codigo = 5;
