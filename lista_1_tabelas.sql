create database fdb2020

create table empregado (
	enome text,
	cpf varchar(11),
	endereco text,
	nasc date,
	sexo varchar(1),
	salario float check salario > 1100,
	chefe bigint references empregado(cpf),
	cdep bigint references departamento(codigo)
)

create table departamento (
	dnome text,
	codigo bigint,
	gerente bigint references empregado(cpf)
)

create table projeto (
	pnome text,
	pcodigo text,
	cidade text,
	cdep bigint references departamento(codigo)
)

create table tarefa (
	cpf bigint references empregado(cpf),
	pcodigo text,
	horas float
)

create table dunidade (
	dcodigo bigint references departamento(codigo),
	dcidade text
)

insert into empregado (enome,cpf,endereco,nasc,sexo,salario,chefe,cdep) values
('Chiquin','1234','rua 1, 1','02/02/62','M',10000.00,8765,3),
('Helenita','4321','rua 2, 2','03/03/63','F',12000.00,6543,2),
('Pedrin','5678','rua 3, 3','04/04/64','M',9000.00,6543,2),
('Valtin','8765','rua 4, 4','05/05/65','M',15000.00,null,4),
('Zulmira','3456','rua 5, 5','06/06/66','F',12000.00,8765,3),
('Zefinha','6543','rua 6, 6','07/07/67','F',10000.00,8765,2)

insert into departamento (dnome,codigo,gerente) values
('Pesquisa',3,1234),
('Marketing',2,6543),
('Administracao',4,8765)

insert into projeto (pnome,pcodigo,cidade,cdep) values
('ProdutoA','PA','Cumbuco',3),
('ProdutoB','PB','Icapui',3),
('Informatizacao','Inf','Fortaleza',4),
('Divulgacao','Div','Morro Branco',2)

insert into tarefa (cpf,pcodigo,horas) values
(1234,'PA',30.0),
(1234,'PB',10.0),
(4321,'PA',5.0),
(4321,'Div',35.0),
(5678,'Div',40.0),
(8765,'Inf',32.0),
(8765,'Div',8.0),
(3456,'PA',10.0),
(3456,'PB',25.0),
(3456,'Div',5.0),
(6543,'PB',40.0)

insert into dunidade (dcodigo,dcidade) values (),
(2,'Morro Branco'),
(3,'Cumbuco'),
(3,'Prainha'),
(3,'Taiba'),
(3,'Icapui'),
(4,'Fortaleza')

