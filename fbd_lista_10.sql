-- Lista 10

-- 4.1 - Crie uma visão que recupere para cada empregado o seu nome, o seu sexo e o seu salário.
CREATE VIEW empregado_resumo (enome,sexo,salario)
AS SELECT enome,sexo,salario FROM empregado

-- 4.2 - Crie uma consulta usando a visão anterior que recupere o nome do funcionário com maior salário.
SELECT enome FROM empregado_resumo INNER JOIN (
	SELECT max(salario) as "salario" FROM empregado_resumo
) AS “maior_salario” ON empregado_resumo.salario = “maior_salario”.salario;

-- 4.3 - Usando a visão anterior, efetue uma atualização que conceda um aumento de salário de 10%.
-- R: Atualização realizada. UPDATE empregado SET salario = salario * 1.10;
UPDATE empregado_resumo SET salario = salario * 1.10;

select * from empregado;

-- 4.4 - Crie uma visão que recupere para cada departamento o seu nome e o nome do seu gerente.
CREATE VIEW departamento_gerente(departamento,gerente)
AS
	SELECT departamento.dnome,empregado.enome FROM departamento 
	INNER JOIN empregado ON empregado.cpf = departamento.gerente

-- 4.5 - Usando a visão anterior, altere o nome do gerente do departamento de “Marketing”.
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
-- R: UPDATE empregado SET nome = ‘Fulano’ WHERE empregado.cpf IN (SELECT cpf FROM empregado INNER JOIN departamento ON gerente = cpf WHERE departamento.dnome = ‘Marketing’)
UPDATE departamento_gerente SET gerente = 'Fulano' WHERE departamento  = 'Marketing';

-- 4.6 - Usando a visão anterior, altere o nome do departamento gerenciado pelo “Henrique Vieira”.
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
-- R: UPDATE departamento SET dnome = ‘Novo Departamento’ WHERE gerente IN (SELECT cpf FROM empregado WHERE enome = ‘Henrique Vieira’)
UPDATE departamento_gerente SET departamento = 'Novo Departamento' WHERE gerente = 'Henrique Vieira';

-- 4.7 - Crie uma visão que recupere para cada empregado com salário menor que 10.000: o seu nome, o seu sexo e o seu salário.
CREATE VIEW menor_10000(nome,sexo,salario) AS SELECT enome,sexo,salario FROM empregado WHERE salario < 10000;

-- 4.8 - Usando a visão anterior, efetue uma atualização que conceda um aumento de 3.000 a todos os empregados que aparecem na visão.
-- R: Atualização realizada. UPDATE empregado SET salario = salario + 3000;
UPDATE menor_10000 SET salario = salario + 3000;

-- 4.9 - Ainda usando esta visão exclua os empregados com salário entre 5.000 e 8.000.
-- R: Atualização realizada. DELETE FROM empregado WHERE salario > 5000 AND salario < 8000;
DELETE FROM menor_10000 WHERE salario > 5000 AND salario < 8000;

-- 4.10 - Agora inclua uma nova tupla usando a visão anterior.
-- R: Atualização não permitida pois resultaria em uma linha sem chave primária preenchida.
-- R: INSERT INTO empregado (cpf,enome,sexo,salario) VALUES (‘9991’,’Fulano,’M’,5000);
INSERT INTO menor_10000 (nome,sexo,salario) VALUES ('Fulano','F',5000);

-- 4.11 - Crie uma visão que recupere para cada departamento o seu código, o seu nome, além do CPF e do nome do seu gerente.
CREATE VIEW departamento_resumo_2(departamento_codigo,departamento_nome,cpf_gerente,nome_gerente)
AS
	SELECT departamento.codigo,departamento.dnome,empregado.cpf,empregado.enome FROM departamento
	INNER JOIN empregado ON empregado.cpf = departamento.gerente;

-- 4.12 - Usando a visão anterior altere o código do departamento de “Marketing”.
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_resumo_2 SET departamento_codigo = 2 WHERE departamento_nome = 'Marketing';

-- 4.13 - Agora altere o CPF do empregado Berlofa.
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
UPDATE departamento_resumo_2 SET cpf_gerente = '1234' WHERE nome_gerente = 'Berlofa';

-- 4.14 - Ainda usando esta visão altere o nome do empregado Berlofa.
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
-- R: UPDATE empregado SET enome = ‘Berlofa Reloaded’ WHERE enome = ‘Berlofa’;
UPDATE departamento_resumo_2 SET nome_gerente = 'Berlofa Reloaded' WHERE cpf_gerente = '1234';

-- 4.15 - Crie uma visão que recupere para cada departamento o seu código, o seu nome, a quantidade de empregados, o maior salário
-- do departamento, o menor salário do departamento e a média salarial do departamento. 
CREATE VIEW departamento_resumo_3 (codigo,dpt_nome,dpt_qtd,max_salario,min_salario,avg_salario) AS
	SELECT departamento.codigo,departamento.dnome,"dpt_qtd".qtd,"max_dpt".salario,
	"min_dpt".salario,"avg_dpt".salario FROM departamento
	INNER JOIN (SELECT COUNT(*) as "qtd",cdep FROM empregado GROUP BY cdep) as "dpt_qtd" ON "dpt_qtd".cdep = departamento.codigo
	INNER JOIN (SELECT MAX(salario) as "salario",cdep FROM empregado GROUP BY cdep) as "max_dpt" ON "max_dpt".cdep = departamento.codigo
	INNER JOIN (SELECT MIN(salario) as "salario",cdep FROM empregado GROUP BY cdep) as "min_dpt" ON "min_dpt".cdep = departamento.codigo
	INNER JOIN (SELECT AVG(salario) as "salario",cdep FROM empregado GROUP BY cdep) as "avg_dpt" ON "avg_dpt".cdep = departamento.codigo

-- 4.16 - Utilizando a visão anterior:

-- - Altere a média salarial do departamento de código igual a 2.
-- - Altere a quantidade de empregados do departamento de código 2.
-- - Exclua o departamento de código 2.
-- - Insira um novo departamento.
-- - Altere o nome de um dos departamentos que aparecem na visão.

-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
-- R: UPDATE empregado SET salario = salario*2 WHERE salario < (SELECT avg(salario) FROM empregado)
UPDATE departamento_resumo_3 SET avg_salario = 4000 WHERE codigo = 2;
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
-- R: INSERT INTO empregado  (cpf,enome,sexo,salario,cdep) VALUES (‘1144’,’Fulano’,’M’,10000,2)
UPDATE departamento_resumo_3 SET dpt_qtd = 4 WHERE codigo = 2;
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
-- R: DELETE FROM departamento WHERE codigo = 2;
DELETE FROM departamento_resumo_3 WHERE codigo = 2;
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
-- R: INSERT INTO departamento (dnome,codigo,gerente) VALUES (‘DPT 5’,20,’1234’)
INSERT INTO departamento_resumo_3 (codigo,dpt_nome,dpt_qtd,max_salario,min_salario,avg_salario) VALUES (5,'DPT 5',3,10000,4000,6000);
-- R: Atualização não permitida devido a View ser originada de mais de uma tabela.
-- R: UPDATE departamento SET dnome = ‘DPT RELOADED’ WHERE codigo IN (SELECT codigo FROM departamento_resumo_3 LIMIT 1)
UPDATE departamento_resumo_3  SET dpt_nome = 'DPT RELOADED' WHERE codigo = 5;
