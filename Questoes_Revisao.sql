**Schema (PostgreSQL v18)**

    -- =====================================================================
    -- Banco de dados de referência da disciplina — "Sistema Acadêmico IFPB"
    -- PostgreSQL 14+
    -- Uso: createdb academico && psql -d academico -f academico.sql
    -- =====================================================================
     
    DROP TABLE IF EXISTS matricula, turma, aluno, pre_requisito, disciplina, curso, professor, campus CASCADE;
     
    CREATE TABLE campus (
        id      int PRIMARY KEY,
        nome    text NOT NULL,
        cidade  text NOT NULL,
        uf      char(2) NOT NULL
    );
     
    CREATE TABLE professor (
        id             int PRIMARY KEY,
        nome           text NOT NULL,
        titulacao      text CHECK (titulacao IN ('Especialista','Mestre','Doutor')),
        regime         text CHECK (regime IN ('DE','40h','20h')),
        campus_id      int REFERENCES campus(id),
        data_admissao  date NOT NULL
    );
     
    CREATE TABLE curso (
        id              int PRIMARY KEY,
        nome            text NOT NULL,
        modalidade      text CHECK (modalidade IN ('Técnico Integrado','Técnico Subsequente','Tecnólogo','Bacharelado')),
        campus_id       int REFERENCES campus(id),
        coordenador_id  int REFERENCES professor(id)   -- NULL = curso sem coordenador designado
    );
     
    CREATE TABLE disciplina (
        id               int PRIMARY KEY,
        codigo           text UNIQUE NOT NULL,
        nome             text NOT NULL,
        carga_horaria    int NOT NULL CHECK (carga_horaria > 0),
        periodo          int NOT NULL,
        obrigatoria      boolean NOT NULL DEFAULT true,
        curso_id         int NOT NULL REFERENCES curso(id)
    );
     
    -- Relação N:N reflexiva: uma disciplina pode exigir vários pré-requisitos,
    -- e a mesma disciplina pode ser pré-requisito de várias outras.
    CREATE TABLE pre_requisito (
        disciplina_id int NOT NULL REFERENCES disciplina(id),
        requisito_id  int NOT NULL REFERENCES disciplina(id),
        PRIMARY KEY (disciplina_id, requisito_id),
        CHECK (disciplina_id <> requisito_id)
    );
     
    CREATE TABLE aluno (
        id              int PRIMARY KEY,
        matricula       text UNIQUE NOT NULL,
        nome            text NOT NULL,
        email           text,                           -- pode ser NULL
        data_nascimento date NOT NULL,
        data_ingresso   date NOT NULL,
        curso_id        int NOT NULL REFERENCES curso(id),
        situacao        text CHECK (situacao IN ('Ativo','Trancado','Concluído','Evadido'))
    );
     
    CREATE TABLE turma (
        id            int PRIMARY KEY,
        disciplina_id int NOT NULL REFERENCES disciplina(id),
        professor_id  int REFERENCES professor(id),     -- NULL = turma sem professor alocado
        semestre      text NOT NULL,                    -- '2025.1', '2025.2', '2026.1'
        vagas         int NOT NULL,
        UNIQUE (disciplina_id, semestre, professor_id)
    );
     
    CREATE TABLE matricula (
        id         int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        aluno_id   int NOT NULL REFERENCES aluno(id),
        turma_id   int NOT NULL REFERENCES turma(id),
        nota_final numeric(4,1) CHECK (nota_final BETWEEN 0 AND 10),  -- NULL = em curso
        frequencia numeric(5,2),
        situacao   text CHECK (situacao IN ('Cursando','Aprovado','Reprovado','Trancado')),
        UNIQUE (aluno_id, turma_id)
    );
     
    -- ---------------------------------------------------------------- campus
    INSERT INTO campus VALUES
     (1,'Esperança','Esperança','PB'),
     (2,'Campina Grande','Campina Grande','PB'),
     (3,'Monteiro','Monteiro','PB');
     
    -- ------------------------------------------------------------ professor
    INSERT INTO professor VALUES
     (1,'Ana Beatriz Ramos','Doutor','DE',1,'2011-03-14'),
     (2,'Carlos Eduardo Lins','Mestre','DE',1,'2014-08-01'),
     (3,'Daniela Farias','Doutor','DE',1,'2018-02-19'),
     (4,'Eduardo Nóbrega','Especialista','40h',1,'2021-09-06'),
     (5,'Fernanda Alencar','Mestre','DE',2,'2013-05-20'),
     (6,'Gustavo Tavares','Doutor','DE',2,'2010-11-08'),
     (7,'Helena Coutinho','Mestre','20h',3,'2022-04-11'),
     (8,'Igor Meneses','Doutor','DE',1,'2024-03-04');
     
    -- ---------------------------------------------------------------- curso
    INSERT INTO curso VALUES
     (1,'Análise e Desenvolvimento de Sistemas','Tecnólogo',1,1),
     (2,'Técnico em Informática','Técnico Integrado',1,3),
     (3,'Técnico em Agroindústria','Técnico Integrado',1,NULL),
     (4,'Engenharia de Computação','Bacharelado',2,6);
     
    -- ----------------------------------------------------------- disciplina
    INSERT INTO disciplina VALUES
     (1 ,'ADS101','Algoritmos e Programação I',80,1,true ,1),
     (2 ,'ADS102','Fundamentos de Banco de Dados',60,1,true ,1),
     (3 ,'ADS201','Algoritmos e Programação II',80,2,true ,1),
     (4 ,'ADS202','Banco de Dados',80,2,true ,1),
     (5 ,'ADS203','Engenharia de Software',60,2,true ,1),
     (6 ,'ADS301','Banco de Dados Avançado',60,3,false,1),
     (7 ,'ADS302','Desenvolvimento Web',80,3,true ,1),
     (8 ,'ADS303','Ciência de Dados',60,3,false,1),
     (9 ,'ADS401','Projeto Integrador',100,4,true ,1),
     (10,'TIN101','Introdução à Informática',60,1,true ,2),
     (11,'TIN201','Programação Web',80,2,true ,2),
     (12,'TIN301','Banco de Dados I',60,3,true ,2),
     (13,'AGR101','Química Geral',60,1,true ,3),
     (14,'ECP101','Cálculo I',90,1,true ,4);
     
    -- -------------------------------------------------------- pre_requisito
    -- ADS302, ADS303 e ADS401 exigem mais de uma disciplina.
    INSERT INTO pre_requisito (disciplina_id, requisito_id) VALUES
     (3 ,1),            -- Algoritmos II          <- Algoritmos I
     (4 ,2),            -- Banco de Dados         <- Fundamentos de BD
     (6 ,4),            -- BD Avançado            <- Banco de Dados
     (7 ,3), (7 ,4),    -- Desenvolvimento Web    <- Algoritmos II + Banco de Dados
     (8 ,3), (8 ,4),    -- Ciência de Dados       <- Algoritmos II + Banco de Dados
     (9 ,5), (9 ,7),    -- Projeto Integrador     <- Eng. de Software + Desenv. Web
     (11,10),           -- Programação Web        <- Introdução à Informática
     (12,10);           -- Banco de Dados I       <- Introdução à Informática
     
    -- --------------------------------------------------------------- aluno
    INSERT INTO aluno VALUES
     (1 ,'20251001','Alice Moreira'        ,'alice@academico.ifpb.edu.br' ,'2004-02-11','2025-03-10',1,'Ativo'),
     (2 ,'20251002','Bruno Sales'          ,NULL                          ,'2003-07-25','2025-03-10',1,'Ativo'),
     (3 ,'20251003','Camila Duarte'        ,'camila@academico.ifpb.edu.br','2005-11-02','2025-03-10',1,'Ativo'),
     (4 ,'20251004','Diego Vasconcelos'    ,'diego@academico.ifpb.edu.br' ,'2002-01-30','2025-03-10',1,'Trancado'),
     (5 ,'20251005','Elaine Torres'        ,'elaine@academico.ifpb.edu.br','2004-09-17','2025-03-10',1,'Ativo'),
     (6 ,'20241001','Felipe Andrade'       ,'felipe@academico.ifpb.edu.br','2003-04-08','2024-03-11',1,'Ativo'),
     (7 ,'20241002','Gabriela Nunes'       ,'gabriela@academico.ifpb.edu.br','2002-12-19','2024-03-11',1,'Ativo'),
     (8 ,'20241003','Henrique Pessoa'      ,NULL                          ,'2001-06-05','2024-03-11',1,'Evadido'),
     (9 ,'20231001','Isabela Cavalcanti'   ,'isabela@academico.ifpb.edu.br','2000-08-22','2023-03-13',1,'Concluído'),
     (10,'20231002','João Pedro Leite'     ,'joao@academico.ifpb.edu.br'  ,'2001-03-14','2023-03-13',1,'Ativo'),
     (11,'20251101','Karina Bezerra'       ,'karina@academico.ifpb.edu.br','2008-05-09','2025-03-10',2,'Ativo'),
     (12,'20251102','Lucas Aragão'         ,'lucas@academico.ifpb.edu.br' ,'2008-10-27','2025-03-10',2,'Ativo'),
     (13,'20241101','Marina Estrela'       ,'marina@academico.ifpb.edu.br','2007-01-16','2024-03-11',2,'Ativo'),
     (14,'20241102','Nícolas Beltrão'      ,NULL                          ,'2007-07-03','2024-03-11',2,'Ativo'),
     (15,'20251201','Olívia Quirino'       ,'olivia@academico.ifpb.edu.br','2008-02-28','2025-03-10',3,'Ativo'),
     (16,'20251301','Paulo Ricardo Maia'   ,'paulo@academico.ifpb.edu.br' ,'2004-06-12','2025-03-10',4,'Ativo'),
     (17,'20261001','Queila Fontes'        ,'queila@academico.ifpb.edu.br','2005-12-01','2026-03-09',1,'Ativo'),
     (18,'20261002','Rafael Siqueira'      ,NULL                          ,'2006-03-23','2026-03-09',1,'Ativo');
     
    -- --------------------------------------------------------------- turma
    INSERT INTO turma VALUES
     (1 ,1 ,1   ,'2025.1',40),
     (2 ,2 ,3   ,'2025.1',40),
     (3 ,3 ,1   ,'2025.2',40),
     (4 ,4 ,3   ,'2025.2',40),
     (5 ,5 ,2   ,'2025.2',40),
     (6 ,6 ,3   ,'2026.1',25),
     (7 ,7 ,4   ,'2026.1',35),
     (8 ,8 ,8   ,'2026.1',25),
     (9 ,9 ,2   ,'2026.1',20),
     (10,10,7   ,'2025.1',30),
     (11,11,4   ,'2025.2',30),
     (12,12,3   ,'2026.1',30),
     (13,1 ,2   ,'2025.1',40),   -- segunda turma da mesma disciplina no semestre
     (14,2 ,NULL,'2026.1',40),   -- turma ainda sem professor alocado
     (15,14,6   ,'2025.1',50),
     (16,13,NULL,'2025.1',45),
     (17,4 ,1   ,'2025.1',40),
     (18,5 ,2   ,'2026.1',40);
     
    -- ----------------------------------------------------------- matricula
    -- Combinações aluno x turma coerentes com o curso, com nota derivada de
    -- fórmula determinística (reprodutível em qualquer instalação).
    INSERT INTO matricula (aluno_id, turma_id, nota_final, frequencia, situacao)
    WITH candidata AS (
        SELECT a.id AS aluno_id,
               t.id AS turma_id,
               CASE WHEN t.semestre = '2026.1' THEN NULL   -- semestre corrente: ainda sem nota
                    ELSE round((4 + ((a.id * 7 + t.id * 13) % 61) / 10.0)::numeric, 1)
               END AS nota
        FROM aluno a
        JOIN disciplina d ON d.curso_id = a.curso_id
        JOIN turma t      ON t.disciplina_id = d.id
        WHERE a.situacao <> 'Evadido'
          AND extract(year from a.data_ingresso) <= substring(t.semestre from 1 for 4)::int
          AND (a.id + t.id) % 3 <> 0   -- desbasta: ninguém cursa tudo
    )
    SELECT aluno_id,
           turma_id,
           nota,
           round((60 + ((aluno_id * 11 + turma_id * 5) % 41))::numeric, 2),
           CASE WHEN nota IS NULL THEN 'Cursando'
                WHEN nota >= 7   THEN 'Aprovado'
                ELSE 'Reprovado' END
    FROM candidata
    ORDER BY aluno_id, turma_id;   -- ids previsíveis, iguais em qualquer carga
     
    -- Casos especiais úteis em aula (trancamento, aprovação alta, reprovação)
    UPDATE matricula SET situacao = 'Trancado', nota_final = NULL
     WHERE aluno_id = 4;
     
    ANALYZE;

