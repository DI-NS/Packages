# Exercício Packages

## Introdução

Este projeto contém pacotes PL/SQL que implementam operações para gerenciamento de um sistema acadêmico, incluindo alunos, disciplinas e professores. Para executar os comandos descritos neste README, você precisará de um ambiente Oracle configurado, como o Oracle Live SQL ou qualquer outra instância do Oracle Database.

Antes de começar a executar os pacotes e funções descritos, você precisará criar as tabelas e, opcionalmente, as sequências do banco de dados. Aqui estão as opções:

- **Criar Sequências (Opcional)**: As sequências são utilizadas para gerar IDs automáticos para algumas tabelas. Caso deseje criá-las, clique [aqui](https://github.com/DI-NS/Packages/blob/main/Estrutura%20do%20banco%20de%20dados/Criando_sequences.sql).

- **Criar e Popular as Tabelas**: Para criar as tabelas necessárias e popular com alguns dados, clique [aqui](https://github.com/DI-NS/Packages/blob/main/Estrutura%20do%20banco%20de%20dados/criando_tabelas.sql).

> **Observação**: As tabelas incluem informações sobre alunos, disciplinas, professores, entre outras. Certifique-se de criá-las antes de prosseguir com a execução dos pacotes.

## Procedimentos e Funções Criados

### 1. Procedure `listar_total_turmas_professor`

**Descrição**:
Esta procedure lista o nome dos professores e o total de turmas que cada um leciona, considerando apenas os professores que ministram mais de uma turma.

**Código**:

```sql
CREATE OR REPLACE PROCEDURE listar_total_turmas_professor IS
    CURSOR cur_total_turmas_prof IS
        SELECT p.nome, COUNT(t.id_turma) AS total_turmas
        FROM professor p
        JOIN turma t ON p.id_professor = t.id_professor
        GROUP BY p.nome
        HAVING COUNT(t.id_turma) > 1;
BEGIN
    FOR rec IN cur_total_turmas_prof LOOP
        DBMS_OUTPUT.PUT_LINE('Professor: ' || rec.nome || ', Total de Turmas: ' || rec.total_turmas);
    END LOOP;
END listar_total_turmas_professor;
/
```

**Como Executar**:

```sql
-- Ativar o DBMS_OUTPUT para visualizar o resultado
SET SERVEROUTPUT ON;

-- Executar a procedure
EXEC listar_total_turmas_professor;
```

**Resultado Esperado**:

- A procedure irá imprimir o nome de cada professor e o total de turmas que ele leciona, para aqueles que ministram mais de uma turma. Exemplo:
  ```
  Professor: Luiza Pinto, Total de Turmas: 3
  Professor: Vinícius Vieira, Total de Turmas: 2
  ```

### 2. Function `total_turmas_professor`

**Descrição**:
Esta function retorna o total de turmas em que um professor atua como responsável. Ela recebe o `id_professor` como parâmetro e retorna um valor numérico.

**Código**:

```sql
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
```

**Como Executar**:

```sql
SELECT total_turmas_professor(1) AS total_de_turmas FROM dual;
```

- Substitua `1` pelo `id_professor` que deseja consultar.

**Resultado Esperado**:

- O comando retornará o total de turmas em que o professor especificado é responsável. Exemplo:
  ```
  TOTAL_DE_TURMAS
  5
  ```

### 3. Function `professor_da_disciplina`

**Descrição**:
Esta function retorna o nome do professor que ministra uma disciplina específica. Ela recebe o `id_disciplina` como parâmetro e retorna o nome do professor.

**Código**:

```sql
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
```

**Como Executar**:

```sql
SELECT professor_da_disciplina(8) AS nome_do_professor FROM dual;
```

- Substitua `8` pelo `id_disciplina` que deseja consultar.

**Resultado Esperado**:

- O comando retornará o nome do professor que ministra a disciplina especificada. Exemplo:
  ```
  NOME_DO_PROFESSOR
  Luiza Pinto
  ```
- Se nenhum professor for encontrado, a mensagem **'Nenhum professor encontrado para a disciplina.'** será retornada.

## Resumo dos Pacotes

### Pacote PKG\_ALUNO

1. **Procedure de exclusão de aluno**:

   - Recebe o ID do aluno como parâmetro e exclui o registro correspondente na tabela de alunos, além de remover todas as matrículas associadas.

   **Código**:

   ```sql
   CREATE OR REPLACE PROCEDURE excluir_aluno(p_id_aluno NUMBER) IS
   BEGIN
       DELETE FROM matricula WHERE id_aluno = p_id_aluno;
       DELETE FROM aluno WHERE id_aluno = p_id_aluno;
   END excluir_aluno;
   /
   ```

   **Como Executar**:

   ```sql
   EXEC excluir_aluno(id_aluno);
   ```

2. **Cursor de listagem de alunos maiores de 18 anos**:

   - Lista o nome e a data de nascimento de todos os alunos com idade superior a 18 anos.

   **Como Executar**:

   ```sql
   -- Declarar o cursor e percorrer os registros
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
   ```

3. **Cursor com filtro por curso**:

   - Recebe o `id_curso` e exibe os nomes dos alunos matriculados no curso especificado.

   **Como Executar**:

   ```sql
   -- Declarar o cursor passando o parâmetro id_curso
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
   ```

### Pacote PKG\_DISCIPLINA

1. **Procedure de cadastro de disciplina**:

   - Recebe o nome, a descrição e a carga horária da disciplina e insere esses dados na tabela correspondente.

   **Código**:

   ```sql
   CREATE OR REPLACE PROCEDURE cadastrar_disciplina(p_nome VARCHAR2, p_descricao CLOB, p_carga_horaria NUMBER) IS
   BEGIN
       INSERT INTO disciplina (nome, descricao, carga_horaria)
       VALUES (p_nome, p_descricao, p_carga_horaria);
   END cadastrar_disciplina;
   /
   ```

   **Como Executar**:

   ```sql
   EXEC cadastrar_disciplina('Matemática Avançadas', 'Curso focado em técnicas avançadas de matemáticas', 120);
   ```

2. **Cursor para total de alunos por disciplina**:

   - Percorre as disciplinas e exibe o número total de alunos matriculados em cada uma (somente disciplinas com mais de 10 alunos).

   **Como Executar**:

   ```sql
   -- Declarar o cursor e percorrer os registros
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
   ```

3. **Cursor com média de idade por disciplina**:

   - Recebe o `id_disciplina` e calcula a média de idade dos alunos matriculados.

   **Como Executar**:

   ```sql
   -- Declarar o cursor passando o parâmetro id_disciplina
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
   ```

4. **Procedure para listar alunos de uma disciplina**:

    - Recebe o `id_disciplina` e exibe os nomes dos alunos matriculados nela.
    
    **Código**:

    ```sql
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
    ```


    **Como Executar**:

    ```sql
    EXEC listar_alunos_disciplina(id_disciplina);
    ```

### Pacote PKG\_PROFESSOR

1. **Cursor para total de turmas por professor**:

   - Lista os nomes dos professores e o total de turmas que cada um leciona (somente aqueles com mais de uma turma).

   **Como Executar**:

   ```sql
   -- Declarar o cursor e percorrer os registros
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
   ```

2. **Function para total de turmas de um professor**:

   - Recebe o `id_professor` e retorna o total de turmas em que ele atua como responsável.

   **Código**:

   ```sql
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
   ```

   **Como Executar**:

   ```sql
   SELECT total_turmas_professor(id_professor) FROM dual;
   ```

3. **Function para professor de uma disciplina**:

   - Recebe o `id_disciplina` e retorna o nome do professor que ministra essa disciplina.

   **Código**:

   ```sql
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
   ```

   **Como Executar**:

   ```sql
   SELECT professor_da_disciplina(id_disciplina) FROM dual;
   ```

## Como Habilitar DBMS\_OUTPUT no Oracle Live SQL

Para visualizar a saída das procedures e functions que utilizam `DBMS_OUTPUT.PUT_LINE`, siga os seguintes passos:

1. No Oracle Live SQL, clique no ícone de engrenagem no canto superior direito.
2. Selecione "Ativar Saída de Script" para visualizar os resultados das mensagens impressas.

## Observações

- Certifique-se de que as tabelas `professor` e `turma` estejam devidamente criadas e populadas no banco de dados antes de executar os scripts.
- Caso encontre erros durante a execução, verifique se todos os objetos (tabelas, procedures, functions) foram criados corretamente e estão no mesmo esquema.

