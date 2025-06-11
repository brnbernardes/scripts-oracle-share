--> https://acaciolrdba.wordpress.com/2024/12/02/pl-sql-automacao-resize-de-datafile-e-tablespace/

set serveroutput on
declare
  v_dg_free    v$asm_diskgroup.free_mb%type;
  v_dg_pct     v$asm_diskgroup.free_mb%type;
  v_isbig      dba_tablespaces.bigfile%type;
  v_max_df     dba_data_files.file_id%type;
  v_dg_name    v$asm_diskgroup.name%type;
  v_tbs_size   dba_data_files.bytes%type;
  v_tbs_used   dba_data_files.bytes%type;
  v_sql        v$sql.sql_text%type;
  v_pct_resize number;
  v_pct_tbs    number;
  vexit        number;
 
begin
 
  --cursor to get the datafiles to analisy 
  for x in (select x.file_id,
                   x.file_name,
                   x.contents,
                   x.bytes / (1024 * 1024) bytes_mb,
                   x.maxbytes / (1024 * 1024) maxbytes_mb,
                   x.autoextensible,
                   x.tablespace_name
              from dba_data_files x
             where x.tablespace_name = upper('USERS')
               and x.file_id =
                   (select max(y.file_id)
                      from dba_data_files y
                     where y.tablespace_name = x.tablespace_name)
             group by file_id,
                      file_name,
                      bytes,
                      maxbytes,
                      autoextensible,
                      tablespace_name) loop
   
    --validate ASM space and percentage
    select round(free_mb / 1024, 2) as free_gb,
           round((1 - (free_mb / total_mb)) * 100, 2) as pct_used
      into v_dg_free, v_dg_pct
      from v$asm_diskgroup
     where total_mb != 0
       and name = substr(regexp_substr(x.file_name, '[^/"]+', 1, 1), 2)
     order by name;
   
    if v_dg_free >= 100 and v_dg_pct <= 75 then
     
      --verify bigfile
      select bigfile
        into v_isbig
        from dba_tablespaces
       where tablespace_name = x.tablespace_name;
     
      --verify max file_id
      select max(x.file_id)
        into v_max_df
        from dba_data_files x
       where tablespace_name = x.tablespace_name;
     
      --verify diskgroup name
      select regexp_substr(file_name, '[^/"]+', 1, 1)
        into v_dg_name
        from dba_data_files
       where tablespace_name = x.tablespace_name
         and file_id = x.file_id;
     
      --validate if is a bigfile
      if v_isbig = 'YES' then
       
        --validate if this is extensible file
        if x.autoextensible = 'YES' then
         
          --calculate the % to resize a bigfile in 30%
          v_pct_resize := (x.bytes_mb * 30 / 100) + x.bytes_mb;
         
          --execute the resize in the bigfile
          v_sql := 'alter database datafile ''' || x.file_name ||
                   ''' resize ' || round(v_pct_resize) || 'm';
          execute immediate v_sql;
         
          v_sql := null;
         
          dbms_output.put_line('EXECUTADO RESIZE DO DATAFILE BIGFILE ' ||
                               x.file_id);
          vexit := 0;
          dbms_output.put_line(vexit);
         
        else
         
          --adjuste the file to autoextend
          v_sql := 'alter database datafile ' || x.file_id ||
                   ' autoextend on next 10000m maxsize 32767m';
          execute immediate v_sql;
         
          v_sql := null;
         
          dbms_output.put_line('EXECUTADO AUTOEXTEND DO DATAFILE SMALLFILE ' ||
                               x.file_id);
          vexit := 0;
          dbms_output.put_line(vexit);
         
        end if;
       
        --validate if is not a bigfile
      elsif v_isbig = 'NO' then
       
        --validate if this is extensible file
        if x.autoextensible = 'YES' then
         
          --calculate the % to resize a smallfile in 30%
          v_pct_resize := (x.bytes_mb * 30 / 100) + x.bytes_mb;
         
          --execute the resize in the small file
          v_sql := 'alter database datafile ''' || x.file_name ||
                   ''' resize ' || round(v_pct_resize) || 'm';
          execute immediate v_sql;
         
          v_sql := null;
         
          dbms_output.put_line('EXECUTADO RESIZE DO DATAFILE SMALL FILE ' ||
                               x.file_id);
          vexit := 0;
          dbms_output.put_line(vexit);
         
          --validate if this is not extensible file
        elsif x.autoextensible = 'NO' then
         
          v_sql := 'alter database datafile ' || x.file_id ||
                   ' autoextend on next 10000m maxsize 32767m';
          execute immediate v_sql;
         
          v_sql := null;
         
          dbms_output.put_line('EXECUTADO AUTOEXTEND DO DATAFILE SMALLFILE ' ||
                               x.file_id);
          vexit := 0;
          dbms_output.put_line(vexit);
         
        else
         
          if x.contents = 'TEMPORARY' then
           
            --add a new tempfile to the tablespace
            v_sql := 'alter tablespace ' || x.tablespace_name ||
                     ' add tempfile ''' || v_dg_name || ''' size 32767m';
            execute immediate v_sql;
           
            v_sql := null;
           
            dbms_output.put_line('ADICIONADO NOVO TEMPFILE SMALLFILE');
            vexit := 0;
           
          else
           
            --add a new datafile to the tablespace
            v_sql := 'alter tablespace ' || x.tablespace_name ||
                     ' add datafile ''' || v_dg_name || ''' size 32767m';
            execute immediate v_sql;
           
            v_sql := null;
           
            dbms_output.put_line('ADICIONADO NOVO DATAFILE SMALLFILE');
            vexit := 0;
          end if;
         
        end if;
      else
       
        if x.contents = 'TEMPORARY' then
         
          --add a new tempfile to the tablespace
          v_sql := 'alter tablespace ' || x.tablespace_name ||
                   ' add tempfile ''' || v_dg_name || ''' size 32767m';
          execute immediate v_sql;
         
          v_sql := null;
         
          dbms_output.put_line('ADICIONADO NOVO TEMPFILE SMALLFILE');
          vexit := 0;
         
        else
         
          --add a new datafile to the tablespace
          v_sql := 'alter tablespace ' || x.tablespace_name ||
                   ' add datafile ''' || v_dg_name || ''' size 32767m';
          execute immediate v_sql;
         
          v_sql := null;
         
          dbms_output.put_line('ADICIONADO NOVO DATAFILE SMALLFILE');
          vexit := 0;
        end if;
       
      end if;
    else
     
      vexit := 1;
      dbms_output.put_line(vexit);
      dbms_output.put_line('WARNING: AVALIAR ESPAÇO NO ASM. LIVRE: ' ||
                           v_dg_free || ' PORCENTAGEM: ' || v_dg_pct);
     
    end if;
  end loop;
exception
  when others then
    dbms_output.put_line('Error : ' || dbms_utility.format_error_stack() ||
                         CHR(10) || dbms_utility.format_error_backtrace());
    vexit := 1;
    dbms_output.put_line(vexit);
end;
/