---

**Query #1**

    -- 1. Liste o nome dos alunos que não possuem email cadastrado.
    -- (4 linhas: Bruno, Henrique, Nícolas, Rafael)
    select nome
    from aluno
    where email is null;

| nome            |
| --------------- |
| Bruno Sales     |
| Henrique Pessoa |
| Nícolas Beltrão |
| Rafael Siqueira |

---
**Query #2**

    -- 2. Liste o código e o nome das disciplinas com carga horária de 80h ou mais.
    select codigo, nome
    from disciplina
    where carga_horaria >= 80;

| codigo | nome                        |
| ------ | --------------------------- |
| ADS101 | Algoritmos e Programação I  |
| ADS201 | Algoritmos e Programação II |
| ADS202 | Banco de Dados              |
| ADS302 | Desenvolvimento Web         |
| ADS401 | Projeto Integrador          |
| TIN201 | Programação Web             |
| ECP101 | Cálculo I                   |

---
**Query #3**

    -- 3. Liste o nome dos professores admitidos antes de 2015.
    select nome
    from professor
    where data_admissao < '2015-01-01';

| nome                |
| ------------------- |
| Ana Beatriz Ramos   |
| Carlos Eduardo Lins |
| Fernanda Alencar    |
| Gustavo Tavares     |

