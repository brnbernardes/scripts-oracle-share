create or replace procedure sys.schema_grant(p_owning_schema varchar2, p_recipient varchar2) is

     errs_found boolean := false;

     cursor c_all is
        select
           owner owner
          ,object_name
           ,object_type
           ,decode(object_type
                             ,'TABLE'   ,
                                 decode(external,'YES','SELECT','SELECT,INSERT,UPDATE,DELETE,REFERENCES')
                             ,'VIEW'    ,'SELECT,INSERT,UPDATE,DELETE'
                             ,'SEQUENCE','SELECT'
                             ,'EXECUTE') priv
         from
           ( select o.owner,o.object_name,o.object_type,'NO' external
             from   dba_objects o
             where  o.owner = upper(p_owning_schema)
             and    o.object_type in ('FUNCTION','PACKAGE','PROCEDURE','SEQUENCE','TYPE','VIEW')
             and    o.generated = 'N'
             and    o.secondary = 'N'
             and    o.object_name not like 'AQ$%'
             union all
             select o.owner,o.object_name,o.object_type, t.external
             from   dba_objects o,
                    dba_tables t
             where  o.owner = upper(p_owning_schema)
             and    o.object_type  = 'TABLE'
             and    o.generated = 'N'
             and    o.secondary = 'N'
             and    o.object_name not like 'AQ$%'
             and    o.owner = t.owner
             and    o.object_name = t.table_name
           )
         order by decode(object_type  
                         ,'VIEW', 1   
                         , 0) asc     
                 ,owner
                 ,object_name;
 
      type t_grant_list is table of c_all%rowtype;
      r    t_grant_list;
 
      l_ddl_indicator number;
 
      procedure logger(m varchar2) is
      begin
        dbms_output.put_line(m);
      end;
 
   begin
     open c_all;
     fetch c_all bulk collect into r;
     close c_all;
 
     for i in 1 .. r.count loop
         dbms_output.put_line(rpad(r(i).object_type,20)||r(i).owner||'.'||r(i).object_name)   ;
 
         begin
           logger('grant '||r(i).priv||' on '||r(i).owner||'.'||r(i).object_name||' to '||p_recipient);
           execute immediate 'grant '||r(i).priv||' on '||r(i).owner||'.'||r(i).object_name||' to '||p_recipient;
 
         exception
           when others then
              logger('ERROR: '||sqlerrm);
              errs_found := true;
         end;
     end loop;
     if errs_found then
       logger('**** ERRORS FOUND ****');
     end if;
     logger('Finished, record count = '||r.count);
 
end;
/

set serveroutput on
exec sys.schema_grant('ERP','SCOTT')
