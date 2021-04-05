-- Lista 11

-- 2.1
CREATE OR REPLACE FUNCTION cadastra_empregado(text,text,text,text,text,decimal,text,integer)
RETURNS VOID AS
$body$
BEGIN
	INSERT INTO empregado (enome,cpf,endereco,nasc,sexo,salario,chefe,cdep) VALUES ($1,$2,$3,CAST($4 AS DATE),$5,$6,$7,$8);
END;
$body$
LANGUAGE 'plpgsql';

-- 2.2
CREATE OR REPLACE FUNCTION adiciona_horas_empregado_tarefas(varchar,decimal) RETURNS VOID AS
$body$
	DECLARE
		c REFCURSOR;
		r projeto%ROWTYPE;
	BEGIN
		OPEN c FOR SELECT * FROM projeto;
		FETCH c INTO r;
		WHILE FOUND LOOP
			INSERT INTO tarefa (cpf,codigo,horas) VALUES ($1,r.codigo,$2);
			FETCH c INTO r;
		END LOOP;
		CLOSE c;
	END;
$body$
LANGUAGE 'plpgsql';

-- 2.3
CREATE FUNCTION cpf_maior_salario() RETURNS VARCHAR AS
$body$
	DECLARE
		maior_salario CURSOR IS SELECT cpf FROM empregado 
		WHERE empregado.salario IN (
			SELECT MAX(salario) FROM empregado
		);
		cpf_maior_salario VARCHAR;
	BEGIN
		OPEN maior_salario;
		FETCH maior_salario INTO cpf_maior_salario;
		CLOSE maior_salario;
		RETURN cpf_maior_salario;
	END;
$body$
LANGUAGE 'plpgsql';

-- 2.4
CREATE OR REPLACE FUNCTION empregado_com_maior_salario (cdep integer) RETURNS VARCHAR
AS
$body$
	DECLARE
		maior_salario CURSOR IS SELECT cpf FROM (
			SELECT * FROM empregado WHERE cdep = cdep ORDER BY salario 				DESC	LIMIT 1
		) as "maior_salario";
		cpf_maior_salario VARCHAR;
	BEGIN
		OPEN maior_salario;
		FETCH maior_salario INTO cpf_maior_salario;
		CLOSE maior_salario;
		RETURN cpf_maior_salario;
	END
$body$
LANGUAGE 'plpgsql';

-- 2.5
CREATE OR REPLACE FUNCTION total_horas_projeto(codigo VARCHAR) RETURNS DECIMAL AS
$body$
DECLARE
	c CURSOR IS SELECT SUM(horas) FROM tarefa WHERE pcodigo = codigo;
	total_horas DECIMAL;
BEGIN
	OPEN c;
	FETCH c INTO total_horas;
	CLOSE c;
	RETURN total_horas;
END;
$body$
LANGUAGE 'plpgsql';

-- 2.6
CREATE FUNCTION aplica_taxa_de_aumento(taxa DECIMAL) RETURNS VOID AS
$body$
DECLARE
	c CURSOR IS SELECT * FROM empregado;
	linha_empregado empregado%ROWTYPE;
BEGIN
	OPEN c;
	FETCH c INTO linha_empregado;
	WHILE FOUND LOOP
		UPDATE empregado SET salario = salario * (1+ (taxa/100.0))
		WHERE cpf = linha_empregado.cpf;
		FETCH c INTO linha_empregado; 
	END LOOP;
	CLOSE c;
END;
$body$
LANGUAGE 'plpgsql';

-- 2.7
CREATE FUNCTION verifica_exclusao_empregado() RETURNS TRIGGER AS
$body$
DECLARE
	c CURSOR IS SELECT * FROM tarefa WHERE cpf  = OLD.cpf;
	linha_tarefa tarefa%ROWTYPE;
BEGIN
	OPEN c;
	FETCH c INTO linha_tarefa;
	CLOSE c;
	IF FOUND THEN
		RETURN NULL;	
	ELSE
		RETURN OLD;
	END IF;
END;
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER verifica_exclusao
BEFORE DELETE ON empregado
FOR EACH ROW EXECUTE  PROCEDURE
verifica_exclusao_empregado();

-- 2.8
CREATE FUNCTION projeto_delete_cascade() RETURNS TRIGGER AS
$body$
	DECLARE
		c CURSOR IS SELECT * FROM tarefa WHERE pcodgio = OLD.codigo;
		linha_tarefa tarefa%ROWTYPE;
	BEGIN
		OPEN c;
		FETCH c INTO linha_tarefa;
		CLOSE c;
		IF FOUND THEN
			DELETE FROM tarefa WHERE pcodigo = OLD.pcodigo;
			RETURN OLD;
		ELSE
			RETURN OLD;
		END IF;
	END
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER projeto_delete_cascade
BEFORE DELETE ON projeto FOR EACH ROW
EXECUTE PROCEDURE projeto_delete_cascade(); 

-- 2.9
CREATE FUNCTION aloca_20() RETURNS TRIGGER AS
$body$
DECLARE
	c CURSOR IS SELECT * FROM projeto WHERE projeto.pcodigo IN (
		SELECT pcodigo,SUM(horas) FROM tarefa GROUP BY pcodigo ORDER BY 			SUM(horas) LIMIT 1
	);
	linha_projeto projeto%ROWTYPE;
BEGIN
	OPEN c;
	FETCH c INTO linha_projeto;
	CLOSE c;
	INSERT INTO tarefa (cpf,pcodigo,hora) VALUES (NEW.cpf,linha_projeto.pcodigo,20);
	RETURN NEW;
END;
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER aloca_tarefa_emp
BEFORE INSERT ON empregado FOR EACH ROW
EXECUTE PROCEDURE aloca_20();

-- 3.a
CREATE FUNCTION insere_unidade_fortaleza() RETURNS TRIGGER AS
$body$
BEGIN
	INSERT INTO dunidade (dcodigo,dcidade) VALUES (new.codigo,’Fortaleza’);
	RETURN NEW;
END;
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER insdere_unidade_dpt BEFORE INSERT ON departamento
FOR EACH ROW EXECUTE PROCEDURE insere_unidade_fortaleza();

-- 3.b
CREATE FUNCTION verifica_salario_funcionario() RETURNS TRIGGER AS
$body$
DECLARE
	gerente empregado%ROWTYPE;
BEGIN
	SELECT * INTO gerente FROM empregado WHERE empregado.cpf = NEW.gerente;
	IF gerente.salario < NEW.salario THEN
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
END
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER controla_emp BEFORE UPDATE OR INSERT ON empregado
FOR EACH ROW EXECUTE PROCEDURE verifica_salario_funcionario();

-- 3.c
CREATE FUNCTION emp_max_horas() RETURNS TRIGGER AS
$body$
DECLARE
	c CURSOR IS SELECT SUM(horas) FROM tarefa WHERE cpf = NEW.cpf;
	soma_horas DECIMAL;
BEGIN
	OPEN c;
	FETCH c INTO soma_horas;
	IF soma_horas + NEW.horas > 40 THEN
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
END;
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER menor_40 BEFORE INSERT OR UPDATE ON tarefa FOR EACH ROW
EXECUTE PROCEDURE emp_max_horas();