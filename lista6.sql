-- 1) Recupere o nome e o salário de todos os empregados.
select enome,salario from empregado

-- 2) Recupere o nome e o salário de todos os empregados do sexo feminino.
select enome,salario from empregado where sexo = 'F'

-- 3) Recupere o nome e o salário de todos os empregados do sexo feminino e que ganham salário maior que R$ 10.000,00.
select enome,salario from empregado where sexo = 'F' and salario > 10000

-- 4) Recupere a quantidade de empregados.
select count(*) from empregado

-- 5) Recupere o maior salário, o menor salário e a média salarial da empresa.
select max(salario),min(salario),avg(salario) from empregado

-- 6) Recupere o nome e o salário de todos os empregados que trabalham em Marketing.
select enome,salario from empregado
inner join departamento on departamento.codigo = empregado.cdep
where departamento.dnome = 'Marketing'

-- 7) Recupere o CPF dos empregados que possuem alguma tarefa.
select empregado.cpf from empregado
inner join tarefa on tarefa.cpf = empregado.cpf
group by empregado.cpf

-- 8) Recupere o CPF dos empregados que não possuem tarefa.
select cpf from empregado
where cpf not in (select cpf from tarefa)

-- 9) Recupere o nome dos empregados que possuem alguma tarefa.
select enome from (
	select empregado.cpf,enome from empregado
	inner join tarefa on tarefa.cpf = empregado.cpf group by empregado.cpf,enome
) as "table"

-- 10)Recupere o nome dos empregados que não possuem tarefa.
select enome from empregado
where cpf not in (select cpf from tarefa)

-- 11)Recupre o CPF dos empregados que possuem pelo menos uma tarefa com mais de 30 horas.
select empregado.cpf from empregado
inner join tarefa on tarefa.cpf = empregado.cpf
where tarefa.horas > 30 group by empregado.cpf

-- 12) Recupre o nome dos empregados que possuem pelo menos uma tarefa com mais de 30 horas.
select empregado.enome from empregado
inner join tarefa on tarefa.cpf = empregado.cpf
where tarefa.horas > 30 group by empregado.cpf

-- 13)Recupere para cada departamento o seu nome e o nome do seu gerente.
select departamento.dnome,empregado.enome from departamento
inner join empregado on empregado.cpf = departamento.gerente

-- 14)Recupere o CPF de todos os empregados que trabalham em Pesquisa ou que diretamente gerenciam um empregado que trabalha em Pesquisa.
select empregado.cpf from empregado where cpf in (
	select cpf from empregado
	inner join departamento on departamento.codigo = empregado.cdep
	where departamento.dnome = 'Pesquisa'
) or empregado.cpf in (
	select gerente from departamento where dnome = 'Pesquisa'
)

-- 15)Recupere o nome e a cidade dos projetos que envolvem (contêm) pelo menos um empregado que trabalha mais de 30 horas nesse projeto.
select projeto.pnome,projeto.cidade from projeto
inner join tarefa on tarefa.pcodigo = projeto.pcodigo
inner join empregado on empregado.cpf = tarefa.cpf
where horas > 30
group by projeto.pnome,projeto.cidade

-- 16)Recupere o nome e a data de nascimento dos gerentes de cada departamento.
select empregado.enome,empregado.nasc from empregado
inner join departamento on departamento.gerente = empregado.cpf

-- 17)Recupere o nome e o endereço de todos os empregados que trabalham para o departamento “Pesquisa”.
select empregado.enome,empregado.endereco
inner join departamento on departamento.codigo = empregado.cdep
where departamento.nome = 'Pesquisa'

-- 18)Para cada projeto localizado em Icapuí, recupere o código do projeto, o nome do departamento que o controla e o nome do seu gerente.
select projeto.pcodigo,departamento.dnome,empregado.enome from projeto
inner join departamento on projeto.cdep = departamento.codigo
inner join empregado on empregado.cpf = departamento.gerente
where projeto.cidade = 'Icapui'

-- 19)Recupere o nome e o sexo dos empregados que são gerentes.
select enome,sexo from empregado where cpf in (select gerente from departamento)


-- 20)Recupere o nome e o sexo dos empregados que não são gerentes.
select enome,sexo from empregado where cpf not in (select gerente from departamento)