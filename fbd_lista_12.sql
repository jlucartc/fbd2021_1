-- Lista 12

CREATE TABLE lista12.empregado (
	emp_matricula INTEGER,
	emp_nome VARCHAR[50],
	emp_sexo CHAR[1],
	PRIMARY KEY (emp_matricula)
);

CREATE TABLE lista12.banco_horas (
	ban_ano INTEGER,
	ban_mes CHAR(18),
	emp_matricula INTEGER,
	ban_total_horas REAL,
	CONSTRAINT fk_empregado
		FOREIGN KEY(emp_matricula)
			REFERENCES lista12.empregado(emp_matricula),
	PRIMARY KEY(ban_ano,ban_mes,emp_matricula)
);

CREATE TABLE lista12.frequencia (
	emp_matricula INT,
	freq_data TIMESTAMP,
	freq_hora_entrada VARCHAR[5],
	freq_hora_saida VARCHAR[5],
	freq_horas_excedentes REAL,
	freq_horas_noturnas REAL,
	freq_obs VARCHAR(100),
	CONSTRAINT fk_empregado
		FOREIGN KEY(emp_matricula)
			REFERENCES lista12.empregado(emp_matricula),
	PRIMARY KEY(emp_matricula,freq_data)
);

CREATE TABLE lista12.feriado (
	fer_data TIMESTAMP,
	fer_descricao CHAR(30),
	PRIMARY KEY(fer_data)
);

CREATE TABLE lista12.periodo (
	per_ano INTEGER,
	per_mes INTEGER,
	PRIMARY KEY(per_ano,per_mes)
);

-- 2.1: Crie uma stored procedure que receba como parâmetro de entrada três parâmetros a matrícula do empregado, o ano e o mês. Este procedimento deve inserir uma tupla
-- no banco de horas referente ao empregado e período em questão.
CREATE OR REPLACE FUNCTION lista12.insere_tupla_banco(matricula INTEGER,ano TEXT,mes TEXT) RETURNS VOID AS
$body$
	BEGIN
		INSERT INTO lista12.banco_horas (ban_ano,ban_mes,emp_matricula,ban_total_horas) VALUES (ano::INTEGER,mes::VARCHAR,matricula,0);
	END;
$body$
LANGUAGE 'plpgsql';

-- 2.2: Crie uma stored procedure que receba como parâmetro de entrada dois parâmetros o ano e o mês. Este procedimento deve inserir uma tupla no banco de horas para
-- todos os empregados referente período em questão.

CREATE OR REPLACE FUNCTION lista12.insere_tupla_para_todos(ano TEXT, mes TEXT) RETURNS VOID AS
$body$
DECLARE
	empregados CURSOR IS SELECT * FROM lista12.empregado;
	linha_empregado lista12.empregado%ROWTYPE;
BEGIN
	OPEN empregados;
	FETCH empregados INTO linha_empregado;
	WHILE FOUND LOOP
		INSERT INTO lista12.banco_horas (ban_ano,ban_mes,emp_matricula,ban_total_horas) VALUES (ano::INTEGER,mes,linha_empregado.emp_matricula,0);
		FETCH empregados INTO linha_empregado;
	END LOOP;
	CLOSE empregados;
END;
$body$
LANGUAGE 'plpgsql';

-- 2.3: Crie uma stored procedure que receba como parâmetro de entrada dois parâmetros o ano e o mês. Este procedimento deve retornar a matrícula do empregado com
-- maior número de horas no banco de horas.
CREATE OR REPLACE FUNCTION lista12.maior_numero_de_horas(ano text, mes text) RETURNS INTEGER AS
$body$
DECLARE
	matricula INTEGER;
BEGIN
	SELECT emp_matricula INTO matricula FROM lista12.banco_horas WHERE lista12.banco_horas.ban_ano::TEXT = ano AND lista12.banco_horas.ban_mes::TEXT = mes GROUP BY emp_matricula ORDER BY SUM(ban_total_horas) DESC LIMIT 1;
	RETURN matricula;
