-- Pacote PKG_ALUNO

-- Procedure de exclusão de aluno:
-- Cria uma procedure que recebe o ID de um aluno como parâmetro e exclui o registro correspondente na tabela de alunos,
-- além de remover todas as matrículas associadas.

CREATE OR REPLACE PROCEDURE excluir_aluno(p_id_aluno NUMBER) IS
BEGIN
    DELETE FROM matricula WHERE id_aluno = p_id_aluno;
    DELETE FROM aluno WHERE id_aluno = p_id_aluno;
END excluir_aluno;
/

-- Como Executar: 
-- EXEC excluir_aluno(id_aluno);


-- Cursor de listagem de alunos maiores de 18 anos:
-- Desenvolve um cursor que lista o nome e a data de nascimento de todos os alunos com idade superior a 18 anos.

DECLARE
    CURSOR cur_alunos_maiores_18 IS
        SELECT nome, data_nascimento
        FROM aluno
        WHERE TRUNC(MONTHS_BETWEEN(SYSDATE, data_nascimento) / 12) > 18;
    v_nome aluno.nome%TYPE;
    v_data_nascimento aluno.data_nascimento%TYPE;
BEGIN
    OPEN cur_alunos_maiores_18;
    LOOP
        FETCH cur_alunos_maiores_18 INTO v_nome, v_data_nascimento;
        EXIT WHEN cur_alunos_maiores_18%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || v_nome || ', Data de Nascimento: ' || TO_CHAR(v_data_nascimento, 'DD/MM/YYYY'));
    END LOOP;
    CLOSE cur_alunos_maiores_18;
END;
/

-- Como Executar:
-- Declare o cursor e percorra os registros conforme o código acima.


-- Cursor com filtro por curso:
-- Cria um cursor parametrizado que recebe o id_curso e exibe os nomes dos alunos matriculados no curso especificado.

DECLARE
    CURSOR cur_alunos_curso(p_id_curso NUMBER) IS
        SELECT a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        JOIN disciplina d ON m.id_disciplina = d.id_disciplina
        WHERE d.id_curso = p_id_curso;
    v_nome aluno.nome%TYPE;
BEGIN
    OPEN cur_alunos_curso(1);  -- Substitua 1 pelo id_curso desejado
    LOOP
        FETCH cur_alunos_curso INTO v_nome;
        EXIT WHEN cur_alunos_curso%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || v_nome);
    END LOOP;
    CLOSE cur_alunos_curso;
END;
/

-- Como Executar:
-- Declare o cursor passando o parâmetro id_curso conforme o código acima.


-- Pacote PKG_DISCIPLINA

-- Procedure de cadastro de disciplina:
-- Recebe o nome, a descrição e a carga horária da disciplina e insere esses dados na tabela correspondente.

CREATE OR REPLACE PROCEDURE cadastrar_disciplina(p_nome VARCHAR2, p_descricao CLOB, p_carga_horaria NUMBER) IS
BEGIN
    INSERT INTO disciplina (nome, descricao, carga_horaria)
    VALUES (p_nome, p_descricao, p_carga_horaria);
END cadastrar_disciplina;
/

-- Como Executar:
-- EXEC cadastrar_disciplina('Matemática Avançada', 'Curso focado em técnicas avançadas de matemática', 120);


-- Cursor para total de alunos por disciplina:
-- Percorre as disciplinas e exibe o número total de alunos matriculados em cada uma (somente disciplinas com mais de 10 alunos).

DECLARE
    CURSOR cur_total_alunos_disciplina IS
        SELECT d.nome, COUNT(m.id_aluno) AS total_alunos
        FROM disciplina d
        JOIN matricula m ON d.id_disciplina = m.id_disciplina
        GROUP BY d.nome
        HAVING COUNT(m.id_aluno) > 10;
    v_nome_disciplina disciplina.nome%TYPE;
    v_total_alunos NUMBER;
BEGIN
    OPEN cur_total_alunos_disciplina;
    LOOP
        FETCH cur_total_alunos_disciplina INTO v_nome_disciplina, v_total_alunos;
        EXIT WHEN cur_total_alunos_disciplina%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Disciplina: ' || v_nome_disciplina || ', Total de Alunos: ' || v_total_alunos);
    END LOOP;
    CLOSE cur_total_alunos_disciplina;