---
**Query #4**

    -- 4. Liste o nome dos alunos que ingressaram em 2025.
    select nome
    from aluno
    where extract (year from data_ingresso) = 2025;

| nome               |
| ------------------ |
| Alice Moreira      |
| Bruno Sales        |
| Camila Duarte      |
| Diego Vasconcelos  |
| Elaine Torres      |
| Karina Bezerra     |
| Lucas Aragão       |
| Olívia Quirino     |
| Paulo Ricardo Maia |

---
**Query #5**

    -- 5. Liste o nome dos professores que ministram pelo menos uma turma.
    select distinct professor.nome
    from professor
    join turma on professor.id = turma.professor_id;

| nome                |
| ------------------- |
| Ana Beatriz Ramos   |
| Igor Meneses        |
| Carlos Eduardo Lins |
| Daniela Farias      |
| Gustavo Tavares     |
| Eduardo Nóbrega     |
| Helena Coutinho     |

---
**Query #6**

    -- 6. Liste os professores que nunca ministraram turma.
    -- (Fernanda Alencar)
    select professor.nome
    from professor
    left join turma on professor.id = turma.professor_id
    where turma.id is null;

| nome             |
| ---------------- |
| Fernanda Alencar |

---
**Query #7**

    -- 7. Liste o nome das disciplinas que não exigem pré-requisito.
    
    select nome
    from disciplina
    where id not in (
        select disciplina_id 
        from pre_requisito
    );