END;
$body$
LANGUAGE 'plpgsql';

-- 2.4: Crie uma stored procedure que receba como parâmetro de entrada quatro parâmetros a matrícula do empregado, o ano, o mês e o último dia do mês. Este
-- procedimento deve inserir um conjunto de tuplas na relação freqüência referentes ao empregado e período em questão.
CREATE OR REPLACE FUNCTION lista12.insere_tuplas_frequencia(matricula INTEGER,ano TEXT,mes TEXT,ultimo_dia TEXT) RETURNS VOID AS
$body$
DECLARE
BEGIN
	INSERT INTO lista12.frequencia (emp_matricula,freq_data,freq_hora_entrada,freq_hora_saida,freq_horas_excedentes,freq_horas_noturnas,freq_obs) VALUES (matricula,(ano || '-' || mes || '-' || ultimo_dia)::TIMESTAMP,'{07:30}','{17:00}',0,0,'ULTIMO DIA DO MES');
END;
$body$
LANGUAGE 'plpgsql';

-- 2.5: Crie uma stored procedure que receba como parâmetro de entrada três parâmetros a matrícula do empregado, o ano e o mês. Este procedimento deve atualizar o valor
-- do banco de horas neste mês para o empregado em questão.
CREATE OR REPLACE FUNCTION lista12.atualiza_mes_atual(matricula INTEGER, ano INTEGER, mes TEXT) RETURNS VOID AS
$body$
DECLARE
	linha_banco lista12.banco_horas%ROWTYPE;
BEGIN
	SELECT * INTO linha_banco FROM lista12.banco_horas WHERE ban_ano = ano AND ban_mes::INTEGER = mes::INTEGER AND emp_matricula = matricula;
	UPDATE lista12.banco_horas SET ban_total_horas = (ban_total_horas * 2) WHERE emp_matricula = matricula AND ban_mes::INTEGER = mes::INTEGER AND ban_ano = ano;
END;
$body$
LANGUAGE 'plpgsql';

-- 2.6: Crie uma stored procedure que receba como parâmetro de entrada dois parâmetros (smallint) o ano e o mês. Este procedimento deve atualizar o valor do banco de
-- horas neste mês para todos os funcionários.

CREATE OR REPLACE FUNCTION lista12.atualiza_mes_atual_todos(ano SMALLINT, mes SMALLINT) RETURNS VOID AS
$body$
	BEGIN
		UPDATE lista12.banco_horas SET ban_total_horas = 10 WHERE ban_ano = ano::INTEGER AND ban_mes::INTEGER = mes::INTEGER;
	END;
$body$
LANGUAGE 'plpgsql';

-- 2.7: Crie um trigger sobre a relação período com a seguinte finalidade: Quando um período for inserido deve-se inserir também, para todos os empregados, na relação
-- freqüência, uma tupla para cada dia no período em questão. Além disso, deve-se inserir também uma tupla para cada empregado no banco de horas.

CREATE OR REPLACE FUNCTION lista12.insere_frequencia_para_cada_dia() RETURNS TRIGGER AS
$body$
DECLARE
	empregados CURSOR IS SELECT * FROM lista12.empregado;
	linha_empregado lista12.empregado%ROWTYPE;
	inicio_periodo DATE;
	fim_periodo DATE;
	dia_atual DATE;