END;
/

-- Como Executar:
-- Declare o cursor e percorra os registros conforme o código acima.


-- Cursor com média de idade por disciplina:
-- Recebe o id_disciplina e calcula a média de idade dos alunos matriculados.

DECLARE
    CURSOR cur_media_idade_disciplina(p_id_disciplina NUMBER) IS
        SELECT AVG(TRUNC(MONTHS_BETWEEN(SYSDATE, a.data_nascimento) / 12)) AS media_idade
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    v_media_idade NUMBER;
BEGIN
    OPEN cur_media_idade_disciplina(1);  -- Substitua 1 pelo id_disciplina desejado
    FETCH cur_media_idade_disciplina INTO v_media_idade;
    DBMS_OUTPUT.PUT_LINE('Média de Idade: ' || v_media_idade);
    CLOSE cur_media_idade_disciplina;
END;
/

-- Como Executar:
-- Declare o cursor passando o parâmetro id_disciplina conforme o código acima.


-- Procedure para listar alunos de uma disciplina:
-- Recebe o id_disciplina e exibe os nomes dos alunos matriculados nela.

CREATE OR REPLACE PROCEDURE listar_alunos_disciplina(p_id_disciplina NUMBER) IS
    CURSOR cur_alunos IS
        SELECT a.nome
        FROM aluno a
        JOIN matricula m ON a.id_aluno = m.id_aluno
        WHERE m.id_disciplina = p_id_disciplina;
    v_nome aluno.nome%TYPE;
BEGIN
    OPEN cur_alunos;
    LOOP
        FETCH cur_alunos INTO v_nome;
        EXIT WHEN cur_alunos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Aluno: ' || v_nome);
    END LOOP;
    CLOSE cur_alunos;
END listar_alunos_disciplina;
/

-- Como Executar:
-- EXEC listar_alunos_disciplina(id_disciplina);


-- Pacote PKG_PROFESSOR

-- Cursor para total de turmas por professor:
-- Lista os nomes dos professores e o total de turmas que cada um leciona (somente aqueles com mais de uma turma).

DECLARE
    CURSOR cur_total_turmas_prof IS
        SELECT p.nome, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.nome
        HAVING COUNT(t.id_turma) > 1;
    v_nome_professor professor.nome%TYPE;
    v_total_turmas NUMBER;
BEGIN
    OPEN cur_total_turmas_prof;
    LOOP
        FETCH cur_total_turmas_prof INTO v_nome_professor, v_total_turmas;
        EXIT WHEN cur_total_turmas_prof%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Professor: ' || v_nome_professor || ', Total de Turmas: ' || v_total_turmas);
    END LOOP;
    CLOSE cur_total_turmas_prof;
END;
/

-- Como Executar:
-- Declare o cursor e percorra os registros conforme o código acima.


-- Function para total de turmas de um professor:
-- Recebe o id_professor e retorna o total de turmas em que ele atua como responsável.

CREATE OR REPLACE FUNCTION total_turmas_professor(p_id_professor NUMBER) RETURN NUMBER IS
    v_total_turmas NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_total_turmas
    FROM turma
    WHERE id_professor = p_id_professor;

    RETURN v_total_turmas;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RETURN 0;
END total_turmas_professor;
/

-- Como Executar:
-- SELECT total_turmas_professor(id_professor) FROM dual;


-- Function para professor de uma disciplina:
-- Recebe o id_disciplina e retorna o nome do professor que ministra essa disciplina.

CREATE OR REPLACE FUNCTION professor_da_disciplina(p_id_disciplina NUMBER) RETURN VARCHAR2 IS
    v_nome_professor VARCHAR2(100);
BEGIN
    SELECT p.nome
    INTO v_nome_professor
    FROM professor p
    JOIN turma t ON p.id_professor = t.id_professor
    WHERE t.id_disciplina = p_id_disciplina;

    RETURN v_nome_professor;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Nenhum professor encontrado para a disciplina.';
    WHEN OTHERS THEN
        RETURN 'Erro ao buscar o professor.';
END professor_da_disciplina;
/

-- Como Executar:
-- SELECT professor_da_disciplina(id_disciplina) FROM dual;
 
