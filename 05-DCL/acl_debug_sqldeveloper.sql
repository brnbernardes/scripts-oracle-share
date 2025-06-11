SELECT host,
       lower_port,
       upper_port,
       ace_order,
       principal,
       principal_type,
       grant_type,
       inverted_principal,
       privilege,
       start_date,
       end_date
  FROM (SELECT aces.*,
               dbms_network_acl_utility.contains_host('*',host) precedence
          FROM dba_host_aces aces)
 WHERE precedence IS NOT NULL
 ORDER BY precedence DESC,
          lower_port NULLS LAST,
          upper_port NULLS LAST,
          ace_order;

--> Create ACL:
BEGIN
     DBMS_NETWORK_ACL_ADMIN.create_acl (
        acl          => 'debug_admrh.xml',
        description  => 'TCP, SMTP, MAIL, HTTP Access',
        principal    => 'ADMRH',
        is_grant     => TRUE,
        privilege    => 'connect',
        start_date   => NULL,
        end_date     => NULL);
END;
/

--> Assign ACL:
BEGIN
     DBMS_NETWORK_ACL_ADMIN.assign_acl (acl         => 'debug_admrh.xml',
                                        HOST        => '*',
                                        lower_port  => NULL,
                                        upper_port  => NULL);
END;
/

--> Add privilege:
BEGIN
   DBMS_NETWORK_ACL_ADMIN.add_privilege (acl         => 'debug_admrh.xml',
                                         principal   => 'ADMRH',
                                         is_grant    => TRUE,
                                         privilege   => 'connect',
                                         start_date  => NULL,
                                         end_date    => NULL);

   DBMS_NETWORK_ACL_ADMIN.add_privilege (acl         => 'debug_admrh.xml',
                                         principal   => 'ADMRH',
                                         is_grant    => TRUE,
                                         privilege   => 'resolve',
                                         --port        => '*',
                                         start_date  => NULL,
                                         end_date    => NULL);
END;
/

--> Append Host ACE (access control entry)
begin 
dbms_network_acl_admin.append_host_ace (host=>'*', 
                                        ace=> sys.xs$ace_type(privilege_list=>sys.XS$NAME_LIST('JDWP'), 
                                        principal_name=>'ADMRH', 
                                        principal_type=>sys.XS_ACL.PTYPE_DB)
                                        ); 
 end; 
/ 