BEGIN
	inicio_periodo := CAST(NEW.per_ano || '-' || NEW.per_mes || '-' || '01' AS DATE);
	fim_periodo := inicio_produto + (INTERVAL '1' MONTH) - (INTERVAL '1' DAY);
	OPEN empregados;
	FETCH empregados INTO linha_empregado;
	
	WHILE FOUND LOOP
		dia_atual := inicio_periodo;
		WHILE dia_atual <= fim_periodo LOOP
			INSERT INTO lista12.frequencia (emp_matricula,freq_data,freq_hora_entrada,freq_hora_saida,freq_horas_excedentes,freq_horas_noturnas,freq_obs) VALUES (linha_empregado.emp_matricula,data_atual,'{}','{}',0,0,'{}');
			dia_atual := dia_atual + (INTERVAL '1' DAY);
		END LOOP;
		INSERT INTO lista12.banco_horas (ban_ano,ban_mes,emp_matricula,ban_total_horas) VALUES (NEW.per_ano,NEW.per_mes::TEXT,linha_empregado.emp_matricula,0);
		FETCH empregados INTO linha_empregado;
	END LOOP;
	CLOSE empregados;
END;
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER insere_frequencias_e_banco BEFORE INSERT ON lista12.periodo FOR EACH ROW EXECUTE PROCEDURE lista12.insere_frequencia_para_cada_dia();

-- 2.8: Crie um trigger sobre a tabela freqüência com o objetivo de atualizar o banco de horas sempre a freqüência for atualizada.

CREATE OR REPLACE FUNCTION lista12.atualiza_banco_por_frequencia() RETURNS TRIGGER AS
$body$
DECLARE
	banco CURSOR IS SELECT * FROM lista12.banco_horas WHERE ban_ano = date_part('YEAR',NEW.freq_data) AND ban_mes = date_part('MONTH',NEW.freq_data) AND lista12.banco_horas.emp_matricula = NEW.emp_matricula;
	linha_banco lista12.banco_horas%ROWTYPE;
BEGIN
 	OPEN banco;
	FETCH banco INTO linha_banco;
	WHILE FOUND LOOP
		UPDATE lista12.banco_horas SET ban_total_horas = ban_total_horas - EXTRACT(EPOCH FROM ((OLD.freq_data || ' ' || OLD.freq_hora_saida)::timestamp  -  (OLD.freq_data || ' ' || OLD.freq_hora_entrada)::timestamp) )/3600 + EXTRACT(EPOCH FROM ((NEW.freq_data || ' ' || NEW.freq_hora_saida)::timestamp  -  (NEW.freq_data || ' ' || NEW.freq_hora_entrada)::timestamp) )/3600 WHERE lista12.banco_horas.emp_matricula = NEW.emp_matricula AND ban_ano = date_part('YEAR',NEW.freq_data) AND ban_mes = date_part('MONTH',NEW.freq_data);
		FETCH banco INTO linha_banco;
	END LOOP;
END;
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER atualiza_banco_por_frequencia BEFORE UPDATE ON lista12.frequencia FOR EACH ROW EXECUTE PROCEDURE lista12.atualiza_banco_por_frequencia();
-- 2.9: Crie um trigger para que ao se excluir um período sejam excluídas também todas as freqüências referentes a este período. Deve-se excluir também todas as tuplas no
-- banco de horas referentes a este período.

CREATE OR REPLACE FUNCTION lista12.exclui_frequencias_e_horas() RETURNS TRIGGER AS
$body$
DECLARE
BEGIN
	DELETE FROM lista12.frequencia WHERE data_part('MONTH',freq_data)::INTEGER = OLD.per_mes AND data_part('YEAR',freq_data)::INTEGER = OLD.per_ano;
	DELETE FROM lista12.banco_horas WHERE ban_mes::INTEGER = OLD.per_mes AND ban_ano::INTEGER = OLD.per_ano;
END;
$body$
LANGUAGE 'plpgsql';

CREATE TRIGGER atualiza_banco_por_frequencia BEFORE DELETE ON lista12.periodo FOR EACH ROW EXECUTE PROCEDURE lista12.exclui_frequencias_e_horas();

-- 2.10: Crie um trigger para manter a seguinte regra de negócio. Cada empregado que trabalha em um dia feriado deve receber seis horas no banco de horas. Além
-- disso, cada hora extra em um feriado vale o dobro no banco de horas. Considere a inserção e a remoção de um feriado.