| nome                          |
| ----------------------------- |
| Algoritmos e Programação I    |
| Fundamentos de Banco de Dados |
| Engenharia de Software        |
| Introdução à Informática      |
| Química Geral                 |
| Cálculo I                     |

---
**Query #8**

    -- 8. Liste o nome dos alunos reprovados em alguma disciplina em 2025.
    
    select distinct aluno.nome
    from aluno
    join matricula on aluno.id = matricula.aluno_id
    join turma on matricula.turma_id = turma.id
    where matricula.situacao = 'Reprovado' 
      and turma.semestre like '2025%';

| nome               |
| ------------------ |
| Felipe Andrade     |
| Olívia Quirino     |
| Isabela Cavalcanti |
| Gabriela Nunes     |
| João Pedro Leite   |
| Camila Duarte      |
| Paulo Ricardo Maia |
| Elaine Torres      |
| Bruno Sales        |
| Alice Moreira      |

---
**Query #9**

    -- 9. Mostre o nome de cada curso e o total de alunos, ordenado de forma decrescente pelo total.
    
    select curso.nome, count (aluno.id) as total_alunos
    from curso
    left join aluno on curso.id = aluno.curso_id
    group by curso.id, curso.nome
    order by total_alunos desc;

| nome                                  | total_alunos |
| ------------------------------------- | ------------ |
| Análise e Desenvolvimento de Sistemas | 12           |
| Técnico em Informática                | 4            |
| Técnico em Agroindústria              | 1            |
| Engenharia de Computação              | 1            |

---
**Query #10**

    -- 10. Liste as disciplinas com mais de 8 matrículas.
    
    select disciplina.nome, count(matricula.id) as total_matriculas
    from disciplina
    join turma on disciplina.id = turma.disciplina_id
    join matricula on turma.id = matricula.turma_id
    group by disciplina.id, disciplina.nome
    having count(matricula.id) > 8;

| nome                          | total_matriculas |
| ----------------------------- | ---------------- |
| Banco de Dados                | 12               |
| Algoritmos e Programação I    | 14               |
| Engenharia de Software        | 12               |
| Fundamentos de Banco de Dados | 12               |

---
**Query #11**

    -- 11. Mostre quantas matrículas estão com situação "Cursando".
    -- (42)
    select count(*) as total_cursando
    from matricula
    where situacao = 'Cursando';

| total_cursando |
| -------------- |
| 42             |

---
**Query #12**

    -- 12. Mostre a disciplina com mais matrículas.
    -- (Algoritmos e Programação I, 14 matrículas)
    
    select disciplina.nome, count(matricula.id) as total_matriculas
    from disciplina
    join turma on disciplina.id = turma.disciplina_id
    join matricula on turma.id = matricula.turma_id
    group by disciplina.id, disciplina.nome
    order by total_matriculas desc
    limit 1;

| nome                       | total_matriculas |
| -------------------------- | ---------------- |
| Algoritmos e Programação I | 14               |

---

[View on DB Fiddle](https://www.db-fiddle.com/f/2y6pWV2RksZ1QbDcSRcfGr/1)
