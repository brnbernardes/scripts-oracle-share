No Oracle Database, a contenção de bloqueio do tipo TM (table-level enqueue) ocorre quando múltas sessões tentam simultaneamente realizar operações DML (como INSERT, UPDATE, DELETE) em tabelas que estão envolvidas em certas restrições de integridade (como constraints) ou operações que exigem serialização.

As principais causas de TM contention incluem:

⸻

1. Constraints (particularmente FOREIGN KEYS não indexadas)
	•	Quando uma tabela filha possui uma constraint de chave estrangeira (foreign key) para uma tabela pai e essa foreign key não está indexada, o Oracle pode bloquear a tabela filha durante operações na tabela pai (como DELETE ou UPDATE da chave primária).
	•	Isso gera um bloqueio TM exclusivo, impactando sessões que tentam modificar os dados na tabela filha ao mesmo tempo.

✅ Solução: Crie índices nas colunas que compõem as foreign keys.

⸻

2. DDL concorrente (como ALTER TABLE)
	•	Se uma sessão está executando DDL (ex: ALTER TABLE), e outra sessão tenta realizar DML simultaneamente na mesma tabela, ocorre contenção TM.

⸻

3. Massivo DML concorrente na mesma tabela
	•	Grandes volumes de sessões executando INSERT, UPDATE ou DELETE na mesma tabela simultaneamente podem levar a contenção TM (embora neste caso normalmente o problema maior seja TX – row-level locking).
	•	Porém, em certas versões e cenários (por exemplo, com triggers envolvidas), isso pode gerar enfileiramento TM.

⸻

4. Triggers e Enqueues de DDL
	•	Tabelas que possuem triggers (especialmente do tipo AFTER INSERT/UPDATE) podem gerar contenção TM em ambientes com alto volume de DML.

⸻

Diagnóstico:

A contenção TM aparece comumente na view V$SESSION como:
	•	EVENT: enq: TM – contention
	•	P1: TM lock (identifica o object_id da tabela)
	•	Wait Class: Concurrency
