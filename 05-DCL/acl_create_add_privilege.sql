begin
  begin
    dbms_network_acl_admin.drop_acl(acl => 'all-network-PUBLIC.xml');
  exception
    when others then
      null;
  end;
  dbms_network_acl_admin.create_acl(acl         => 'all-network-PUBLIC.xml',
                                    description => 'Network connects for all',
                                    principal   => 'PUBLIC',
                                    is_grant    => true,
                                    privilege   => 'connect');
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl       => 'all-network-PUBLIC.xml',
                                       principal => 'PUBLIC',
                                       is_grant  => true,
                                       privilege => 'resolve');
  dbms_network_acl_admin.assign_acl(acl  => 'all-network-PUBLIC.xml',
                                    host => '*');
end;
/




--gaspar:
SELECT utl_http.request('http://grp.gaspar.sc.gov.br/esfinge/services/', '', '', '') FROM dual;


--blumenau que funciona: 
SELECT utl_http.request('http://172.17.2.2/esfinge/services/', '', '', '') FROM dual;



--FURB
declare
    l_url    varchar2(1000) := 'https://sapop1.furb.br/esfinge/services/';
    l_req    utl_http.req;
    l_result utl_http.resp;
    l_data   varchar2(32767);
  begin
    utl_http.set_wallet('file:/cloudfs/wallet/prd', 'SENHADAWALLET');
   l_req    := utl_http.begin_request(l_url);
   l_result := utl_http.get_response(l_req);
    begin
      loop
       utl_http.read_text(l_result, l_data, 1000);
        dbms_output.put_line(l_data);
      end loop;
   exception
      when utl_http.end_of_body then
        utl_http.end_response(l_result);
    end;
 end;
  /


declare
    l_url    varchar2(1000) := 'https://201.54.207.31/';
    l_req    utl_http.req;
    l_result utl_http.resp;
    l_data   varchar2(32767);
  begin
    utl_http.set_wallet('file:/cloudfs/wallet/prd', 'SENHADAWALLET');
   l_req    := utl_http.begin_request(l_url);
   l_result := utl_http.get_response(l_req);
    begin
      loop
       utl_http.read_text(l_result, l_data, 1000);
        dbms_output.put_line(l_data);
      end loop;
   exception
      when utl_http.end_of_body then
        utl_http.end_response(l_result);
    end;
 end;
  /

