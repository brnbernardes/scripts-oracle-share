/*   
FAILED_LOGIN_ATTEMPTS – Número de tentativas de logar com erro que irá fazer com que a senha fique em lock.
PASSWORD_LIFE_TIME – Quantidade de dias até que a senha expire.

PASSWORD_REUSE_TIME – Quantidade de dias para que uma senha não pode ser reutilizada.
PASSWORD_REUSE_MAX –  Quantidade de alterações de senha necessárias antes que a senha atual possa ser reutilizada.
                  Os parâmetros devem ser utilizados em conjuntos, exemplo: 
                    se PASSWORD_REUSE_TIME = 30 e PASSWORD_REUSE_MAX como 10
                    o usuário poderá reutilizar a senha após 30 dias se a senha já tiver sido alterada 10 vezes.

PASSWORD_LOCK_TIME – Quantidade de dias que a conta ficará em lock após atingir o limit de FAILED_LOGIN_ATTEMPTS
PASSWORD_GRACE_TIME – Quantidade de dias, depois do primeiro login em que a senha já esta expirada, que a senha ainda pode ser utilizada, dando tempo para o usuário alterar. 
INACTIVE_ACCOUNT_TIME - Quantitade de dias que a conte fica sem login antes de bloquear.
PASSWORD_ROLLOVER_TIME - Quantidade em dias (minimo 1/24 = 1h) para que possamos utilizar a senha antiga e a nova / bom para usuários de aplicação em janela de manutenção
PASSWORD_VERIFY_FUNCTION ora12c_verify_function:
    - A senha contém pelo menos 8 caracteres e inclui pelo menos um caractere numérico e um alfabético.
    - A senha não é igual ao nome de usuário ou o nome de usuário está invertido.
    - A senha não é igual ao nome do banco de dados.
    - A senha não contém a palavra oracle(como oracle123).
    - A senha difere da senha anterior em pelo menos 3 caracteres.
    - A senha contém pelo menos 1 caractere especial.
    
    - A seguinte verificação interna também é aplicada:
    - A senha não contém o caractere de aspas duplas ( "). No entanto, pode ser colocado entre aspas duplas.
*/

/*
A senha precisa conter:
-> pelo menos 8 caracteres e inclui pelo menos um caractere numérico e um alfabético.
-> pelo menos 1 caractere especial.
-> diferenciar da senha anterior em pelo menos 3 caracteres.
*/
-- Alteração da senha:
ALTER USER "COLABORADOR@THEMA" IDENTIFIED BY "senha nova" replace "senha temporária";  


-- Create Profile: oficial após SQL Developer estar configurado nas estações dos analistas para troca de senha
CREATE PROFILE thema_nameduser_profile LIMIT
   FAILED_LOGIN_ATTEMPTS 10
   PASSWORD_LIFE_TIME 90
   PASSWORD_REUSE_TIME 180
   PASSWORD_REUSE_MAX 3
   PASSWORD_GRACE_TIME 10
   PASSWORD_LOCK_TIME 1/24/60
   INACTIVE_ACCOUNT_TIME 365
   PASSWORD_ROLLOVER_TIME  0
   PASSWORD_VERIFY_FUNCTION ora12c_verify_function;

-- Create Profile: temporário para forçar regras na definição da senha, sem expirar 
create PROFILE THEMA_NAMEDUSER_PROFILE LIMIT
   FAILED_LOGIN_ATTEMPTS 10
   PASSWORD_LOCK_TIME 1/24/60
   PASSWORD_LIFE_TIME UNLIMITED
   PASSWORD_REUSE_TIME UNLIMITED
   PASSWORD_REUSE_MAX UNLIMITED
   PASSWORD_GRACE_TIME 10
   INACTIVE_ACCOUNT_TIME 365
   PASSWORD_ROLLOVER_TIME  0
   PASSWORD_VERIFY_FUNCTION ora12c_verify_function;

-- Alter Profile: alterar profile já criado para temporário para forçar regras na definição da senha, sem expirar 
ALTER PROFILE THEMA_NAMEDUSER_PROFILE LIMIT
   FAILED_LOGIN_ATTEMPTS 10
   PASSWORD_LOCK_TIME 1/24/60
   PASSWORD_LIFE_TIME UNLIMITED
   PASSWORD_REUSE_TIME UNLIMITED
   PASSWORD_REUSE_MAX UNLIMITED
   PASSWORD_GRACE_TIME 10
   INACTIVE_ACCOUNT_TIME 365
   PASSWORD_ROLLOVER_TIME  0
   PASSWORD_VERIFY_FUNCTION ora12c_verify_function;

/*
Exemplo:
SQL> alter user "BRUNO.BERNARDES@THEMA" identified by 123;
ORA-28221: REPLACE não especificado

SQL> alter user "BRUNO.BERNARDES@THEMA" identified by 123 replace 02674722002;
ORA-28003: falha na verificação de senha para a senha especificada
ORA-20000: password length less than 8 bytes

SQL> alter user "BRUNO.BERNARDES@THEMA" identified by 12345678 replace 02674722002;
ORA-28003: falha na verificação de senha para a senha especificada
ORA-20000: password must contain 1 or more letters

SQL> alter user "BRUNO.BERNARDES@THEMA" identified by AB12345678 replace 02674722002;
ORA-28003: falha na verificação de senha para a senha especificada
ORA-20000: password must contain 1 or more special characters

SQL> alter user "BRUNO.BERNARDES@THEMA" identified by "AB12345678%" replace 02674722002;
User altered
*/