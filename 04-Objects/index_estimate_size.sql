declare
  v_used_bytes int;
  v_alloc_bytes int;
begin
  dbms_space.CREATE_INDEX_COST(
     'create index ix on T ( owner, object_type, object_id)'
     ,used_bytes=>v_used_bytes
     ,alloc_bytes=>v_alloc_bytes);
  dbms_output.put_line('used_mb: '  || round(v_used_bytes/1024/1024) );
  dbms_output.put_line('alloc_mb: ' || round(v_alloc_bytes/1024/1024));
end;
/