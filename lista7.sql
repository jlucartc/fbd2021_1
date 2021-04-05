-- 1. Recuperar para cada departamento: o seu nome, o maior e o menor salário recebido por empregados do departamento e a média salarial do departamento.
select departamento.dnome,max(salario),min(salario) from empregado
inner join departamento on departamento.codigo = empregado.cdep
group by dnome
-- 2. Recuperar o nome do departamento com maior média salarial.
select departamento.dnome from empregado
inner join departamento on departamento.codigo = empregado.cdep
group by dnome
order by avg(salario) desc
limit 1
-- 3. Recuperar para cada departamento: o seu nome, o nome do seu gerente, a quantidade de empregados, a quantidade de projetos do departamento e a quantidade de unidades do departamento.
select departamento.dnome,"gerente".enome,count(distinct "funcionario".cpf) as "funcionarios",count(distinct projeto.pcodigo) as "projetos",count(distinct dunidade.dcidade) as "unidades" from departamento
inner join empregado as "gerente" on "gerente".cpf = gerente
inner join empregado as "funcionario" on "funcionario".cdep = codigo
inner join projeto on projeto.cdep = codigo
inner join dunidade on dunidade.dcodigo = codigo
group by departamento.dnome,"gerente".enome
-- 4. Recuperar o nome do projeto que consome o maior número de horas.
select projeto.pnome from projeto
inner join tarefa on tarefa.pcodigo = projeto.pcodigo
group by projeto.pnome
order by sum(horas) desc
limit 1
-- 5. Recuperar o nome do projeto mais caro.
select projeto.pnome from projeto
inner join tarefa on tarefa.pcodigo = projeto.pcodigo
inner join empregado on empregado.cpf = tarefa.cpf
group by projeto.pnome
order by sum(empregado.salario) desc
limit 1
-- 6. Recuperar para cada projeto: o seu nome, o nome gerente do departamento que controla o projeto, a quantidade total de horas alocadas ao projeto, a quantidade de empregados alocados ao projeto e o custo mensal do projeto.
select pnome as "projeto","gerente".enome as "gerente",sum(tarefa.horas) as "horas",count(empregado.cpf) as "empregados",sum(empregado.salario) as "custo mensal" from projeto
inner join departamento on departamento.codigo = projeto.cdep
inner join empregado as "gerente" on "gerente".cpf = departamento.gerente
inner join tarefa on tarefa.pcodigo = projeto.pcodigo
inner join empregado on empregado.cpf = tarefa.cpf
group by projeto.pcodigo,"gerente".enome
-- 7. Recuperar o nome dos gerentes com sobrenome ‘Silva’.
select enome from empregado
where cpf in (select gerente from departamento)
and enome ~ '^.+\sSilva'
-- 8. Recupere o nome dos gerentes que estão alocados em algum projeto (ou seja, possuem “alguma” tarefa em “algum” projeto).
select empregado.enome from tarefa
inner join projeto on projeto.pcodigo = tarefa.pcodigo
inner join departamento on departamento.codigo = projeto.cdep
inner join empregado on empregado.cpf = departamento.gerente
group by empregado.enome
-- 9. Recuperar o nome dos empregados que participam de projetos que não são gerenciados pelo seu departamento.
select empregado.enome from tarefa
inner join projeto on projeto.pcodigo = tarefa.pcodigo
inner join empregado on empregado.cpf = tarefa.cpf
where projeto.cdep <> empregado.cdep
group by empregado.enome
-- 10. Recuperar o nome dos empregados que participam de todos os projetos.
select empregado.enome from empregado
inner join (select empregado.cpf,count(distinct tarefa.pcodigo) from empregado inner join tarefa on tarefa.cpf = empregado.cpf group by empregado.cpf) as "projetos" on "projetos".cpf = empregado.cpf
and "projetos".count = (select count(*) from projeto)
-- 11. Recuperar para cada funcionário (empregado): o seu nome, o seu salário e o nome do seu departamento. O resultado deve estar em ordem decrescente de salário. Mostrar os empregados sem departamento e os departamentos sem empregados.
select enome,salario,departamento.dnome from empregado
left join departamento on empregado.cdep = departamento.codigo
union select enome,salario,departamento.dnome from departamento
left join empregado on empregado.cdep = departamento.codigo
order by salario desc
-- 12. Recuperar para cada funcionário (empregado): o seu nome, o nome do seu chefe e o nome do gerente do seu departamento.
select empregado.enome,"chefe".enome,"gerente".enome from empregado
inner join empregado as "chefe" on "chefe".cpf = empregado.chefe
inner join departamento on departamento.codigo = empregado.cdep
inner join empregado as "gerente" on departamento.gerente = "gerente".cpf
-- 13. Listar nome dos departamentos com média salarial maior que a média salarial da empresa.
select dnome from departamento
inner join (select cdep,avg(salario) as "avg" from empregado group by cdep) as "media" on "media".cdep = departamento.codigo
where "media".avg > (select avg(salario) from empregado)
-- 14. Listar todos os empregados que possuem salário maior que a média salarial de seus departamentos.
select empregado.* from empregado
inner join (select avg(salario) as "avg",cdep from empregado group by cdep) as "departamento" on "departamento".cdep = empregado.cdep
where salario > "departamento".avg
-- 15. Listar os empregados lotados nos departamentos localizados em “Fortaleza”.
select empregado.* from empregado
inner join departamento on departamento.codigo = empregado.cdep
inner join dunidade on dunidade.dcodigo = departamento.codigo
where dunidade.dcidade = 'Fortaleza'
-- 16. Listar nome de departamentos com empregados ganhando duas vezes mais que a média do departamento.
select departamento.dnome from departamento
inner join empregado on empregado.cdep = departamento.codigo
inner join (select avg(salario)as "avg",cdep from empregado group by cdep) as "media" on "media".cdep = departamento.codigo
where empregado.salario >= 2*"media".avg
-- 17. Recuperar o nome dos empregados com salário entre R$ 700 e R$ 2800.
select * from empregado
where salario between 700 and 2800
-- 18. Recuperar o nome dos departamentos que controlam projetos com mais de 50 empregados e que também controlam projetos com menos de 5 empregados
select departamento.dnome from departamento
inner join (select count(distinct tarefa.cpf) as "qtd",projeto.pcodigo,cdep from projeto inner join tarefa on tarefa.pcodigo = projeto.pcodigo group by projeto.pcodigo) as "empregados_por_projeto" on "empregados_por_projeto".cdep = departamento.codigo
where "empregados_por_projeto".qtd > 50 or "empregados_por_projeto".qtd < 5




