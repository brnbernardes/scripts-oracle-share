SELECT owner,
        sum(qtd) quantidade,
         listagg(object_type, ', ') within group(order by object_type) object_type
   from (SELECT owner, count(1) qtd, object_type
            FROM dba_objects O
          INNER JOIN dba_users U
             ON o.owner = u.username
           WHERE default_tablespace not in ('SYSTEM', 'SYSAUX')
          GROUP BY owner, object_type
         ORDER BY 2)
  GROUP BY owner;