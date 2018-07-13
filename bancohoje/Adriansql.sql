--1. Crie a tabela professor com os campos cod (auto incrementado), nome, CPF (unico),
--dataNascimento, dtHrAtualizacao (data e hora) e codDepto que referencia Departamento.
--Considere que caso um departamento seja excluído, os professores alocados naquele
--departamento ficarão sem estar alocados em nenhum departamento e em caso de alteração da
--PK de departamento os professores continuarão a atuar nesse departamento. Crie as devidas
--restrições de integridade.

CREATE TABLE "professor"(
	"codigo" serial,
	"nome" varchar(100) NOT NULL,
	"cpf" integer UNIQUE,
    "dataNascimento" date,
	"dtHrAtualizacao" timestamp,
	"codDepto" integer,
	CONSTRAINT "ProfPK" PRIMARY KEY ("codigo"),
	CONSTRAINT "ProfDeptoFK" FOREIGN KEY ("codDepto") 
        REFERENCES "Departamento" ("codigo")
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

INSERT INTO "professor" ("nome", "cpf", "dataNascimento", "dtHrAtualizacao", "codDepto") VALUES 
('Adoleta de Uruguaiana', (66375563), to_date('02/03/1980','DD/MM/YYYY'), current_date - interval '1 mons' + interval '18 hours' + '50 minute', 1),

('Olaf da Silva', (26375563), to_date('10/12/1988','DD/MM/YYYY'), current_date - interval '4 mons' + interval '9 hours' + '2 minute', 2),

('Loro José', (36375563), to_date('15/01/1967','DD/MM/YYYY'), current_date - interval '8 mons' + interval '11 hours' + '15 minute', 4),

('Carlos Silva', (46375563), to_date('01/02/1990','DD/MM/YYYY'), current_date - interval '1 mons' + interval '16 hours' + '23 minute', 3),

('Animalan', (56375563), to_date('30/09/1987','DD/MM/YYYY'), current_date - interval '2 mons' + interval '10 hours' + '32 minute', 4),

('Animalinho', (56375564), to_date('03/04/1980','DD/MM/YYYY'), current_date - interval '2 mons' + interval '12 hours' + '48 minute', 4)

--2. Faça uma consulta que retorne o nome de cada departamento, a quantidade de disciplinas
--alocadas neste departamento e o somatório de horas (de disciplinas) vinculado a cada
--departamento.

SELECT d.nome as Departamento, COUNT(disc."codDepto") as quantidade, coalesce(sum(disc."cargaHoraria")) as "CargaHoraria" FROM "Disciplina" disc
RIGHT OUTER JOIN "Departamento" d ON d."codigo" = disc."codDepto"
GROUP BY d.nome

--3. Liste o nome dos professores, idade (quantidade de anos já vividos) e dtHrAtualizacao para os professores que contem "silva" (sem distinguir caracteres maiúsculos de minúsculos) em
--alguma parte do nome. Ordene a resposta pela dtHrAtualizacao decrescente.

SELECT p.nome as "Nome", extract(year FROM age("dataNascimento")) as "Idade", p."dtHrAtualizacao" as "DtHr" FROM professor p
WHERE lower(nome) like '%silva%'
ORDER BY "DtHr" desc

--4. Liste os cursos e a sua carga horária total.
SELECT c.nome as "Curso", sum(d."cargaHoraria") as "cargaHoraria" FROM "CursoDisciplina" cd
INNER JOIN "Curso" c ON c."codigo" = cd."codCurso"
INNER JOIN "Disciplina" d ON d."codigo" = cd."codDisciplina"
GROUP BY c.nome
ORDER BY c.nome